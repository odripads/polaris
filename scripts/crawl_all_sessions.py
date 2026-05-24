"""
POLARIS Corpus
Script: crawl_all_sessions.py

Purpose:
    Crawl ALL sessions from 2015-2016 through 2024-2025.
    Skips sessions already completed (checks for existing processed CSV).
    Logs progress to data/crawl_log.txt.

Usage:
    python3 crawl_all_sessions.py

Author: Kalcer Institute / Odri (technical execution: Claude Code)
"""

import urllib.request
import xml.etree.ElementTree as ET
import re
import csv
import time
import os
import sys
from datetime import datetime

# ── Configuration ─────────────────────────────────────────────────────────────

API_BASE = "https://data.stortinget.no/eksport"
DELAY    = 0.7  # seconds between API calls

# All sessions in scope (Paris Agreement 2015 → present)
# 2022-2023 already crawled — script will detect and skip it
ALL_SESSIONS = [
    "2015-2016",
    "2016-2017",
    "2017-2018",
    "2018-2019",
    "2019-2020",
    "2020-2021",
    "2021-2022",
    "2022-2023",  # already done — will be skipped
    "2023-2024",
    "2024-2025",
]

# Keyword lists from POLARIS curation logic (briefing Section 4)
KEYWORDS_CORE = [
    "petroleum", "olje", "klimaendring", "klima", "energiomstilling",
    "fornybar energi", "fornybar", "bærekraft", "oljefondet", "nbim",
]
KEYWORDS_EXTENDED = [
    "grønn vekst", "karbonfangst", "rettferdig omstilling",
]

# ── Helpers ───────────────────────────────────────────────────────────────────

def log(msg, logfile):
    ts = datetime.now().strftime("%H:%M:%S")
    line = f"[{ts}] {msg}"
    print(line, flush=True)
    with open(logfile, "a", encoding="utf-8") as f:
        f.write(line + "\n")

def fetch_xml(url):
    try:
        with urllib.request.urlopen(url, timeout=15) as r:
            return r.read().decode("utf-8")
    except Exception as e:
        return None

def strip_tags(text):
    text = re.sub(r"<[^>]+>", " ", text)
    return re.sub(r"\s+", " ", text).strip()

def extract_name_party(navn_text):
    navn_text = strip_tags(navn_text).strip()
    m = re.match(r"^(.+?)\s*\(([A-ZÆØÅ\-]+)\)\s*(?:\[[\d:]+\])?", navn_text)
    if m:
        return m.group(1).strip(), m.group(2).strip()
    return navn_text.split("[")[0].strip().rstrip(":"), ""

def keyword_match(text):
    text_lower = text.lower()
    matched_core = [kw for kw in KEYWORDS_CORE if kw in text_lower]
    matched_ext  = [kw for kw in KEYWORDS_EXTENDED if kw in text_lower]
    all_matched  = matched_core + matched_ext
    return bool(all_matched), all_matched, bool(matched_ext) and not matched_core

def get_meeting_refs(session_id):
    url = f"{API_BASE}/moter?sesjonid={session_id}"
    content = fetch_xml(url)
    if not content:
        return []
    time.sleep(DELAY)
    ns = "http://data.stortinget.no"
    root = ET.fromstring(content)
    refs = []
    for m in root.findall(f".//{{{ns}}}mote"):
        ref_el  = m.find(f"{{{ns}}}referat_id")
        dato_el = m.find(f"{{{ns}}}mote_dato_tid")
        if ref_el is not None and ref_el.text and dato_el is not None:
            refs.append((dato_el.text[:10], ref_el.text))
    refs.sort()
    return refs

def parse_transcript(xml_text, session_id, meeting_date, referat_id):
    speeches = []
    sak_blocks = re.findall(
        r'<Sak[ >][^>]*?sakID="(\d+)"[^>]*>(.*?)</Sak>',
        xml_text, re.DOTALL
    )
    if not sak_blocks:
        sak_blocks = [("0", xml_text)]
    for sak_id, sak_content in sak_blocks:
        title_m = re.search(r"<Saktittel[^>]*>(.*?)</Saktittel>", sak_content, re.DOTALL)
        case_title = strip_tags(title_m.group(1)) if title_m else ""
        for tag in ["Hovedinnlegg", "Presinnlegg", "Replikk"]:
            blocks = re.findall(rf"<{tag}[ >].*?</{tag}>", sak_content, re.DOTALL)
            for block in blocks:
                navn_m = re.search(r"<Navn[^>]*>(.*?)</Navn>", block, re.DOTALL)
                if navn_m:
                    speaker_name, party = extract_name_party(navn_m.group(1))
                else:
                    speaker_name, party = "Unknown", ""
                full_text  = strip_tags(block)
                word_count = len(full_text.split())
                if speaker_name.lower().startswith("president") and word_count < 80:
                    continue
                speeches.append({
                    "session_id":   session_id,
                    "date":         meeting_date,
                    "referat_id":   referat_id,
                    "case_id":      sak_id,
                    "case_title":   case_title,
                    "speech_type":  tag,
                    "speaker_name": speaker_name,
                    "party":        party,
                    "speech_text":  full_text,
                    "word_count":   word_count,
                })
    return speeches

def save_csv(speeches, path, fieldnames):
    with open(path, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(speeches)

def crawl_session(session_id, raw_dir, proc_dir, logfile):
    safe = session_id.replace("-", "_")
    all_path      = os.path.join(proc_dir, f"speeches_{safe}.csv")
    filtered_path = os.path.join(proc_dir, f"filtered_{safe}.csv")

    # Skip if already done
    if os.path.exists(all_path) and os.path.exists(filtered_path):
        log(f"  SKIP {session_id} — already crawled", logfile)
        return 0, 0

    log(f"  START {session_id}", logfile)
    refs = get_meeting_refs(session_id)
    log(f"  {len(refs)} meetings found", logfile)

    all_speeches = []
    for i, (date, referat_id) in enumerate(refs):
        url      = f"{API_BASE}/publikasjon?publikasjonid={referat_id}&format=xml"
        xml_text = fetch_xml(url)
        time.sleep(DELAY)
        if not xml_text:
            log(f"    [{i+1}/{len(refs)}] {date} SKIP (fetch failed)", logfile)
            continue
        # Save raw
        raw_path = os.path.join(raw_dir, f"{referat_id}.xml")
        with open(raw_path, "w", encoding="utf-8") as f:
            f.write(xml_text)
        speeches = parse_transcript(xml_text, session_id, date, referat_id)
        all_speeches.extend(speeches)
        log(f"    [{i+1}/{len(refs)}] {date} → {len(speeches)} speeches", logfile)

    # Keyword filter
    filtered = []
    fieldnames = [
        "session_id","date","referat_id","case_id","case_title",
        "speech_type","speaker_name","party","word_count",
        "matched_keywords","extended_only","speech_text"
    ]
    for sp in all_speeches:
        matched, kw_list, ext_only = keyword_match(sp["speech_text"])
        sp["matched_keywords"] = ", ".join(kw_list)
        sp["extended_only"]    = ext_only
        if matched:
            filtered.append(sp)
    for sp in all_speeches:
        if "matched_keywords" not in sp:
            sp["matched_keywords"] = ""
            sp["extended_only"]    = False

    save_csv(all_speeches, all_path, fieldnames)
    save_csv(filtered, filtered_path, fieldnames)

    log(f"  DONE {session_id}: {len(all_speeches)} speeches, {len(filtered)} matched ({len(filtered)/max(len(all_speeches),1)*100:.1f}%)", logfile)
    return len(all_speeches), len(filtered)

# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    raw_dir  = os.path.join(base_dir, "data", "raw")
    proc_dir = os.path.join(base_dir, "data", "processed")
    logfile  = os.path.join(base_dir, "data", "crawl_log.txt")

    os.makedirs(raw_dir, exist_ok=True)
    os.makedirs(proc_dir, exist_ok=True)

    start = datetime.now()
    log(f"POLARIS Full Crawl — {start.strftime('%Y-%m-%d %H:%M:%S')}", logfile)
    log(f"Sessions: {ALL_SESSIONS}", logfile)
    log("=" * 60, logfile)

    total_speeches = 0
    total_filtered = 0

    for session_id in ALL_SESSIONS:
        s, f = crawl_session(session_id, raw_dir, proc_dir, logfile)
        total_speeches += s
        total_filtered += f

    end = datetime.now()
    elapsed = (end - start).total_seconds() / 60

    log("=" * 60, logfile)
    log(f"COMPLETE — {end.strftime('%Y-%m-%d %H:%M:%S')}", logfile)
    log(f"Total time: {elapsed:.1f} minutes", logfile)
    log(f"Total speeches: {total_speeches:,}", logfile)
    log(f"Total matched:  {total_filtered:,}", logfile)

if __name__ == "__main__":
    main()
