###############################################################################
# POLARIS Inferential Analysis — Script 12: STM Effect Estimates (Inferential)
# Kalcer Institute | Odri | May 2026
#
# The STM model already estimated prevalence effects with uncertainty.
# estimateEffect() produces confidence intervals on:
#   - How topic proportions change per year
#   - How FrP vs left-bloc differ on each topic
#   - How ministers (Statsråd) differ from MPs
#
# This script extracts, formats, and visualises those estimates.
# These ARE inferential — they come with standard errors computed via
# the global uncertainty method (Roberts et al. 2016).
###############################################################################

library(tidyverse)
library(stm)

BASE  <- "/Users/odripads/Desktop/GitHub/ngdc"
OUT_F <- file.path(BASE, "outputs", "figures")
OUT_T <- file.path(BASE, "outputs", "tables")

stm_fit   <- readRDS(file.path(BASE, "outputs", "stm_k10.rds"))
corpus_df <- readRDS(file.path(BASE, "outputs", "corpus.rds"))

# Topic labels (from 08_stm_interpret.R)
topic_labels <- c(
  "T1: Petroleum fiscal regime",
  "T2: Welfare / social services",
  "T3: Parliamentary procedure",
  "T4: Energy transition & industry",
  "T5: Adversarial floor debate",
  "T6: Nynorsk register",
  "T7: Climate policy & emissions",
  "T8: Transport & infrastructure",
  "T9: Foreign policy & geopolitics",
  "T10: Nature & biodiversity"
)

major_parties <- c("A","H","FrP","SV","MDG","R","V","KrF","Sp","Statsråd")

# Use FULL corpus (15,210 rows) — must match STM training data exactly
meta <- corpus_df %>%
  mutate(
    year_scaled  = scale(year_start)[,1],
    is_minister  = as.integer(party == "Statsråd"),
    is_frp       = as.integer(party == "FrP"),
    is_left      = as.integer(party %in% c("SV","MDG","R")),
    speech_main  = as.integer(speech_type == "Hoofdinnlegg")
  ) %>%
  select(year_scaled, is_minister, is_frp, is_left, speech_main)

cat("Estimating STM prevalence effects...\n")
effects <- estimateEffect(
  formula  = 1:10 ~ year_scaled + is_minister + is_frp + is_left,
  stmobj   = stm_fit,
  metadata = meta,
  uncertainty = "Global"
)

# ── Extract year effects for all 10 topics ───────────────────────────────────

extract_coef <- function(effects, covariate, topics = 1:10, topic_labels) {
  map_dfr(topics, function(k) {
    s <- summary(effects, topics = k)$tables[[1]]
    row_idx <- which(rownames(s) == covariate)
    if (length(row_idx) == 0) return(NULL)
    tibble(
      topic      = k,
      topic_label = topic_labels[k],
      estimate   = s[row_idx, "Estimate"],
      std_err    = s[row_idx, "Std. Error"],
      t_stat     = s[row_idx, "t value"],
      p_value    = s[row_idx, "Pr(>|t|)"],
      ci_lo      = estimate - 1.96 * std_err,
      ci_hi      = estimate + 1.96 * std_err,
      sig        = case_when(
        p_value < 0.001 ~ "***", p_value < 0.01 ~ "**",
        p_value < 0.05 ~ "*",   p_value < 0.1 ~ ".",
        TRUE ~ ""
      )
    )
  })
}

year_effects  <- extract_coef(effects, "year_scaled",  1:10, topic_labels)
frp_effects   <- extract_coef(effects, "is_frp",       1:10, topic_labels)
left_effects  <- extract_coef(effects, "is_left",      1:10, topic_labels)
min_effects   <- extract_coef(effects, "is_minister",  1:10, topic_labels)

write_csv(year_effects,  file.path(OUT_T, "stm_year_effects.csv"))
write_csv(frp_effects,   file.path(OUT_T, "stm_frp_effects.csv"))
write_csv(left_effects,  file.path(OUT_T, "stm_left_effects.csv"))
write_csv(min_effects,   file.path(OUT_T, "stm_minister_effects.csv"))

# ── Plot 1: Year effects with CIs ────────────────────────────────────────────

theory_color <- c(
  "T1: Petroleum fiscal regime"    = "#C0392B",
  "T4: Energy transition & industry" = "#8E44AD",
  "T5: Adversarial floor debate"   = "#2C3E50",
  "T7: Climate policy & emissions" = "#27AE60",
  "other" = "#AAAAAA"
)

year_effects_plot <- year_effects %>%
  mutate(
    topic_label = fct_reorder(topic_label, estimate),
    color_group = case_when(
      str_detect(topic_label, "Petroleum") ~ topic_label,
      str_detect(topic_label, "Energy")    ~ topic_label,
      str_detect(topic_label, "Adversarial") ~ topic_label,
      str_detect(topic_label, "Climate")   ~ topic_label,
      TRUE ~ "other"
    )
  )

p_year_fx <- year_effects_plot %>%
  ggplot(aes(x = topic_label, y = estimate, color = color_group)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "#AAAAAA") +
  geom_linerange(aes(ymin = ci_lo, ymax = ci_hi), linewidth = 1.1) +
  geom_point(size = 3.5) +
  geom_text(aes(label = sig), hjust = -0.5, size = 4, color = "#333333") +
  scale_color_manual(values = theory_color, guide = "none") +
  coord_flip() +
  labs(
    title    = "STM: effect of year on topic prevalence (with 95% CI)",
    subtitle = "Positive = topic growing over time | Negative = declining\nColour: theoretically key topics | * p<.05 ** p<.01 *** p<.001",
    x = NULL, y = "Estimated effect of year (scaled) on topic proportion",
    caption  = "POLARIS v1.0 | Kalcer Institute, 2026"
  ) +
  theme_minimal(base_family = "Helvetica", base_size = 12) +
  theme(plot.title = element_text(face = "bold"), panel.grid.minor = element_blank())

# ── Plot 2: FrP vs Left comparison ───────────────────────────────────────────

contrast_df <- bind_rows(
  frp_effects  %>% mutate(group = "FrP (vs. rest)"),
  left_effects %>% mutate(group = "Left bloc SV/MDG/R (vs. rest)")
) %>%
  mutate(topic_label = fct_reorder(topic_label, estimate))

p_contrast <- contrast_df %>%
  ggplot(aes(x = topic_label, y = estimate, color = group)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "#AAAAAA") +
  geom_linerange(aes(ymin = ci_lo, ymax = ci_hi), linewidth = 1,
                 position = position_dodge(width = 0.5)) +
  geom_point(size = 3, position = position_dodge(width = 0.5)) +
  geom_text(aes(label = sig), hjust = -0.3, size = 3.5, color = "#333333",
            position = position_dodge(width = 0.5)) +
  scale_color_manual(values = c("FrP (vs. rest)" = "#003580",
                                 "Left bloc SV/MDG/R (vs. rest)" = "#8B0000")) +
  coord_flip() +
  labs(
    title    = "STM: FrP vs Left bloc — topic prevalence differences (95% CI)",
    subtitle = "Positive = group uses topic MORE than rest of corpus\nKey test: do FrP and left bloc differ on energy transition & climate topics?",
    x = NULL, y = "Effect on topic proportion",
    color    = NULL,
    caption  = "POLARIS v1.0 | Kalcer Institute, 2026"
  ) +
  theme_minimal(base_family = "Helvetica", base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    legend.position = "bottom",
    panel.grid.minor = element_blank()
  )

# ── Plot 3: Minister effect ───────────────────────────────────────────────────

p_minister <- min_effects %>%
  mutate(topic_label = fct_reorder(topic_label, estimate)) %>%
  ggplot(aes(x = topic_label, y = estimate,
             color = estimate > 0)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "#AAAAAA") +
  geom_linerange(aes(ymin = ci_lo, ymax = ci_hi), linewidth = 1.1) +
  geom_point(size = 3.5) +
  geom_text(aes(label = sig), hjust = -0.5, size = 4, color = "#333333") +
  scale_color_manual(values = c("TRUE" = "#555555", "FALSE" = "#C0392B"),
                     guide = "none") +
  coord_flip() +
  labs(
    title    = "STM: Minister (Statsråd) effect on topic prevalence",
    subtitle = "Do ministers speak differently from MPs, controlling for year?\nTheoretical prediction: ministers over-represent T4 (energy transition) and T3 (procedural)",
    x = NULL, y = "Effect of being Minister (Statsråd) on topic proportion",
    caption  = "POLARIS v1.0 | Kalcer Institute, 2026"
  ) +
  theme_minimal(base_family = "Helvetica", base_size = 12) +
  theme(plot.title = element_text(face = "bold"), panel.grid.minor = element_blank())

# ── Save ──────────────────────────────────────────────────────────────────────

ggsave(file.path(OUT_F, "INF09_stm_year_effects_ci.png"),
       p_year_fx, width = 11, height = 7, dpi = 250, bg = "white")
ggsave(file.path(OUT_F, "INF10_stm_party_contrast.png"),
       p_contrast, width = 12, height = 7, dpi = 250, bg = "white")
ggsave(file.path(OUT_F, "INF11_stm_minister_effect.png"),
       p_minister, width = 11, height = 7, dpi = 250, bg = "white")

cat("\n=== KEY STM INFERENTIAL RESULTS ===\n")
cat("\nYear effects (significant topics):\n")
print(year_effects %>% filter(p_value < 0.1) %>%
      select(topic_label, estimate, ci_lo, ci_hi, p_value, sig) %>%
      mutate(across(where(is.numeric), ~round(., 4))))

cat("\nFrP vs rest (significant):\n")
print(frp_effects %>% filter(p_value < 0.1) %>%
      select(topic_label, estimate, ci_lo, ci_hi, p_value, sig) %>%
      mutate(across(where(is.numeric), ~round(., 4))))

cat("\nSTM effect estimates complete. Figures: INF09–11\n")
