###############################################################################
# POLARIS Analysis — Script 07: Findings Synthesis
# Kalcer Institute | Odri | May 2026
#
# Generates the key publication-ready tables and figures that synthesise
# across all analysis scripts. These are the empirical results that support
# the disavowal thesis.
###############################################################################

library(tidyverse)
library(scales)
library(patchwork)
library(ggrepel)

BASE  <- "/Users/odripads/Desktop/GitHub/ngdc"
OUT_F <- file.path(BASE, "outputs", "figures")
OUT_T <- file.path(BASE, "outputs", "tables")

corpus  <- readRDS(file.path(BASE, "outputs", "corpus.rds"))
summary <- readRDS(file.path(BASE, "outputs", "session_summary.rds"))

theme_pub <- function(base_size = 12) {
  theme_minimal(base_family = "Helvetica", base_size = base_size) +
    theme(
      plot.title    = element_text(size = base_size + 2, face = "bold"),
      plot.subtitle = element_text(size = base_size, color = "#444444", lineheight = 1.3),
      plot.caption  = element_text(size = 9, color = "#888888", hjust = 0),
      panel.grid.minor = element_blank(),
      legend.position = "bottom"
    )
}

# ── Figure A: The Disavowal Signal ───────────────────────────────────────────
# The ratio declining = petroleum disappears from discourse while
# petroleum extraction continues or increases

ratio_plot <- summary %>%
  mutate(
    label     = case_when(
      session_label == "2016–17" ~ "0.168\n(baseline)",
      session_label == "2024–25" ~ "0.083\n(2024)",
      TRUE ~ ""
    ),
    year_start = year_start
  ) %>%
  ggplot(aes(x = year_start, y = petroleum_klima_ratio)) +
  geom_ribbon(aes(ymin = 0, ymax = petroleum_klima_ratio), fill = "#C0392B", alpha = 0.12) +
  geom_line(linewidth = 1.5, color = "#C0392B") +
  geom_point(size = 4, color = "#C0392B") +
  geom_text(aes(label = label), vjust = -0.8, size = 3.2, color = "#C0392B", lineheight = 1.1) +
  annotate("segment", x = 2019, xend = 2020,
           y = 0.16, yend = 0.095,
           arrow = arrow(length = unit(0.2, "cm")),
           color = "#555555", linetype = "dashed") +
  annotate("text", x = 2019.2, y = 0.165,
           label = "2020: pandemic + \nrenewables surge",
           size = 3, hjust = 0, color = "#555555") +
  scale_x_continuous(breaks = 2016:2024,
                     labels = paste0(2016:2024, "–", str_sub(2017:2025, 3))) +
  scale_y_continuous(limits = c(0, 0.22), labels = number_format(accuracy = 0.01)) +
  labs(
    title    = "The petroleum/klima ratio in Stortinget, 2016–2025",
    subtitle = "Speeches naming 'petroleum*' ÷ speeches naming 'klima*'\nFalling ratio = petroleum progressively absent from parliamentary discourse",
    x = NULL, y = "Ratio (petroleum rate ÷ klima rate)",
    caption  = "POLARIS Corpus (Parliamentary Oil, Legitimacy And Renewables In Stortinget) v1.0 | Kalcer Institute, 2026"
  ) +
  theme_pub()

ggsave(file.path(OUT_F, "FIGURE_A_disavowal_ratio.png"),
       ratio_plot, width = 11, height = 6, dpi = 250, bg = "white")

# ── Figure B: Cross-partisan consistency ─────────────────────────────────────
# If disavowal is structural, petroleum rates should be declining across ALL parties

major_parties <- c("A", "H", "FrP", "SV", "MDG", "Sp", "Statsråd")
party_colors <- c(
  "A" = "#D73E3E", "H" = "#0070B8", "FrP" = "#003580",
  "Sp" = "#2B8B2B", "SV" = "#CC0000", "MDG" = "#5DAC44",
  "Statsråd" = "#555555"
)
party_labels <- c(
  "A" = "Labour", "H" = "Conservative", "FrP" = "Progress",
  "Sp" = "Centre", "SV" = "Socialist Left", "MDG" = "Greens",
  "Statsråd" = "Ministers"
)

party_time <- corpus %>%
  filter(party %in% major_parties) %>%
  group_by(party, year_start) %>%
  summarise(n = n(), rate_petro = mean(has_petroleum) * 100, .groups = "drop") %>%
  filter(n >= 10)

xpar <- ggplot(party_time,
               aes(x = year_start, y = rate_petro, color = party, group = party)) +
  geom_smooth(method = "loess", se = FALSE, span = 1.2, linewidth = 0.8, alpha = 0.7) +
  geom_point(aes(size = n), alpha = 0.6) +
  geom_label_repel(
    data = party_time %>% filter(year_start == max(year_start)),
    aes(label = party_labels[party]),
    size = 3, min.segment.length = 0.2, show.legend = FALSE
  ) +
  scale_color_manual(values = party_colors, guide = "none") +
  scale_size_continuous(name = "N speeches", range = c(1.5, 5), guide = "none") +
  scale_x_continuous(breaks = 2016:2024) +
  labs(
    title    = "Petroleum mention rates by party, 2016–2025",
    subtitle = "% of each party's speeches mentioning 'petroleum*'\nDecline is cross-partisan: structural, not party-political",
    x = "Session start year", y = "% mentioning 'petroleum*'",
    caption  = "POLARIS v1.0 | Kalcer Institute, 2026"
  ) +
  theme_pub()

ggsave(file.path(OUT_F, "FIGURE_B_crosspartisan.png"),
       xpar, width = 11, height = 6, dpi = 250, bg = "white")

# ── Figure C: Cross-institutional comparison ──────────────────────────────────

cross_df <- tibble(
  term        = c("carbon neutral /\nnet zero", "responsible", "divestment",
                  "sustainable /\nbærekraft", "balance", "climate / klima",
                  "petroleum", "oil / olje", "extraction"),
  parliament  = c(0.29, 1.76, 0.01, 9.52, 1.60, 38.0, 3.3, 7.56, 0.85),
  nbim        = c(14.9, 65.6, 30.5, 28.6, 2.34, 66.1, 0.0, 0.0, 0.0),
  category    = c("green-identity", "green-identity", "green-identity",
                  "green-identity", "bridging", "green-identity",
                  "extractive", "extractive", "extractive")
)

cross_long <- cross_df %>%
  pivot_longer(c(parliament, nbim), names_to = "institution", values_to = "rate") %>%
  mutate(
    institution = recode(institution,
      parliament = "Parliament (Phase 1)",
      nbim       = "NBIM (Phase 2)"
    ),
    term = fct_reorder(term, rate, .fun = max)
  )

p_cross <- ggplot(cross_long, aes(x = term, y = rate + 0.001,
                                   fill = institution, alpha = category)) +
  geom_col(position = "dodge") +
  scale_fill_manual(values = c("Parliament (Phase 1)" = "#2C3E50",
                                "NBIM (Phase 2)"       = "#27AE60")) +
  scale_alpha_manual(values = c("green-identity" = 1, "bridging" = 0.7,
                                 "extractive" = 0.5),
                     guide = "none") +
  scale_y_log10(labels = number_format(accuracy = 0.1),
                breaks = c(0.01, 0.1, 1, 10, 100)) +
  coord_flip() +
  labs(
    title    = "Parliament vs NBIM: key term rates",
    subtitle = "Rate per 10,000 words (log scale) | POLARIS Phase 1 + Phase 2",
    x = NULL, y = "Rate per 10,000 words (log scale)",
    fill     = NULL,
    caption  = "POLARIS v1.0 | Kalcer Institute, 2026"
  ) +
  theme_pub()

ggsave(file.path(OUT_F, "FIGURE_C_cross_institutional.png"),
       p_cross, width = 11, height = 7, dpi = 250, bg = "white")

# ── Table 1: Key empirical findings summary ───────────────────────────────────

findings_table <- tribble(
  ~Finding, ~Measure, ~Value, ~Theoretical_significance,
  "Petroleum/klima ratio decline",
    "2016–17 vs 2024–25",
    "0.168 → 0.083 (-50%)",
    "Petroleum progressively absent from discourse while extraction continues",

  "Cross-partisan consistency",
    "Standard deviation of petroleum rates across parties",
    paste0(round(sd(corpus %>%
      filter(party %in% major_parties) %>%
      group_by(party) %>%
      summarise(r=mean(has_petroleum)) %>%
      pull(r)), 3), " (low)"),
    "Disavowal is structural, not a property of individual parties",

  "Ministerial share of corpus",
    "% of corpus spoken by Statsråd",
    sprintf("%.0f%%",
      mean(corpus$party == "Statsråd") * 100),
    "The state apparatus speaks as a unified subject",

  "NBIM carbon neutral rate vs Parliament",
    "NBIM ÷ Parliament rate",
    "51.7x",
    "NBIM performs green identity at extreme intensity",

  "NBIM extraction rate",
    "Occurrences per 10,000 words",
    "0.0",
    "Source of fund’s wealth structurally absent from its own discourse",

  "Parliament petroleum rate",
    "Speeches mentioning 'petroleum*' (2016–17)",
    sprintf("%.0f%%", 154/1768*100),
    "Even the primary forum names petroleum only in 1 in 11 speeches",

  "Parliament petroleum rate",
    "Speeches mentioning 'petroleum*' (2024–25)",
    sprintf("%.0f%%", 69/1641*100),
    "Rate has halved in 8 years while extraction expanded"
)

write_csv(findings_table, file.path(OUT_T, "FINDINGS_SUMMARY.csv"))
cat("Findings summary table written.\n")

# ── Speaker analysis: top speakers ───────────────────────────────────────────

top_speakers <- corpus %>%
  filter(!party %in% c("Presidenten", "Unknown", "")) %>%
  group_by(speaker_name, party) %>%
  summarise(
    n_speeches     = n(),
    n_petro        = sum(has_petroleum),
    n_klima        = sum(has_klima),
    petro_rate     = mean(has_petroleum) * 100,
    klima_rate     = mean(has_klima) * 100,
    petro_klima_r  = n_petro / pmax(n_klima, 1),
    .groups = "drop"
  ) %>%
  filter(n_speeches >= 20) %>%
  arrange(desc(n_speeches))

write_csv(top_speakers %>% head(50), file.path(OUT_T, "top_speakers.csv"))

cat("\nTop 20 speakers by corpus presence:\n")
print(top_speakers %>% head(20) %>%
      select(speaker_name, party, n_speeches, petro_rate, klima_rate) %>%
      mutate(across(where(is.numeric) & !n_speeches, ~round(., 1))))
