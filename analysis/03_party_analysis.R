###############################################################################
# POLARIS Analysis — Script 03: Party-Level Comparison
# Kalcer Institute | Odri | May 2026
#
# Theoretical claim: disavowal is cross-partisan — it is a property of the
# structural position of the Norwegian state, not of individual parties.
# This script tests that claim: do all parties show similar vocabulary rates?
###############################################################################

library(tidyverse)
library(scales)
library(ggrepel)
library(forcats)

BASE  <- "/Users/odripads/Desktop/GitHub/ngdc"
OUT_F <- file.path(BASE, "outputs", "figures")
OUT_T <- file.path(BASE, "outputs", "tables")

corpus <- readRDS(file.path(BASE, "outputs", "corpus.rds"))

theme_ngdc <- function() {
  theme_minimal(base_family = "Helvetica", base_size = 12) +
    theme(
      plot.title    = element_text(size = 14, face = "bold", margin = margin(b = 6)),
      plot.subtitle = element_text(size = 11, color = "#444444", margin = margin(b = 12)),
      plot.caption  = element_text(size = 9, color = "#888888", hjust = 0),
      panel.grid.minor = element_blank(),
      legend.position = "none"
    )
}

# ── Keep only parties with meaningful N ───────────────────────────────────────

party_n <- corpus %>% count(party)
major_parties <- party_n %>% filter(n >= 50) %>% pull(party)

party_colors <- c(
  "A"        = "#D73E3E",   # Labour red
  "H"        = "#0070B8",   # Conservative blue
  "FrP"      = "#003580",   # Progress dark blue
  "Sp"       = "#2B8B2B",   # Centre green
  "SV"       = "#CC0000",   # Socialist Left
  "MDG"      = "#5DAC44",   # Green
  "R"        = "#8B0000",   # Red
  "V"        = "#00A651",   # Liberal green
  "KrF"      = "#FFAD00",   # Christian Democrat amber
  "Statsråd" = "#555555"    # Minister grey
)

# ── 1. Speeches per party (overall) ──────────────────────────────────────────

p5 <- corpus %>%
  filter(party %in% major_parties) %>%
  count(party) %>%
  mutate(party = fct_reorder(party, n)) %>%
  ggplot(aes(x = party, y = n, fill = party)) +
  geom_col() +
  scale_fill_manual(values = party_colors) +
  coord_flip() +
  labs(
    title    = "Keyword-matched speeches by party, 2016–2025",
    subtitle = "Total corpus N = 15,210 | Major parties only (N ≥ 50 speeches)",
    x = NULL, y = "Speech count",
    caption  = "POLARIS | Kalcer Institute, 2026"
  ) +
  theme_ngdc()

# ── 2. Vocabulary rates by party (per 100 speeches) ──────────────────────────

party_vocab <- corpus %>%
  filter(party %in% major_parties) %>%
  group_by(party) %>%
  summarise(
    n_total        = n(),
    rate_petroleum = mean(has_petroleum) * 100,
    rate_klima     = mean(has_klima) * 100,
    rate_fornybar  = mean(has_fornybar) * 100,
    rate_barekraft = mean(has_barekraft) * 100,
    rate_nbim      = mean(has_nbim) * 100,
    rate_omstilling = mean(has_omstilling) * 100,
    .groups = "drop"
  )

write_csv(party_vocab, file.path(OUT_T, "party_vocabulary_rates.csv"))

vocab_long <- party_vocab %>%
  pivot_longer(starts_with("rate_"), names_to = "term", values_to = "rate_per_100") %>%
  mutate(term = recode(term,
    rate_petroleum  = "petroleum",
    rate_klima      = "klima",
    rate_fornybar   = "fornybar",
    rate_barekraft  = "bærekraft",
    rate_nbim       = "NBIM/Oljefondet",
    rate_omstilling = "omstilling"
  ))

p6 <- vocab_long %>%
  filter(term %in% c("petroleum", "klima")) %>%
  ggplot(aes(x = fct_reorder(party, rate_per_100, .fun = max), y = rate_per_100, fill = party)) +
  geom_col() +
  scale_fill_manual(values = party_colors) +
  facet_wrap(~term, scales = "free_x") +
  coord_flip() +
  labs(
    title    = "Vocabulary rates by party: 'petroleum' vs 'klima'",
    subtitle = "% of each party's corpus speeches containing the term",
    x = NULL, y = "% of speeches",
    caption  = "POLARIS | Kalcer Institute, 2026"
  ) +
  theme_ngdc()

# ── 3. Petroleum/Klima ratio by party ─────────────────────────────────────────

p7 <- party_vocab %>%
  mutate(
    ratio = rate_petroleum / pmax(rate_klima, 0.01),
    party = fct_reorder(party, ratio)
  ) %>%
  ggplot(aes(x = party, y = ratio, fill = party)) +
  geom_col() +
  geom_hline(yintercept = mean(party_vocab$rate_petroleum / pmax(party_vocab$rate_klima, 0.01)),
             linetype = "dashed", color = "#888888") +
  scale_fill_manual(values = party_colors) +
  coord_flip() +
  labs(
    title    = "Petroleum/Klima ratio by party",
    subtitle = "If disavowal is structural, ratios should be similar across parties\nDashed line = corpus mean",
    x = NULL, y = "Ratio (petroleum rate ÷ klima rate)",
    caption  = "POLARIS | Kalcer Institute, 2026"
  ) +
  theme_ngdc()

# ── 4. Scatter: each party's petroleum vs klima rate ─────────────────────────
# Theoretically: if disavowal is cross-partisan, all parties should cluster
# similarly. FrP should be the outlier (pro-petroleum, less green identity).

p8 <- party_vocab %>%
  filter(party %in% major_parties) %>%
  ggplot(aes(x = rate_klima, y = rate_petroleum, color = party, size = n_total)) +
  geom_point(alpha = 0.85) +
  geom_label_repel(aes(label = party), size = 3.5, show.legend = FALSE,
                   min.segment.length = 0.2) +
  scale_color_manual(values = party_colors) +
  scale_size_continuous(name = "N speeches", range = c(3, 10)) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "#CCCCCC") +
  labs(
    title    = "Party positions in petroleum–klima vocabulary space",
    subtitle = "Each point = one party; size = corpus share\nDiagonal = equal rates. Above diagonal: more petroleum than klima",
    x = "klima speech rate (%)", y = "petroleum speech rate (%)",
    caption  = "POLARIS | Kalcer Institute, 2026"
  ) +
  theme_minimal(base_family = "Helvetica", base_size = 12) +
  theme(
    plot.title    = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(size = 11, color = "#444444"),
    plot.caption  = element_text(size = 9, color = "#888888", hjust = 0),
    legend.position = "right"
  )

# ── 5. Temporal trend by party (petroleum rate) ───────────────────────────────

party_time <- corpus %>%
  filter(party %in% c("A", "H", "FrP", "SV", "MDG", "Sp", "Statsråd")) %>%
  group_by(party, year_start) %>%
  summarise(
    n          = n(),
    rate_petro = mean(has_petroleum) * 100,
    rate_klima = mean(has_klima) * 100,
    .groups    = "drop"
  ) %>%
  filter(n >= 10)  # suppress noisy small-N cells

p9 <- party_time %>%
  ggplot(aes(x = year_start, y = rate_petro, color = party, group = party)) +
  geom_line(linewidth = 0.9) +
  geom_point(size = 2) +
  scale_color_manual(values = party_colors) +
  scale_x_continuous(breaks = 2016:2024) +
  labs(
    title    = "Petroleum mention rate by party over time",
    subtitle = "% of each party's speeches mentioning 'petroleum' — declining across all parties",
    x = "Session start year", y = "% of speeches mentioning 'petroleum'",
    color    = "Party",
    caption  = "POLARIS | Kalcer Institute, 2026"
  ) +
  theme_minimal(base_family = "Helvetica", base_size = 12) +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(size = 11, color = "#444444"),
    panel.grid.minor = element_blank(),
    legend.position = "right"
  )

# ── Save ──────────────────────────────────────────────────────────────────────

ggsave(file.path(OUT_F, "fig05_party_speech_counts.png"),
       p5, width = 9, height = 6, dpi = 200, bg = "white")
ggsave(file.path(OUT_F, "fig06_party_vocab_rates.png"),
       p6, width = 11, height = 6, dpi = 200, bg = "white")
ggsave(file.path(OUT_F, "fig07_party_petro_klima_ratio.png"),
       p7, width = 9, height = 6, dpi = 200, bg = "white")
ggsave(file.path(OUT_F, "fig08_party_scatter.png"),
       p8, width = 9, height = 7, dpi = 200, bg = "white")
ggsave(file.path(OUT_F, "fig09_party_time_petroleum.png"),
       p9, width = 11, height = 6, dpi = 200, bg = "white")

cat("Party analysis complete.\n")
cat("\nParty vocabulary rates:\n")
print(party_vocab %>% arrange(desc(rate_petroleum)) %>%
      mutate(across(where(is.numeric) & !starts_with("n_"), ~round(., 1))))
