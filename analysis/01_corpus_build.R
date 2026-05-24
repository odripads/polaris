###############################################################################
# POLARIS Analysis — Script 01: Corpus Build
# Kalcer Institute | Odri | May 2026
#
# Loads all filtered session CSVs, cleans party codes (incl. mixed-case
# FrP/KrF), constructs a combined analysis-ready data frame, and saves it
# as the canonical analysis object used by all downstream scripts.
###############################################################################

library(tidyverse)
library(lubridate)
library(stringr)

# ── Paths ─────────────────────────────────────────────────────────────────────

BASE   <- "/Users/odripads/Desktop/GitHub/ngdc"
PROC   <- file.path(BASE, "data", "processed")
OUT    <- file.path(BASE, "outputs")

# ── Load all filtered CSVs ────────────────────────────────────────────────────

cat("Loading filtered session CSVs...\n")

filtered_files <- list.files(PROC, pattern = "^filtered_.*\\.csv$", full.names = TRUE)

corpus_raw <- map_dfr(filtered_files, function(f) {
  read_csv(f, col_types = cols(.default = "c"), show_col_types = FALSE)
})

cat(sprintf("  Total rows loaded: %s\n", nrow(corpus_raw)))

# ── Party code fix ────────────────────────────────────────────────────────────
# Original crawl regex only matched ALL-CAPS party codes, so FrP and KrF
# were silently pushed into the empty-string bucket. We re-parse here.

fix_party <- function(speaker_name, party_col) {
  # If party already looks valid, keep it
  if (!is.na(party_col) && nchar(party_col) > 0) return(party_col)
  # Ministers and Prime Minister speak in government capacity — flag as Statsråd
  if (str_detect(speaker_name, regex("statsråd|statsminister|statssekretær", ignore_case = TRUE))) {
    return("Statsråd")
  }
  # Presidenten (chair) — flag separately
  if (str_detect(speaker_name, regex("presiden", ignore_case = TRUE))) {
    return("Presidenten")
  }
  # Try case-insensitive extraction from (PartyCode) pattern
  m <- str_match(speaker_name, "\\(([A-Za-zÆØÅæøå\\-]{1,6})\\)")
  if (!is.na(m[1,2])) return(m[1,2])
  return("Unknown")
}

corpus_raw <- corpus_raw %>%
  mutate(
    party = map2_chr(speaker_name, party, fix_party),
    # Standardise capitalisation: FRP → FrP, KRF → KrF
    party = case_when(
      str_to_upper(party) == "FRP"      ~ "FrP",
      str_to_upper(party) == "KRF"      ~ "KrF",
      str_to_upper(party) == "STATSRAD" ~ "Statsråd",
      TRUE                               ~ party
    )
  )

# ── Add derived variables ─────────────────────────────────────────────────────

corpus <- corpus_raw %>%
  mutate(
    # Parse year from session_id
    year_start = as.integer(str_sub(session_id, 1, 4)),
    year_end   = as.integer(str_sub(session_id, 6, 9)),
    # Use the academic year label (e.g., "2016-17")
    session_label = sprintf("%s–%s", year_start, str_sub(as.character(year_end), 3, 4)),
    # Parse date
    date = as.Date(date),
    # word count as numeric
    word_count = as.integer(word_count),
    # extended_only as logical
    extended_only = str_to_lower(extended_only) == "true",
    # party_group: collapse small/uncertain categories
    party_group = case_when(
      party %in% c("A", "Sp")         ~ "Government coalition (A+Sp)",
      party == "H"                     ~ "Conservative (H)",
      party == "FrP"                   ~ "Progress Party (FrP)",
      party %in% c("SV", "R", "MDG")  ~ "Left bloc (SV/R/MDG)",
      party %in% c("V", "KrF")        ~ "Centre (V/KrF)",
      party == "Statsråd"              ~ "Ministers (Statsråd)",
      TRUE                             ~ "Other/Unknown"
    ),
    # Compute per-speech keyword flags (fast string search)
    has_petroleum  = str_detect(str_to_lower(speech_text), "petroleum"),
    has_olje       = str_detect(str_to_lower(speech_text), "\\bolje\\b"),
    has_klima      = str_detect(str_to_lower(speech_text), "klima"),
    has_fornybar   = str_detect(str_to_lower(speech_text), "fornybar"),
    has_barekraft  = str_detect(str_to_lower(speech_text), "bærekraft"),
    has_nbim       = str_detect(str_to_lower(speech_text), "nbim|oljefondet"),
    has_omstilling = str_detect(str_to_lower(speech_text), "omstilling"),
    has_karbonfangst = str_detect(str_to_lower(speech_text), "karbonfangst"),
  )

# ── Session-level summary ─────────────────────────────────────────────────────

session_summary <- corpus %>%
  group_by(session_id, session_label, year_start) %>%
  summarise(
    n_speeches   = n(),
    n_words      = sum(word_count, na.rm = TRUE),
    n_petroleum  = sum(has_petroleum),
    n_klima      = sum(has_klima),
    n_fornybar   = sum(has_fornybar),
    n_barekraft  = sum(has_barekraft),
    n_nbim       = sum(has_nbim),
    n_omstilling = sum(has_omstilling),
    petroleum_klima_ratio = n_petroleum / pmax(n_klima, 1),
    .groups = "drop"
  )

# ── Save ──────────────────────────────────────────────────────────────────────

saveRDS(corpus,          file.path(OUT, "corpus.rds"))
saveRDS(session_summary, file.path(OUT, "session_summary.rds"))
write_csv(corpus,          file.path(OUT, "tables", "corpus_full.csv"))
write_csv(session_summary, file.path(OUT, "tables", "session_summary.csv"))

cat(sprintf("\nCorpus built: %s speeches across %s sessions\n",
            nrow(corpus), n_distinct(corpus$session_id)))
cat(sprintf("Sessions: %s\n", paste(sort(unique(corpus$session_id)), collapse = ", ")))
cat(sprintf("Parties: %s\n", paste(sort(unique(corpus$party)), collapse = ", ")))
cat("\nSession summary:\n")
print(session_summary %>% select(session_label, n_speeches, n_petroleum, n_klima, petroleum_klima_ratio))
cat("\nSaved: outputs/corpus.rds, outputs/session_summary.rds\n")
