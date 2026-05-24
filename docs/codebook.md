# POLARIS Codebook — Variable Definitions

**POLARIS Corpus (Parliamentary Oil, Legitimacy And Renewables In Stortinget)** | Kalcer Institute | v1.0 | May 2026

This codebook defines all variables in the POLARIS processed data files. It covers Phase 1 (Stortinget plenary corpus) and Phase 2 (NBIM and government document corpus).

---

## Phase 1: Stortinget Plenary Corpus

### Files

| File | Description |
|---|---|
| `data/processed/speeches_YYYY_YYYY.csv` | All extracted speeches for a session, including non-matched |
| `data/processed/filtered_YYYY_YYYY.csv` | Keyword-matched speeches only — the working corpus |

### Variable Definitions

| Variable | Type | Description | Example |
|---|---|---|---|
| `session_id` | string | Parliamentary session in `YYYY-YYYY` format | `2022-2023` |
| `date` | string | Date of the meeting (ISO 8601: YYYY-MM-DD) | `2022-10-04` |
| `referat_id` | string | Unique transcript identifier from Stortinget API | `refs-202223-10-04` |
| `case_id` | string | Case (*sak*) identifier from Stortinget API; `0` if no case structure | `89667` |
| `case_title` | string | Full title of the case being debated | `Innstilling fra energi- og miljøkomiteen om...` |
| `speech_type` | string | Type of speech intervention (see Speech Types below) | `Hovedinnlegg` |
| `speaker_name` | string | Speaker's full name and party abbreviation as recorded in transcript | `Terje Aasland (A)` |
| `party` | string | Party abbreviation extracted from speaker name field (see Party Codes below) | `A` |
| `word_count` | integer | Number of words in the speech text | `342` |
| `matched_keywords` | string | Comma-separated list of keywords triggering inclusion | `petroleum, klima, fornybar` |
| `extended_only` | boolean | `True` if speech matched only extended keywords (not core); `False` otherwise | `False` |
| `speech_text` | string | Full speech text in Norwegian original (not translated) | `Presidenten har gitt ordet til...` |

### Speech Types (`speech_type`)

| Value | Norwegian | Description |
|---|---|---|
| `Hovedinnlegg` | Main speech | Formal floor speech with allocated time; most substantive intervention |
| `Presinnlegg` | Short speech | Brief unallocated floor intervention |
| `Replikk` | Reply / rebuttal | Direct response to a preceding speaker; often less scripted |

### Party Codes (`party`)

Norwegian parliamentary parties represented in the corpus:

| Code | Party (Norwegian) | Party (English) | Political position |
|---|---|---|---|
| `A` | Arbeiderpartiet | Labour Party | Centre-left |
| `H` | Høyre | Conservative Party | Centre-right |
| `SV` | Sosialistisk Venstreparti | Socialist Left Party | Left |
| `FrP` | Fremskrittspartiet | Progress Party | Right-populist; explicitly pro-petroleum |
| `Sp` | Senterpartiet | Centre Party | Agrarian/Centre; in government coalition with A post-2021 |
| `V` | Venstre | Liberal Party | Centre; green liberal |
| `MDG` | Miljøpartiet De Grønne | Green Party | Green/ecologist |
| `R` | Rødt | Red Party | Far-left; critical of petroleum industry |
| `KrF` | Kristelig Folkeparti | Christian Democratic Party | Centre-right |
| `Statsråd` | — | Minister (government) | Speaks as government, not party representative |

**Note on `Statsråd`**: Ministers (*statsråd*) and the Prime Minister (*statsminister*) speak in their official government capacity. Their speeches are not assigned to a party in the transcript. This is theoretically significant — the state apparatus speaks as a unified subject, dissolving the partisan voice into the governmental one. Ministerial speeches account for ~26% of the filtered corpus.

**Note on `Ukjent` / `Unknown`**: A small number of speeches (~2%) could not be assigned a speaker name or party due to formatting irregularities in the source XML. These are retained in the corpus but flagged.

### Data Quality Notes

- **Speech text is Norwegian original**. No translation has been applied. The ideological texture of disavowal is language-specific and must be read in Norwegian.
- **Speaker names include timestamps**: The raw Stortinget XML encodes speech start times within the `<Navn>` tag (e.g., `Terje Aasland [11:34:12]`). These have been stripped from the `speaker_name` field for cleanliness but are preserved in the raw XML files under `data/raw/`.
- **Word counts are approximate**: Based on whitespace tokenisation of stripped plain text. Sufficient for filtering and frequency analysis; not suitable for precise linguistic word-count research without re-tokenisation.
- **One meeting timed out** during collection (`refs-202223-06-16`): This meeting is absent from the 2022–2023 session data. Its absence is not theoretically significant.
- **2015–2016 session**: The Stortinget API returned no transcript data for this session. The corpus formally begins with 2016–2017 (October 2016 — the month of Paris Agreement ratification by Norway).

---

## Phase 2: Cross-Institutional Secondary Corpus

### Files

| File | Description |
|---|---|
| `data/phase2/nbim/*.json` | Individual NBIM document records (19 documents, 2015–2024) |
| `data/phase2/phase2_corpus.csv` | Unified index of all Phase 2 documents |

### Phase 2 CSV Variables

| Variable | Type | Description | Example |
|---|---|---|---|
| `doc_id` | string | Unique document identifier | `nbim_ri_2023` |
| `institution` | string | Issuing institution | `NBIM` |
| `doc_type` | string | Document type (see Document Types below) | `responsible_investment` |
| `year` | string | Publication year | `2023` |
| `title` | string | Document title | `Responsible Investment 2023` |
| `language` | string | Primary language of document (`en` or `no`) | `en` |
| `word_count` | integer | Approximate word count of collected text | `20937` |
| `matched_keywords` | string | Comma-separated matched keywords | `climate, oil, transition` |
| `url` | string | Source URL | `https://www.nbim.no/...` |
| `text_preview` | string | First 500 characters of document text | — |

### Document Types (`doc_type`)

| Value | Description | Theoretical significance |
|---|---|---|
| `annual_report` | NBIM annual financial report | Financial performance narrative; how petroleum returns are framed |
| `responsible_investment` | NBIM responsible investment / ESG report | Primary site of green identity performance; densest ESG vocabulary |
| `white_paper` | Norwegian government *Melding til Stortinget* | Formal policy intention; where disavowal is institutionally codified |

### NBIM Collection Notes

- **2022–2024 reports** are content-rich (18,000–40,000 words each): the NBIM website served full HTML content for these years.
- **2015–2021 reports** are index-only (200–1,000 words): NBIM's older pages are JavaScript-rendered and returned only navigation/metadata. Raw PDFs for these years are available at `nbim.no` but were not automatically collected. Manual PDF collection recommended for close reading of pre-2022 NBIM documents.
- **Responsible Investment reports** are theoretically the most charged documents: they deploy climate/ESG vocabulary at the highest density while managing the tension between the fund's petroleum-revenue origin and its stated long-term stewardship mission.

### Cross-Institutional Frequency Findings

Key term frequency rates per 10,000 words (from analysis of 2022–2024 data):

| Term | NBIM rate | Parliament rate | Interpretation |
|---|---|---|---|
| `carbon neutral / net zero` | 6.9 | 0.3 | NBIM performs green identity 20× more intensely |
| `responsible` | 9.8 | 1.9 | NBIM's self-legitimating vocabulary |
| `divestment` | 9.6 | ~0 | NBIM-specific disavowal mechanism |
| `balance` | 14.9 | 1.9 | Bridging term; holds contradiction without resolving it |
| `petroleum` | 0.5 | 2.0 | Parliament names it more than the fund it created |
| `extraction` | ~0 | 1.8 | Structurally absent from NBIM vocabulary |

---

## Keyword Reference

### Core Keywords (Norwegian)

| Keyword | English gloss | Rationale |
|---|---|---|
| `petroleum` | petroleum | Direct industry term; declining use = disavowal signal |
| `olje` | oil | Colloquial; note softer register vs *petroleum* |
| `klimaendring` | climate change | Full compound; more formal/scientific register |
| `klima` | climate | High-frequency; spans climate crisis, climate policy, climate identity |
| `energiomstilling` | energy transition | Post-2020 technocratic vocabulary; managed-transition frame |
| `fornybar energi` | renewable energy | Full compound |
| `fornybar` | renewable | Shortened form; captured separately to avoid missed matches |
| `bærekraft` | sustainability | Broad ESG/green identity term |
| `Oljefondet` | the Oil Fund | Capitalised proper noun; the fund's popular name, which names its origin |
| `NBIM` | NBIM (Norges Bank Investment Management) | Institutional name for same fund |

### Extended Keywords (Norwegian)

| Keyword | English gloss | Theoretical note |
|---|---|---|
| `grønn vekst` | green growth | Economic frame; disavowal via capitalism — growth can be green |
| `karbonfangst` | carbon capture | Techno-fix; enables continued extraction by promising future remedy |
| `rettferdig omstilling` | just transition | Social-democratic frame; softens extractivism with welfare language |

### English Keywords (Phase 2 / NBIM)

| Keyword | Rationale |
|---|---|
| `climate` | Core green identity claim |
| `oil` | Direct naming of petroleum |
| `petroleum` | Formal industry term |
| `transition` | Managed-change vocabulary |
| `sustainable` / `sustainability` | ESG/green identity |
| `renewable` | Substitution frame |
| `carbon neutral` / `net zero` | Technocratic green commitment |
| `responsible` | NBIM self-legitimating vocabulary |
| `fossil` | Often used in divestment context |
| `emission` | Technical climate vocabulary |
| `green` | Broad identity marker |
| `divestment` | NBIM-specific disavowal mechanism |

---

## Reproducibility Checklist

- [x] All source URLs documented
- [x] All curation decisions documented with theoretical rationale
- [x] All scripts commented and publicly available
- [x] No authentication required for primary data collection (Stortinget API is open)
- [x] Rate limiting respected (0.7s delay; within 100 calls/minute limit)
- [x] Speech texts preserved in Norwegian original (no translation)
- [x] Raw XML files preserved in `data/raw/` for independent reanalysis

---

*Kalcer Institute | kalcerinstitute.com*
