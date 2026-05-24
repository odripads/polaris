"""
NGDC — Norwegian Green Discourse Corpus
Script: crawl_session.py

Purpose:
    Crawl one Stortinget session (default: 2022-2023) and extract all
    plenary speeches, then apply keyword filter to return a structured CSV.

Usage:
    python3 crawl_session.py --session 2022-2023

Output:
    data/raw/   — one XML file per meeting transcript (preserved as-is)
    data/processed/speeches_<session>.csv  — all speeches as rows
    data/processed/filtered_<session>.csv  — keyword-matched speeches only

Author: Kalcer Institute / Odri (technical execution: Claude Code)
"""

import urllib.request
import xml.etree.ElementTree as ET
import re
import csv
import time
import os
import argparse
from datetime import datetime

# ── Configuration ────────────────────────────────────────────────────────────

API_BASE = "https://data.stortinget.no/eksport"
DELAY    = 0.7   # seconds between API calls (rate limit: 100/min)

# Keyword lists as defined in the NGDC curation logic (Section 4 of briefing)
# These are the discursive sites where green identity and extractivism collide

KEYWORDS_CORE = [
    "petroleum",
    "olje",
    "klimaendring",
    "klima",
    "energiomstilling",
    "fornybar energi",
    "fornybar",
    "bærekraft",
    "oljefondet",
    "nbim",
]

KEYWORDS_EXTENDED = [
    "grønn vekst",
    "karbonfangst",
    "rettferdig omstilling",
]

ALL_KEYWORDS = KEYWORDS_CORE + KEYWORDS_EXTENDED

# ── Helpers ──────────────────────────────────────────────────────────────────

def fetch_xml(url):
    """Fetch a URL and return its text content. Respects rate limit via DELAY."""
    try:
        with urllib.request.urlopen(url, timeout=15) as r:
            return r.read().decode("utf-8")
    except Exception as e:
        print(f"    [WARN] Failed to fetch {url}: {e}")
        return None

def strip_tags(text):
    """Remove XML tags and normalise whitespace to get plain text."""
    text = re.sub(r"<[^>]+>", " ", text)
    text = re.sub(r"\s+", " ", text).strip()
    return text

def extract_name_party(navn_text):
    """
    Parse speaker name and party from Navn tag text.
    Input example:  'Anne Kristine Linnestad (H) [10:05:00]'
    Returns:        ('Anne Kristine Linnestad', 'H')
    """
    navn_text = strip_tags(navn_text).strip()
    # Match "Name (PARTY) [timestamp]" or "Name (PARTY)"
    m = re.match(r"^(.+?)\s*\(([A-ZÆØÅ\-]+)\)\s*(?:\[[\d:]+\])?", navn_text)
    if m:
        return m.group(1).strip(), m.group(2).strip()
    # Fallback: Presidenten or Kongen
    return navn_text.split("[")[0].strip().rstrip(":"), ""

def keyword_match(text):
    """
    Check speech text against keyword list.
    Returns tuple: (matched: bool, matched_keywords: list, is_extended: bool)
    """
    text_lower = text.lower()
    matched_core = [kw for kw in KEYWORDS_CORE if kw in text_lower]
    matched_ext  = [kw for kw in KEYWORDS_EXTENDED if kw in text_lower]
    all_matched  = matched_core + matched_ext
    return bool(all_matched), all_matched, bool(matched_ext) and not matched_core

# ── Core extraction ───────────────────────────────────────────────────────────

def get_meeting_refs(session_id):
    """
    Fetch all plenary meetings for a session.
    Returns list of (date_str, referat_id) tuples, sorted by date.
    """
    print(f"  Fetching meeting list for session {session_id}...")
    url = f"{API_BASE}/moter?sesjonid={session_id}"
    content = fetch_xml(url)
    if not content:
        return []
    time.sleep(DELAY)

    # The API returns its own namespace
    ns = "http://data.stortinget.no"
    root = ET.fromstring(content)
    refs = []
    for m in root.findall(f".//{{{ns}}}mote"):
        ref_el  = m.find(f"{{{ns}}}referat_id")
        dato_el = m.find(f"{{{ns}}}mote_dato_tid")
        if ref_el is not None and ref_el.text and dato_el is not None:
            refs.append((dato_el.text[:10], ref_el.text))

    refs.sort()
    print(f"  Found {len(refs)} meetings with transcripts.")
    return refs


def parse_transcript(xml_text, session_id, meeting_date, referat_id):
    """
    Parse a meeting transcript XML and extract individual speeches.
    Returns list of speech dicts.
    """
    speeches = []

    # We parse with regex rather than ET because the transcript XML uses
    # a non-namespaced, custom schema (Forhandlinger, Sak, Navn, etc.)

    # Extract all Sak (case) blocks with their IDs and titles
    sak_blocks = re.findall(
        r'<Sak[ >][^>]*?sakID="(\d+)"[^>]*>(.*?)</Sak>',
        xml_text, re.DOTALL
    )

    if not sak_blocks:
        # Some meetings (ceremonial, openings) have no Sak structure
        # Still extract any speeches at the top level
        sak_blocks = [("0", xml_text)]

    for sak_id, sak_content in sak_blocks:
        # Case title
        title_m = re.search(r"<Saktittel[^>]*>(.*?)</Saktittel>", sak_content, re.DOTALL)
        case_title = strip_tags(title_m.group(1)) if title_m else ""

        # Extract speech blocks: Hovedinnlegg, Presinnlegg, Replikk
        # We treat all as "speeches" — the type is recorded
        speech_tags = ["Hovedinnlegg", "Presinnlegg", "Replikk"]
        for tag in speech_tags:
            blocks = re.findall(
                rf"<{tag}[ >].*?</{tag}>",
                sak_content, re.DOTALL
            )
            for block in blocks:
                # Speaker name
                navn_m = re.search(r"<Navn[^>]*>(.*?)</Navn>", block, re.DOTALL)
                if navn_m:
                    raw_navn = navn_m.group(1)
                    speaker_name, party = extract_name_party(raw_navn)
                else:
                    speaker_name, party = "Unknown", ""

                # Skip procedural Presidenten entries under 80 words
                # (they are chair announcements, not substantive speech)
                full_text = strip_tags(block)
                word_count = len(full_text.split())
                if speaker_name.lower().startswith("president") and word_count < 80:
                    continue

                speeches.append({
                    "session_id":       session_id,
                    "date":             meeting_date,
                    "referat_id":       referat_id,
                    "case_id":          sak_id,
                    "case_title":       case_title,
                    "speech_type":      tag,
                    "speaker_name":     speaker_name,
                    "party":            party,
                    "speech_text":      full_text,
                    "word_count":       word_count,
                })

    return speeches


def crawl_session(session_id, raw_dir, save_raw=True):
    """
    Main crawl loop for one session.
    Returns list of all speech dicts.
    """
    refs = get_meeting_refs(session_id)
    all_speeches = []

    for i, (date, referat_id) in enumerate(refs):
        print(f"  [{i+1}/{len(refs)}] {date} — {referat_id}", end="", flush=True)

        url = f"{API_BASE}/publikasjon?publikasjonid={referat_id}&format=xml"
        xml_text = fetch_xml(url)
        time.sleep(DELAY)

        if not xml_text:
            print("  [SKIP]")
            continue

        # Save raw XML
        if save_raw:
            raw_path = os.path.join(raw_dir, f"{referat_id}.xml")
            with open(raw_path, "w", encoding="utf-8") as f:
                f.write(xml_text)

        speeches = parse_transcript(xml_text, session_id, date, referat_id)
        all_speeches.extend(speeches)
        print(f"  → {len(speeches)} speeches")

    return all_speeches


def save_csv(speeches, path):
    """Write speeches list to CSV."""
    if not speeches:
        print(f"  [WARN] No speeches to write to {path}")
        return
    fieldnames = [
        "session_id", "date", "referat_id", "case_id", "case_title",
        "speech_type", "speaker_name", "party",
        "word_count", "matched_keywords", "extended_only",
        "speech_text"
    ]
    with open(path, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(speeches)
    print(f"  Saved {len(speeches)} rows → {path}")


# ── Main ─────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="Crawl Stortinget session speeches")
    parser.add_argument("--session", default="2022-2023", help="Session ID, e.g. 2022-2023")
    parser.add_argument("--no-raw", action="store_true", help="Skip saving raw XML files")
    args = parser.parse_args()

    session_id = args.session
    base_dir   = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    raw_dir    = os.path.join(base_dir, "data", "raw")
    proc_dir   = os.path.join(base_dir, "data", "processed")

    print(f"\nNGDC Crawler — Session: {session_id}")
    print(f"Started: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 55)

    # Step 1: Crawl
    all_speeches = crawl_session(session_id, raw_dir, save_raw=not args.no_raw)

    print(f"\nTotal speeches extracted: {len(all_speeches)}")

    # Step 2: Apply keyword filter
    filtered = []
    for sp in all_speeches:
        matched, kw_list, ext_only = keyword_match(sp["speech_text"])
        sp["matched_keywords"] = ", ".join(kw_list)
        sp["extended_only"]    = ext_only
        if matched:
            filtered.append(sp)

    # Also annotate non-matched speeches for the full CSV
    for sp in all_speeches:
        if "matched_keywords" not in sp:
            sp["matched_keywords"] = ""
            sp["extended_only"]    = False

    print(f"Keyword-matched speeches:  {len(filtered)}")
    print(f"Match rate:                {len(filtered)/len(all_speeches)*100:.1f}%")

    # Step 3: Save outputs
    print("\nSaving outputs...")
    safe_session = session_id.replace("-", "_")
    save_csv(all_speeches, os.path.join(proc_dir, f"speeches_{safe_session}.csv"))
    save_csv(filtered,     os.path.join(proc_dir, f"filtered_{safe_session}.csv"))

    print(f"\nDone: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 55)
    print(f"All speeches:      data/processed/speeches_{safe_session}.csv")
    print(f"Filtered corpus:   data/processed/filtered_{safe_session}.csv")
    print(f"Raw XML:           data/raw/ ({session_id} transcripts)")


if __name__ == "__main__":
    main()
