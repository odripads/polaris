###############################################################################
# NGDC Analysis — Script 02: Temporal Trends
# Kalcer Institute | Odri | May 2026
#
# The core empirical claim: as petroleum extraction continues or increases,
# "petroleum" is spoken *less* while "klima" remains constant or grows.
# This is disavowal at the level of language.
###############################################################################

library(tidyverse)
library(scales)
library(patchwork)
library(ggrepel)

BASE   <- "/Users/odripads/Desktop/GitHub/ngdc"
OUT_F  <- file.path(BASE, "outputs", "figures")
OUT_T  <- file.path(BASE, "outputs", "tables")

corpus  <- readRDS(file.path(BASE, "outputs", "corpus.rds"))
summary <- readRDS(file.path(BASE, "outputs", "session_summary.rds"))

theme_ngdc <- function() {
  theme_minimal(base_family = "Helvetica", base_size = 12) +
    theme(
      plot.title    = element_text(size = 14, face = "bold", margin = margin(b = 6)),
      plot.subtitle = element_text(size = 11, color = "#444444", margin = margin(b = 12)),
      plot.caption  = element_text(size = 9, color = "#888888", hjust = 0),
      panel.grid.minor = element_blank(),
      axis.text.x   = element_text(angle = 30, hjust = 1),
      legend.position = "bottom",
      legend.title  = element_blank()
    )
}

# ── 1. Petroleum-vs-Klima raw speech counts ───────────────────────────────────

trend_long <- summary %>%
  select(session_label, year_start, n_petroleum, n_klima, n_fornybar, n_barekraft) %>%
  pivot_longer(c(n_petroleum, n_klima, n_fornybar, n_barekraft),
               names_to = "term", values_to = "n_speeches") %>%
  mutate(term = recode(term,
    n_petroleum = "petroleum",
    n_klima     = "klima",
    n_fornybar  = "fornybar (renewable)",
    n_barekraft = "bærekraft (sustainability)"
  ))

p1 <- trend_long %>%
  filter(term %in% c("petroleum", "klima")) %>%
  ggplot(aes(x = reorder(session_label, year_start), y = n_speeches,
             color = term, group = term)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 3) +
  scale_color_manual(values = c("petroleum" = "#C0392B", "klima" = "#27AE60")) +
  labs(
    title    = "Speeches mentioning 'petroleum' vs 'klima', by session",
    subtitle = "Stortinget plenary debates, 2016–2025 | N = 15,210 keyword-matched speeches",
    x = NULL, y = "Speeches (count)",
    caption  = "Norwegian Green Discourse Corpus (NGDC) | Kalcer Institute, 2026"
  ) +
  theme_ngdc()

# ── 2. Petroleum/Klima ratio ──────────────────────────────────────────────────

p2 <- summary %>%
  mutate(session_label = reorder(session_label, year_start)) %>%
  ggplot(aes(x = session_label, y = petroleum_klima_ratio, group = 1)) +
  geom_line(linewidth = 1.3, color = "#8E44AD") +
  geom_point(size = 3.5, color = "#8E44AD") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "#AAAAAA") +
  geom_label_repel(
    aes(label = sprintf("%.2f", petroleum_klima_ratio)),
    size = 3, color = "#8E44AD", min.segment.length = 0.3
  ) +
  labs(
    title    = "Petroleum/Klima speech ratio, 2016–2025",
    subtitle = "Speeches naming 'petroleum' as a fraction of those naming 'klima'\nFalling ratio = petroleum progressively absent from discourse while extraction continues",
    x = NULL, y = "Ratio (petroleum ÷ klima)",
    caption  = "NGDC | Kalcer Institute, 2026"
  ) +
  theme_ngdc()

# ── 3. All green-identity terms stacked ───────────────────────────────────────

p3 <- trend_long %>%
  ggplot(aes(x = reorder(session_label, year_start), y = n_speeches,
             color = term, group = term)) +
  geom_line(linewidth = 1.0) +
  geom_point(size = 2.5) +
  scale_color_manual(values = c(
    "petroleum"              = "#C0392B",
    "klima"                  = "#27AE60",
    "fornybar (renewable)"   = "#2980B9",
    "bærekraft (sustainability)" = "#F39C12"
  )) +
  labs(
    title    = "All major keyword categories across sessions",
    subtitle = "Stortinget plenary debates | NGDC filtered corpus",
    x = NULL, y = "Speeches (count)",
    caption  = "NGDC | Kalcer Institute, 2026"
  ) +
  theme_ngdc()

# ── 4. Composition: share of corpus by speech type ───────────────────────────

speech_type_by_session <- corpus %>%
  group_by(session_label = sprintf("%s–%s", year_start,
    str_sub(as.character(year_end), 3, 4)),
    year_start, speech_type) %>%
  summarise(n = n(), .groups = "drop") %>%
  group_by(session_label, year_start) %>%
  mutate(pct = n / sum(n))

p4 <- speech_type_by_session %>%
  ggplot(aes(x = reorder(session_label, year_start), y = pct, fill = speech_type)) +
  geom_col() +
  scale_y_continuous(labels = percent_format()) +
  scale_fill_manual(values = c(
    "Hovedinnlegg" = "#2C3E50",
    "Presinnlegg"  = "#7F8C8D",
    "Replikk"      = "#BDC3C7"
  )) +
  labs(
    title    = "Speech type composition by session",
    subtitle = "Hauptinnlegg (formal) vs Presinnlegg (brief) vs Replikk (reply)",
    x = NULL, y = "Share of corpus",
    caption  = "NGDC | Kalcer Institute, 2026"
  ) +
  theme_ngdc()

# ── Save ──────────────────────────────────────────────────────────────────────

ggsave(file.path(OUT_F, "fig01_petroleum_klima_counts.png"),
       p1, width = 10, height = 6, dpi = 200, bg = "white")
ggsave(file.path(OUT_F, "fig02_petroleum_klima_ratio.png"),
       p2, width = 10, height = 6, dpi = 200, bg = "white")
ggsave(file.path(OUT_F, "fig03_all_keywords_temporal.png"),
       p3, width = 11, height = 6, dpi = 200, bg = "white")
ggsave(file.path(OUT_F, "fig04_speech_type_composition.png"),
       p4, width = 10, height = 6, dpi = 200, bg = "white")

# Combined figure for publication
combined <- (p1 / p2) + plot_annotation(
  title   = "Disavowal in parliamentary language: petroleum absent, klima present",
  caption = "Norwegian Green Discourse Corpus (NGDC) | Kalcer Institute, 2026",
  theme   = theme(plot.title = element_text(size = 15, face = "bold"))
)
ggsave(file.path(OUT_F, "fig00_combined_temporal.png"),
       combined, width = 11, height = 12, dpi = 200, bg = "white")

write_csv(summary, file.path(OUT_T, "temporal_summary.csv"))

cat("Temporal analysis complete. Figures saved to outputs/figures/\n")
cat("\nKey finding — Petroleum/Klima ratios:\n")
print(summary %>% select(session_label, n_petroleum, n_klima, petroleum_klima_ratio) %>%
      mutate(across(petroleum_klima_ratio, ~round(., 3))))
