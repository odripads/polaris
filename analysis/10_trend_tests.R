###############################################################################
# NGDC Inferential Analysis — Script 10: Trend Tests + Interrupted Time Series
# Kalcer Institute | Odri | May 2026
#
# 1. Mann-Kendall trend test: is the petroleum/klima ratio decline monotonic
#    and statistically significant? (non-parametric, suitable for n=9)
#
# 2. Interrupted Time Series (ITS): was there a structural break in 2020?
#    (The ratio dropped from 0.161 in 2019-20 to 0.089 in 2020-21 — is
#    that a level change, a slope change, or both?)
#
# 3. Permutation test: is the cross-partisan similarity in petroleum rates
#    significantly higher than chance? Shuffling party labels should destroy
#    the similarity if the pattern is party-specific; if it holds, the
#    structure is not party-driven.
###############################################################################

library(tidyverse)
library(Kendall)
library(segmented)
library(lmtest)
library(sandwich)
library(ggrepel)

BASE  <- "/Users/odripads/Desktop/GitHub/ngdc"
OUT_F <- file.path(BASE, "outputs", "figures")
OUT_T <- file.path(BASE, "outputs", "tables")

corpus  <- readRDS(file.path(BASE, "outputs", "corpus.rds"))
summary <- readRDS(file.path(BASE, "outputs", "session_summary.rds"))

# ── 1. Mann-Kendall trend test ────────────────────────────────────────────────
# H0: no monotonic trend in petroleum/klima ratio
# Suitable for n=9 (rank-based, no distributional assumptions)

ratio_series <- summary %>%
  arrange(year_start) %>%
  pull(petroleum_klima_ratio)

mk_result <- MannKendall(ratio_series)

cat("=== Mann-Kendall Trend Test ===\n")
cat("Series: petroleum/klima ratio, 2016–2024 (n=9 sessions)\n")
cat(sprintf("Kendall's tau = %.4f\n", mk_result$tau))
cat(sprintf("p-value (two-sided) = %.4f\n", mk_result$sl[1]))
cat(sprintf("p-value (one-sided, declining) = %.4f\n", mk_result$sl[2]))
cat(sprintf("\nConclusion: the decline is %s (tau=%.3f, p=%.4f)\n",
            ifelse(mk_result$sl[2] < 0.05, "STATISTICALLY SIGNIFICANT", "not significant at p<.05"),
            mk_result$tau, mk_result$sl[2]))

mk_df <- tibble(
  test = "Mann-Kendall",
  series = "petroleum/klima ratio",
  n = 9,
  tau = mk_result$tau[1],
  p_two_sided = mk_result$sl[1],
  p_one_sided_decline = mk_result$sl[2],
  significant = mk_result$sl[2] < 0.05
)
write_csv(mk_df, file.path(OUT_T, "mann_kendall_result.csv"))

# Also run on raw petroleum count and klima count separately
mk_petro <- MannKendall(summary %>% arrange(year_start) %>% pull(n_petroleum))
mk_klima <- MannKendall(summary %>% arrange(year_start) %>% pull(n_klima))
cat(sprintf("\nPetroleum count trend: tau=%.3f, p=%.4f\n",
            mk_petro$tau, mk_petro$sl[2]))
cat(sprintf("Klima count trend:     tau=%.3f, p=%.4f\n",
            mk_klima$tau, mk_klima$sl[2]))

# ── 2. Interrupted Time Series ────────────────────────────────────────────────
# We model the ratio as a function of time and a structural break
# Break candidate: 2020 (year_c = 4)

its_dat <- summary %>%
  arrange(year_start) %>%
  mutate(
    t          = row_number(),               # 1–9
    year_c     = year_start - 2016,          # 0–8
    post_break = as.integer(year_start >= 2020),  # intervention indicator
    t_post     = (year_c - 4) * post_break   # time since break (0 before)
  )

# OLS ITS model: ratio ~ t + post_break + t_post
# - t:          pre-break slope
# - post_break: level change at break
# - t_post:     slope change after break

its_model <- lm(petroleum_klima_ratio ~ year_c + post_break + t_post,
                data = its_dat)

# With robust SEs
its_robust <- coeftest(its_model, vcov = vcovHC(its_model, type = "HC3"))

cat("\n=== Interrupted Time Series (ITS) ===\n")
cat("Break point: 2020 (post-COVID green recovery)\n")
print(its_robust)

# Counterfactual: what would the ratio be if there had been no break?
counterfact <- its_dat %>%
  mutate(
    post_break_cf = 0L,
    t_post_cf     = 0
  )
its_dat$fitted_observed    <- fitted(its_model)
its_dat$fitted_counterfact <- predict(its_model,
  newdata = its_dat %>% mutate(post_break = 0L, t_post = 0))

its_results <- broom::tidy(its_model, conf.int = TRUE) %>%
  mutate(sig = case_when(
    p.value < 0.001 ~ "***", p.value < 0.01 ~ "**",
    p.value < 0.05 ~ "*",   TRUE ~ ""
  ))
write_csv(its_results, file.path(OUT_T, "its_model_results.csv"))

# ── ITS plot ──────────────────────────────────────────────────────────────────

p_its <- ggplot(its_dat, aes(x = year_start)) +
  # Shading for break period
  annotate("rect", xmin = 2019.5, xmax = 2020.5,
           ymin = -Inf, ymax = Inf, fill = "#F39C12", alpha = 0.10) +
  annotate("text", x = 2020, y = 0.195,
           label = "Break: 2020", size = 3.2, color = "#F39C12", fontface = "bold") +
  # Counterfactual trajectory
  geom_line(aes(y = fitted_counterfact), linetype = "dashed",
            color = "#AAAAAA", linewidth = 1.0) +
  annotate("text", x = 2023, y = 0.14,
           label = "Counterfactual\n(no break)", size = 3, color = "#AAAAAA") +
  # Observed data
  geom_line(aes(y = petroleum_klima_ratio), color = "#C0392B", linewidth = 1.2) +
  geom_point(aes(y = petroleum_klima_ratio), color = "#C0392B", size = 3.5) +
  # ITS fitted
  geom_line(aes(y = fitted_observed), color = "#8E44AD",
            linewidth = 1.0, linetype = "dotted") +
  # Level change arrow
  annotate("segment",
           x = 2020, xend = 2020,
           y = its_dat$fitted_counterfact[its_dat$year_start == 2020],
           yend = its_dat$fitted_observed[its_dat$year_start == 2020],
           arrow = arrow(length = unit(0.2, "cm"), ends = "both"),
           color = "#8E44AD") +
  scale_x_continuous(breaks = 2016:2024) +
  scale_y_continuous(limits = c(0, 0.22)) +
  labs(
    title    = "Interrupted Time Series: petroleum/klima ratio",
    subtitle = sprintf(
      "OLS ITS model | Break at 2020\nLevel change: %.3f %s | Slope change: %.4f %s",
      its_results$estimate[its_results$term == "post_break"],
      its_results$sig[its_results$term == "post_break"],
      its_results$estimate[its_results$term == "t_post"],
      its_results$sig[its_results$term == "t_post"]
    ),
    x = "Session start year",
    y = "Petroleum/klima speech ratio",
    caption  = "NGDC v1.0 | Kalcer Institute, 2026"
  ) +
  theme_minimal(base_family = "Helvetica", base_size = 12) +
  theme(plot.title = element_text(face = "bold"), panel.grid.minor = element_blank())

# ── 3. Permutation test: cross-partisan consistency ───────────────────────────
# If disavowal is structural (not party-driven), shuffling party labels
# should NOT reduce the variance in petroleum rates across parties.
# H0: observed between-party variance in petroleum rates = chance
# We measure: variance of party-level mean petroleum rates
# Permute: shuffle party labels 5000 times, recompute between-party variance

major_parties <- c("A","H","FrP","SV","MDG","R","V","KrF","Sp","Statsråd")

pdat <- corpus %>%
  filter(party %in% major_parties) %>%
  mutate(has_petroleum = as.integer(has_petroleum))

# Observed between-party variance
obs_var <- pdat %>%
  group_by(party) %>%
  summarise(m = mean(has_petroleum), .groups = "drop") %>%
  pull(m) %>% var()

cat(sprintf("\n=== Permutation Test: Cross-Partisan Consistency ===\n"))
cat(sprintf("Observed between-party variance in petroleum rates: %.6f\n", obs_var))

set.seed(123)
n_perm <- 5000
perm_vars <- numeric(n_perm)
for (i in seq_len(n_perm)) {
  shuffled <- pdat %>%
    mutate(party = sample(party)) %>%
    group_by(party) %>%
    summarise(m = mean(has_petroleum), .groups = "drop") %>%
    pull(m) %>% var()
  perm_vars[i] <- shuffled
}

p_val_perm <- mean(perm_vars <= obs_var)
cat(sprintf("Permutation p-value (one-sided, obs <= null): %.4f\n", p_val_perm))
cat(sprintf("Mean null variance: %.6f | Observed: %.6f\n",
            mean(perm_vars), obs_var))

interpretation <- if (p_val_perm < 0.05) {
  "SIGNIFICANT: observed between-party variance is LOWER than chance.\nParties are MORE similar than random — disavowal is structurally cross-partisan."
} else {
  "The between-party variance is not significantly different from chance."
}
cat(sprintf("Conclusion: %s\n", interpretation))

perm_df <- tibble(null_variance = perm_vars)
write_csv(perm_df, file.path(OUT_T, "permutation_test_null_dist.csv"))

perm_result <- tibble(
  test = "Permutation",
  observed_variance = obs_var,
  null_mean_variance = mean(perm_vars),
  p_value = p_val_perm,
  n_permutations = n_perm
)
write_csv(perm_result, file.path(OUT_T, "permutation_test_result.csv"))

# Permutation plot
p_perm <- ggplot(perm_df, aes(x = null_variance)) +
  geom_histogram(bins = 60, fill = "#2C3E50", alpha = 0.75) +
  geom_vline(xintercept = obs_var, color = "#C0392B",
             linewidth = 1.5, linetype = "dashed") +
  annotate("label", x = obs_var, y = Inf, vjust = 1.2,
           label = sprintf("Observed\nvariance\n= %.5f", obs_var),
           color = "#C0392B", size = 3.5, fill = "white") +
  labs(
    title    = "Permutation test: between-party variance in petroleum rates",
    subtitle = sprintf("N = %d permutations | p = %.4f\nIf disavowal is structural, observed variance < null distribution",
                       n_perm, p_val_perm),
    x = "Between-party variance (shuffled party labels)",
    y = "Count",
    caption  = "NGDC v1.0 | Kalcer Institute, 2026"
  ) +
  theme_minimal(base_family = "Helvetica", base_size = 12) +
  theme(plot.title = element_text(face = "bold"), panel.grid.minor = element_blank())

# ── Save ──────────────────────────────────────────────────────────────────────

ggsave(file.path(OUT_F, "INF04_its_model.png"),
       p_its, width = 11, height = 6, dpi = 250, bg = "white")
ggsave(file.path(OUT_F, "INF05_permutation_test.png"),
       p_perm, width = 10, height = 6, dpi = 250, bg = "white")

cat("\nTrend tests complete. Figures: INF04–05\n")
