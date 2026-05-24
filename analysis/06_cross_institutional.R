###############################################################################
# NGDC Analysis — Script 06: Cross-Institutional Comparison (Phase 1 + Phase 2)
# Kalcer Institute | Odri | May 2026
#
# Compares Parliament (Phase 1) vs NBIM (Phase 2) on key vocabulary rates.
# The theoretical claim: NBIM performs green identity at 20x the rate of
# parliament while completely suppressing the word "extraction".
# Parliament names petroleum more than the fund it created.
###############################################################################

library(tidyverse)
library(scales)
library(patchwork)

BASE  <- "/Users/odripads/Desktop/GitHub/ngdc"
OUT_F <- file.path(BASE, "outputs", "figures")
OUT_T <- file.path(BASE, "outputs", "tables")

# ── Load Phase 2 NBIM data ────────────────────────────────────────────────────

nbim_dir <- file.path(BASE, "data", "phase2", "nbim")

nbim_docs <- list.files(nbim_dir, pattern = "\\.json$", full.names = TRUE) %>%
  map_dfr(function(f) {
    doc <- jsonlite::fromJSON(f, simplifyVector = TRUE)
    tibble(
      doc_id    = doc$doc_id,
      year      = as.integer(doc$year),
      doc_type  = doc$doc_type,
      language  = doc$language,
      word_count = doc$word_count,
      text      = if (!is.null(doc$text)) doc$text else ""
    )
  })

cat(sprintf("Loaded %d NBIM documents\n", nrow(nbim_docs)))

# Only use content-rich documents (2022-2024)
nbim_rich <- nbim_docs %>% filter(word_count > 5000, !is.na(text), nchar(text) > 500)
cat(sprintf("  Content-rich (>5k words): %d documents\n", nrow(nbim_rich)))

# ── Compute term rates for NBIM ───────────────────────────────────────────────

count_per_10k <- function(text, pattern) {
  total_words <- length(str_split(text, "\\s+")[[1]])
  if (total_words < 100) return(NA_real_)
  hits <- str_count(str_to_lower(text), pattern)
  hits / total_words * 10000
}

nbim_rates <- nbim_rich %>%
  mutate(
    rate_carbon_neutral = map_dbl(text, ~count_per_10k(.x, "carbon neutral|net.zero")),
    rate_responsible    = map_dbl(text, ~count_per_10k(.x, "responsible")),
    rate_divestment     = map_dbl(text, ~count_per_10k(.x, "divest")),
    rate_balance        = map_dbl(text, ~count_per_10k(.x, "\\bbalance\\b")),
    rate_petroleum      = map_dbl(text, ~count_per_10k(.x, "petroleum")),
    rate_extraction     = map_dbl(text, ~count_per_10k(.x, "extract")),
    rate_oil            = map_dbl(text, ~count_per_10k(.x, "\\boil\\b")),
    rate_climate        = map_dbl(text, ~count_per_10k(.x, "climate")),
    rate_sustainable    = map_dbl(text, ~count_per_10k(.x, "sustain"))
  )

# ── Compute same rates for Parliament ─────────────────────────────────────────
# Use ALL speeches text from filtered corpus (Phase 1)

corpus_df <- readRDS(file.path(BASE, "outputs", "corpus.rds"))

parl_text <- paste(corpus_df$speech_text, collapse = " ")

parl_rates_single <- tibble(
  institution = "Parliament (Phase 1)",
  rate_carbon_neutral = count_per_10k(parl_text, "karbon.?nøytral|netto.?null|carbon.?neutral|net.?zero"),
  rate_responsible    = count_per_10k(parl_text, "ansvarlig|responsible"),
  rate_divestment     = count_per_10k(parl_text, "divest|frasalg"),
  rate_balance        = count_per_10k(parl_text, "balanse|\\bbalance\\b"),
  rate_petroleum      = count_per_10k(parl_text, "petroleum"),
  rate_extraction     = count_per_10k(parl_text, "utvinning|extract"),
  rate_oil            = count_per_10k(parl_text, "\\bolje\\b"),
  rate_climate        = count_per_10k(parl_text, "klima"),
  rate_sustainable    = count_per_10k(parl_text, "bærekraft|sustain")
)

# NBIM aggregate (mean of rich docs)
nbim_agg <- nbim_rates %>%
  summarise(across(starts_with("rate_"), ~mean(.x, na.rm = TRUE))) %>%
  mutate(institution = "NBIM (Phase 2)") %>%
  relocate(institution)

# ── Combine and compare ───────────────────────────────────────────────────────

comparison <- bind_rows(parl_rates_single, nbim_agg) %>%
  pivot_longer(starts_with("rate_"), names_to = "term", values_to = "rate_per_10k") %>%
  mutate(
    term = recode(term,
      rate_carbon_neutral = "carbon neutral / net zero",
      rate_responsible    = "responsible",
      rate_divestment     = "divestment",
      rate_balance        = "balance",
      rate_petroleum      = "petroleum",
      rate_extraction     = "extraction",
      rate_oil            = "oil / olje",
      rate_climate        = "climate / klima",
      rate_sustainable    = "sustainable / bærekraft"
    )
  )

write_csv(comparison, file.path(OUT_T, "cross_institutional_rates.csv"))

# ── Plot: side-by-side bar chart ──────────────────────────────────────────────

inst_colors <- c("Parliament (Phase 1)" = "#2C3E50", "NBIM (Phase 2)" = "#27AE60")

# Pivot wide for ratio calculation
comparison_wide <- comparison %>%
  pivot_wider(names_from = institution, values_from = rate_per_10k) %>%
  rename(parliament = `Parliament (Phase 1)`, nbim = `NBIM (Phase 2)`) %>%
  mutate(nbim_vs_parl = nbim / pmax(parliament, 0.01))

write_csv(comparison_wide, file.path(OUT_T, "cross_institutional_ratios.csv"))

p_cross <- comparison %>%
  mutate(
    term = fct_reorder(term, rate_per_10k, .fun = max),
    rate_per_10k = round(rate_per_10k, 2)
  ) %>%
  ggplot(aes(x = term, y = rate_per_10k, fill = institution)) +
  geom_col(position = "dodge") +
  scale_fill_manual(values = inst_colors) +
  coord_flip() +
  labs(
    title    = "Key term rates: Parliament vs NBIM",
    subtitle = "Rate per 10,000 words | NGDC Phase 1 + Phase 2",
    x = NULL, y = "Rate per 10,000 words",
    fill     = NULL,
    caption  = "NGDC | Kalcer Institute, 2026"
  ) +
  theme_minimal(base_family = "Helvetica", base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 11, color = "#444444"),
    legend.position = "bottom",
    panel.grid.minor = element_blank()
  )

ggsave(file.path(OUT_F, "fig17_cross_institutional.png"),
       p_cross, width = 11, height = 7, dpi = 200, bg = "white")

# ── Ratio plot: NBIM vs Parliament ────────────────────────────────────────────

p_ratio <- comparison_wide %>%
  mutate(term = fct_reorder(term, nbim_vs_parl)) %>%
  ggplot(aes(x = term, y = nbim_vs_parl)) +
  geom_col(aes(fill = nbim_vs_parl > 1)) +
  scale_fill_manual(values = c("TRUE" = "#27AE60", "FALSE" = "#C0392B"),
                    labels = c("TRUE" = "NBIM higher", "FALSE" = "Parliament higher")) +
  geom_hline(yintercept = 1, linetype = "dashed") +
  geom_text(aes(label = sprintf("%.1fx", nbim_vs_parl)), hjust = -0.1, size = 3.5) +
  coord_flip() +
  scale_y_log10(labels = scales::label_number(suffix = "x")) +
  labs(
    title    = "NBIM vs Parliament: relative term rates",
    subtitle = "How many times more frequent is each term in NBIM vs Parliament?\n> 1x = NBIM uses it more; < 1x = Parliament uses it more",
    x = NULL, y = "NBIM rate ÷ Parliament rate (log scale)",
    fill     = NULL,
    caption  = "NGDC | Kalcer Institute, 2026"
  ) +
  theme_minimal(base_family = "Helvetica", base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "bottom",
    panel.grid.minor = element_blank()
  )

ggsave(file.path(OUT_F, "fig18_institutional_ratios.png"),
       p_ratio, width = 10, height = 7, dpi = 200, bg = "white")

cat("\nCross-institutional analysis complete.\n")
cat("\nComparison table:\n")
print(comparison_wide %>% mutate(across(where(is.numeric), ~round(., 2))))
