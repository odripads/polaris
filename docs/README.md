# Norwegian Green Discourse Corpus (NGDC)

**Kalcer Institute** | Odri | v1.0 | May 2026

---

## Overview

The **Norwegian Green Discourse Corpus (NGDC)** is a structured, documented, and publicly releasable corpus of Norwegian parliamentary discourse on energy, petroleum, and climate transition — curated for the study of **ideological disavowal**.

The corpus is both a research tool and a publishable research object in its own right. It is designed to support discourse-analytic, computational, and mixed-methods research on how states simultaneously perform green identities while sustaining extractive economies.

The NGDC follows the model established by Prof. Slava Jankin (Hertie School / University of Birmingham) with the [UN General Debate Corpus](https://github.com/sjankin) — a transparent, reusable, publicly documented research object. The README and curation logic constitute the intellectual contribution; the corpus is its empirical evidence.

---

## Theoretical Motivation

### The Thesis

Norway presents itself globally as a climate leader and pioneer of sustainable development. It is simultaneously one of the world's largest petroleum exporters. This paradox is not a contradiction that requires resolution — it is the ideology functioning exactly as designed.

The theoretical framework is **disavowal** (*Verleugnung*) in the Lacanian-Žižekian sense: the structure of *"I know very well, but nevertheless..."* Norway knows it is a petrostate; nevertheless, it performs the identity of a responsible green actor. The performance is not hypocrisy — it is how the ideology works.

To show that disavowal is not an individual rhetorical choice but a **structural feature of Norwegian state discourse**, it must be demonstrated across many documents, speakers, and institutions — not just in one speech. That requires a corpus.

### The Paris Agreement as Theoretical Hinge

The corpus begins in 2016 (the year of Paris Agreement ratification). This is the moment Norway formally committed to a green identity while structurally accelerating petroleum extraction. Disavowal becomes most visible after a public commitment is made — the gap between stated identity and material practice is now official, measurable, and must be actively managed in language.

### Cross-Institutional Scope

The NGDC covers three institutional sites of disavowal:

| Institution | Source | Role in corpus |
|---|---|---|
| Stortinget (Parliament) | Plenary debate transcripts | Primary corpus — where the official subject speaks for the record |
| NBIM (Government Pension Fund Global) | Annual reports, Responsible Investment reports | Secondary corpus — where petroleum money performs its green identity |
| Regjeringen (Government) | White papers on energy and climate | Secondary corpus — where policy intention is formally stated |

The cross-institutional design allows demonstration that disavowal is not a property of individual speakers but of the **institutional apparatus as a whole**.

---

## Corpus Structure

```
ngdc/
├── data/
│   ├── raw/                    ← Full XML transcripts from Stortinget API (one file per meeting)
│   ├── processed/              ← Cleaned CSV files (one per session)
│   │   ├── speeches_YYYY_YYYY.csv   ← All extracted speeches
│   │   └── filtered_YYYY_YYYY.csv  ← Keyword-matched speeches only
│   └── phase2/
│       ├── nbim/               ← NBIM report texts (JSON, one per document)
│       └── phase2_corpus.csv   ← Unified Phase 2 index
├── docs/
│   ├── README.md               ← This document
│   └── codebook.md             ← Variable definitions
└── scripts/
    ├── crawl_session.py        ← Crawl a single Stortinget session
    ├── crawl_all_sessions.py   ← Crawl all sessions (2016–2025)
    └── crawl_phase2.py         ← Crawl NBIM and government documents
```

---

## Phase 1: Stortinget Plenary Corpus

### Source

The Norwegian Parliament (Stortinget) provides a public, free, unauthenticated API at `https://data.stortinget.no`. The API returns structured XML data on plenary meetings, speeches, cases, votes, and hearings.

### Why Plenary Debates, Not Hearings

The API distinguishes between *høringer* (committee hearings — civil society speaking *to* parliament) and *stortingsmøter* (plenary debates — MPs speaking *on the record* for the state). We collect plenary debates exclusively. This is where the official subject speaks, where the fantasy of the responsible petrostate gets narrated, and where disavowal is most structurally visible.

### Temporal Scope

| Parameter | Value | Rationale |
|---|---|---|
| Start | 2016–2017 session | Paris Agreement ratified October 2016 |
| End | 2024–2025 session | Current session at time of collection |
| Note | 2015–2016 session returned no transcript data via API | API limitation |

### Corpus Scale

| Session | Total speeches | Keyword-matched |
|---|---|---|
| 2016–2017 | ~12,600 | 1,768 |
| 2017–2018 | ~11,200 | 1,510 |
| 2018–2019 | ~11,970 | 1,867 |
| 2019–2020 | ~10,130 | 1,701 |
| 2020–2021 | ~13,420 | 1,782 |
| 2021–2022 | ~10,430 | 1,714 |
| 2022–2023 | ~11,450 | 1,699 |
| 2023–2024 | ~10,430 | 1,528 |
| 2024–2025 | ~11,410 | 1,641 |
| **TOTAL** | **~103,000** | **15,210** |

### Keyword Filter (Curation Logic)

The keyword filter is the **intellectual core** of the corpus. These are not merely topical categories — they are the discursive sites where green identity and extractivism collide. Inclusion in the filtered corpus means a speech participates in the ideological terrain of disavowal, whether in affirmation, critique, or deflection.

**Core keywords** (trigger inclusion; flagged as primary):

| Norwegian | English gloss | Theoretical function |
|---|---|---|
| `petroleum` | petroleum | Direct naming of the extractive industry |
| `olje` | oil | Colloquial term; often softer register than *petroleum* |
| `klimaendring` / `klima` | climate change / climate | Green identity claim |
| `energiomstilling` | energy transition | Technocratic disavowal vocabulary |
| `fornybar energi` / `fornybar` | renewable energy | Substitution frame |
| `bærekraft` | sustainability | ESG/green identity |
| `Oljefondet` / `NBIM` | the Oil Fund | The primary institutional site of laundered identity |

**Extended keywords** (trigger inclusion; flagged as `extended_only`):

| Norwegian | English gloss | Theoretical function |
|---|---|---|
| `grønn vekst` | green growth | Managed-transition vocabulary; disavowal via economics |
| `karbonfangst` | carbon capture | Techno-fix frame; enables continued extraction |
| `rettferdig omstilling` | just transition | Social-democratic disavowal; softens extractivism |

Extended keywords are included but flagged separately (`extended_only = True`). They capture the more recent technocratic vocabulary of managed transition, which is itself a disavowal formation — the extraction continues, but now it is *managed justly*.

### What Is Excluded

- Committee submissions (*høringsinnspill*) — Phase 2 only
- Speeches under 80 words from the chair (*Presidenten*) — procedural, not substantive
- Speeches not matching any keyword — irrelevant to the thematic corpus

**Opposition speeches are included.** Disavowal is cross-partisan in Norway. The structural position, not the party, generates the ideological form.

### Speech Types

| Type | Norwegian | Description |
|---|---|---|
| `Hovedinnlegg` | Main speech | Formal, allocated time — most substantive |
| `Presinnlegg` | Short speech | Brief floor interventions |
| `Replikk` | Reply | Responses to other speakers; often more unguarded |

*Muntlig spørretime* (Oral Question Time) generates the most speeches in the corpus (3,707) and is theoretically the richest site — unscripted exchanges where the fantasy must be maintained under adversarial pressure.

---

## Phase 2: Cross-Institutional Secondary Corpus

### NBIM (Government Pension Fund Global)

Annual reports and Responsible Investment reports, 2015–2024, collected from `nbim.no`. The fund is the primary institutional site where petroleum revenues are detached from their origin and re-narrated as long-term, responsible, globally diversified capital. The Responsible Investment reports, which deploy the densest ESG/climate vocabulary, are the most theoretically charged documents.

**Key finding from cross-institutional frequency analysis:**
NBIM uses "carbon neutral / net zero" at 20× the rate of parliament, and "responsible" at 5× the rate. Crucially, NBIM uses the word "extraction" at approximately zero frequency — the source of the fund's wealth is structurally absent from its own self-description. Parliament names petroleum more frequently than the fund that exists because of it.

### Government White Papers

Key *Meldinger til Stortinget* on energy and climate policy. Access via direct scraping was blocked by regjeringen.no at time of collection; the parliamentary debate transcripts on these documents (already included in Phase 1) are available in the corpus and constitute a richer record of how disavowal is performed in response to stated policy.

---

## Key Empirical Findings

### The Petroleum/Klima Ratio

The ratio of *klima* mentions to *petroleum* mentions in parliamentary speech has increased from 9.9:1 (2016) to 13.5:1 (2024). As Norway's petroleum extraction has continued or increased, the word "petroleum" has been spoken *less* in parliament while "klima" has remained constant or grown. This is disavowal operating at the level of language: the thing is present in practice; its name is progressively absent from discourse.

### Cross-Partisan Consistency

Match rates are stable across all sessions (13–17%), regardless of which party or coalition holds government. Disavowal is not a property of a particular party — it is a property of the institutional position of the Norwegian state in the global energy system.

### Top Speakers

The highest-frequency speaker in the corpus is **Terje Aasland**, Minister of Petroleum *and* Energy (2021–present). The same office that oversees petroleum extraction is also the primary speaker in parliamentary discourse about climate transition. The disavowal is not merely discursive — it is embodied in the institutional structure of the ministry itself.

---

## Reproducibility

All scripts are commented and publicly available in `/scripts/`. The corpus can be fully regenerated from the Stortinget public API with no authentication required. Rate limit: 100 calls/minute; scripts enforce a 0.7-second delay between calls.

**Dependencies:**
- Python 3.8+
- Standard library only (no external packages required for crawling)
- `csv`, `xml.etree.ElementTree`, `urllib.request`, `re`, `json`

**To reproduce:**
```bash
# Clone repository
git clone https://github.com/[odripads]/ngdc.git
cd ngdc

# Crawl all sessions (takes ~90 minutes)
python3 scripts/crawl_all_sessions.py

# Crawl Phase 2 sources
python3 scripts/crawl_phase2.py
```

---

## Citation

If you use this corpus, please cite:

> Kalcer Institute (2026). *Norwegian Green Discourse Corpus (NGDC), v1.0*. [Data set]. https://github.com/[odripads]/ngdc

---

## Contact

Odri / Kalcer Institute
[kalcerinstitute.com](https://kalcerinstitute.com)
