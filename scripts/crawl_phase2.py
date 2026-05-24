"""
POLARIS Phase 2 Crawler — Secondary Sources
Script: crawl_phase2.py

Sources:
  1. NBIM Annual Reports (2015–2024)         — nbim.no
  2. NBIM Responsible Investment Reports     — nbim.no
  3. Government white papers on energy/climate — regjeringen.no

Output:
  data/phase2/nbim/          — NBIM report texts (one JSON per doc)
  data/phase2/regjeringen/   — Government white paper texts
  data/phase2/phase2_corpus.csv — unified structured corpus

Author: Kalcer Institute / Odri (technical execution: Claude Code)
"""

import urllib.request
import re
import json
import csv
import time
import os
from datetime import datetime

DELAY = 1.0
HEADERS = {
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 Chrome/120.0.0.0 Safari/537.36",
    "Accept": "text/html,application/xhtml+xml",
}

KEYWORDS_CORE = ["petroleum", "oil", "climate", "renewable", "sustainability",
                 "fossil", "transition", "carbon", "emission", "green"]
KEYWORDS_NO   = ["petroleum", "olje", "klima", "fornybar", "bærekraft",
                 "fossil", "omstilling", "karbon", "utslipp", "grønn"]

BASE_DIR  = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
NBIM_DIR  = os.path.join(BASE_DIR, "data", "phase2", "nbim")
REGJ_DIR  = os.path.join(BASE_DIR, "data", "phase2", "regjeringen")
os.makedirs(NBIM_DIR, exist_ok=True)
os.makedirs(REGJ_DIR, exist_ok=True)

# ── Helpers ───────────────────────────────────────────────────────────────────

def fetch(url, timeout=15):
    try:
        req = urllib.request.Request(url, headers=HEADERS)
        with urllib.request.urlopen(req, timeout=timeout) as r:
            return r.read().decode("utf-8", errors="ignore")
    except Exception as e:
        print(f"    [WARN] {url}: {e}")
        return None

def strip_tags(html):
    html = re.sub(r"<script[^>]*>.*?</script>", " ", html, flags=re.DOTALL)
    html = re.sub(r"<style[^>]*>.*?</style>",  " ", html, flags=re.DOTALL)
    html = re.sub(r"<[^>]+>", " ", html)
    html = re.sub(r"&nbsp;", " ", html)
    html = re.sub(r"&[a-z]+;", " ", html)
    return re.sub(r"\s+", " ", html).strip()

def keyword_match(text):
    t = text.lower()
    all_kw = KEYWORDS_CORE + KEYWORDS_NO
    matched = [kw for kw in all_kw if kw in t]
    return list(set(matched))

def save_json(data, path):
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

# ── NBIM scraper ──────────────────────────────────────────────────────────────

NBIM_TARGETS = {}
for year in range(2015, 2025):
    y = str(year)
    NBIM_TARGETS[f"nbim_annual_{y}"] = {
        "url": f"https://www.nbim.no/en/news-and-insights/reports/{y}/annual-report-{y}/",
        "year": y, "institution": "NBIM", "doc_type": "annual_report", "language": "en"
    }
    if year >= 2016:
        NBIM_TARGETS[f"nbim_ri_{y}"] = {
            "url": f"https://www.nbim.no/en/news-and-insights/reports/{y}/responsible-investment-{y}/",
            "year": y, "institution": "NBIM", "doc_type": "responsible_investment", "language": "en"
        }

def crawl_nbim_doc(doc_id, meta):
    out_path = os.path.join(NBIM_DIR, f"{doc_id}.json")
    if os.path.exists(out_path):
        print(f"  SKIP {doc_id} (cached)")
        return

    print(f"  Fetching {doc_id}...", end="", flush=True)
    html = fetch(meta["url"])
    time.sleep(DELAY)
    if not html:
        print(" FAILED")
        return

    # Extract main content — NBIM uses article/main tags
    main = re.search(r"<main[^>]*>(.*?)</main>", html, re.DOTALL)
    article = re.search(r"<article[^>]*>(.*?)</article>", html, re.DOTALL)
    body = (main or article)
    raw = strip_tags(body.group(1) if body else html)

    # Also try to find sub-pages (CEO letter, chapters)
    sub_links = re.findall(r'href="(/en/news-and-insights/reports/' + meta["year"] + r'/[^"]+)"', html)
    sub_links = [l for l in set(sub_links) if l != meta["url"].replace("https://www.nbim.no", "")]

    sub_texts = []
    for sl in sub_links[:8]:  # max 8 sub-pages per report
        sub_url = "https://www.nbim.no" + sl
        sub_html = fetch(sub_url)
        time.sleep(DELAY)
        if sub_html:
            sm = re.search(r"<main[^>]*>(.*?)</main>", sub_html, re.DOTALL)
            sa = re.search(r"<article[^>]*>(.*?)</article>", sub_html, re.DOTALL)
            sb = (sm or sa)
            sub_text = strip_tags(sb.group(1) if sb else sub_html)
            sub_texts.append({"url": sub_url, "text": sub_text})

    full_text = raw + " " + " ".join(s["text"] for s in sub_texts)
    kws = keyword_match(full_text)

    result = {
        "doc_id": doc_id, **meta,
        "text": raw[:50000],  # cap main page at 50k chars
        "sub_pages": sub_texts,
        "word_count": len(full_text.split()),
        "matched_keywords": kws,
    }
    save_json(result, out_path)
    print(f" {len(full_text.split()):,} words | {len(kws)} keywords matched")

# ── Government white papers ───────────────────────────────────────────────────

# Key Norwegian government documents on energy, climate, petroleum strategy
# These are the most theoretically significant for cross-institutional disavowal
REGJ_TARGETS = {
    "klimaplan_2030": {
        "url": "https://www.regjeringen.no/en/dokumenter/meld.-st.-13-20202021/id2807592/",
        "title": "Climate Plan 2021-2030 (Meld. St. 13, 2020-2021)",
        "year": "2021", "institution": "Regjeringen", "doc_type": "white_paper", "language": "en"
    },
    "energi_til_arbeid": {
        "url": "https://www.regjeringen.no/en/dokumenter/meld.-st.-36-20202021/id2860748/",
        "title": "Energy for Work — Long-term Value Creation from Norwegian Energy Resources (Meld. St. 36, 2020-2021)",
        "year": "2021", "institution": "Regjeringen", "doc_type": "white_paper", "language": "en"
    },
    "petroleum_strategy_2019": {
        "url": "https://www.regjeringen.no/en/dokumenter/meld.-st.-2-20182019/id2631220/",
        "title": "Revised National Budget 2019 (petroleum revenue framework)",
        "year": "2019", "institution": "Regjeringen", "doc_type": "white_paper", "language": "en"
    },
    "power_of_wind": {
        "url": "https://www.regjeringen.no/en/dokumenter/meld.-st.-28-20192020/id2686088/",
        "title": "The Power of Wind (offshore wind strategy)",
        "year": "2020", "institution": "Regjeringen", "doc_type": "white_paper", "language": "en"
    },
    "norsk_klimapolitikk_2012": {
        "url": "https://www.regjeringen.no/no/dokumenter/meld-st-21-2011-2012/id679374/",
        "title": "Norsk klimapolitikk (Meld. St. 21, 2011-2012) — baseline pre-Paris",
        "year": "2012", "institution": "Regjeringen", "doc_type": "white_paper", "language": "no"
    },
    "langtidsplan_petroleum_2024": {
        "url": "https://www.regjeringen.no/no/dokumenter/meld.-st.-9-20232024/id3029085/",
        "title": "Norges petroleumsvirksomhet (Meld. St. 9, 2023-2024)",
        "year": "2024", "institution": "Regjeringen", "doc_type": "white_paper", "language": "no"
    },
    "havvind_2023": {
        "url": "https://www.regjeringen.no/no/dokumenter/meld.-st.-20-20222023/id2975305/",
        "title": "Meld. St. 20 (2022-2023) — Energikommisjonens rapport (A Well-Connected Norway)",
        "year": "2023", "institution": "Regjeringen", "doc_type": "white_paper", "language": "no"
    },
}

def crawl_regj_doc(doc_id, meta):
    out_path = os.path.join(REGJ_DIR, f"{doc_id}.json")
    if os.path.exists(out_path):
        print(f"  SKIP {doc_id} (cached)")
        return

    print(f"  Fetching {doc_id}...", end="", flush=True)
    html = fetch(meta["url"])
    time.sleep(DELAY)
    if not html:
        print(" FAILED")
        return

    # regjeringen.no uses article tags
    article = re.search(r'<div[^>]*class="[^"]*article[^"]*"[^>]*>(.*?)</div>\s*</div>', html, re.DOTALL)
    main    = re.search(r"<main[^>]*>(.*?)</main>", html, re.DOTALL)
    body    = article or main
    raw = strip_tags(body.group(1) if body else html)

    kws = keyword_match(raw)
    result = {
        "doc_id": doc_id, **meta,
        "text": raw[:80000],
        "word_count": len(raw.split()),
        "matched_keywords": kws,
    }
    save_json(result, out_path)
    print(f" {len(raw.split()):,} words | {len(kws)} keywords matched")

# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    print(f"\nPOLARIS Phase 2 Crawler — {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 60)

    print("\n[1] NBIM Annual Reports & Responsible Investment Reports")
    for doc_id, meta in sorted(NBIM_TARGETS.items()):
        crawl_nbim_doc(doc_id, meta)

    print("\n[2] Government White Papers (Regjeringen.no)")
    for doc_id, meta in REGJ_TARGETS.items():
        crawl_regj_doc(doc_id, meta)

    # Build unified CSV
    print("\n[3] Building unified Phase 2 corpus CSV...")
    all_docs = []
    for folder, label in [(NBIM_DIR, "NBIM"), (REGJ_DIR, "Regjeringen")]:
        for fname in sorted(os.listdir(folder)):
            if not fname.endswith(".json"):
                continue
            with open(os.path.join(folder, fname), encoding="utf-8") as f:
                doc = json.load(f)
            all_docs.append({
                "doc_id":           doc.get("doc_id", fname),
                "institution":      doc.get("institution", label),
                "doc_type":         doc.get("doc_type", ""),
                "year":             doc.get("year", ""),
                "title":            doc.get("title", ""),
                "language":         doc.get("language", ""),
                "word_count":       doc.get("word_count", 0),
                "matched_keywords": ", ".join(doc.get("matched_keywords", [])),
                "url":              doc.get("url", ""),
                "text_preview":     doc.get("text", "")[:500],
            })

    out_csv = os.path.join(BASE_DIR, "data", "phase2", "phase2_corpus.csv")
    with open(out_csv, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=list(all_docs[0].keys()) if all_docs else [])
        writer.writeheader()
        writer.writerows(all_docs)

    print(f"  {len(all_docs)} documents → {out_csv}")
    print(f"\nDone: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 60)

if __name__ == "__main__":
    main()
