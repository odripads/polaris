###############################################################################
# POLARIS Inferential Analysis — Script 09: Logistic Regression
# Kalcer Institute | Odri | May 2026
#
# Research question: does YEAR significantly predict the probability of a
# speech mentioning 'petroleum', controlling for party and speech type?
#
# Model 1 (baseline):   has_petroleum ~ year
# Model 2 (controlled): has_petroleum ~ year + party + speech_type
# Model 3 (interaction): has_petroleum ~ year * party + speech_type
#
# Epistemological framing: superpopulation model — speeches are treated as
# draws from the distribution of all possible speeches Norwegian parliament
# could have produced. Effect sizes + 95% CIs are the primary outputs;
# p-values are reported but interpreted as evidence strength, not decision
# thresholds.
###############################################################################

library(tidyverse)
library(broom)
library(lmtest)
library(sandwich)
library(car)
library(emmeans)
library(ggrepel)
library(patchwork)

BASE  <- "/Users/odripads/Desktop/GitHub/ngdc"
OUT_F <- file.path(BASE, "outputs", "figures")
OUT_T <- file.path(BASE, "outputs", "tables")

corpus <- readRDS(file.path(BASE, "outputs", "corpus.rds"))

# ── Prepare modelling dataset ─────────────────────────────────────────────────

major_parties <- c("A", "H", "FrP", "SV", "MDG", "R", "V", "KrF", "Sp", "Statsråd")

mdat <- corpus %>%
  filter(party %in% major_parties) %>%
  mutate(
    year_c      = year_start - 2016,          # centre: 2016 = 0
    year_scaled = scale(year_start)[,1],
    party       = fct_relevel(party, "A"),     # Labour = reference
    speech_type = fct_relevel(speech_type, "Hovedinnlegg"),
    has_petroleum = as.integer(has_petroleum),
    has_klima     = as.integer(has_klima)
  )

cat(sprintf("Modelling dataset: %d speeches\n", nrow(mdat)))
cat(sprintf("petroleum = 1: %d (%.1f%%)\n",
            sum(mdat$has_petroleum), mean(mdat$has_petroleum)*100))

# ── Model 1: Year only ────────────────────────────────────────────────────────

m1 <- glm(has_petroleum ~ year_c, data = mdat, family = binomial(link = "logit"))

# ── Model 2: Year + party + speech type ───────────────────────────────────────

m2 <- glm(has_petroleum ~ year_c + party + speech_type,
          data = mdat, family = binomial(link = "logit"))

# ── Model 3: Year × party interaction ────────────────────────────────────────

m3 <- glm(has_petroleum ~ year_c * party + speech_type,
          data = mdat, family = binomial(link = "logit"))

# Robust standard errors (Huber-White sandwich) to account for clustering
coeftest_m2 <- coeftest(m2, vcov = vcovHC(m2, type = "HC3"))
coeftest_m3 <- coeftest(m3, vcov = vcovHC(m3, type = "HC3"))

# ── Model comparison ──────────────────────────────────────────────────────────

anova_12 <- anova(m1, m2, test = "Chisq")
anova_23 <- anova(m2, m3, test = "Chisq")

cat("\n=== Model comparison (LRT) ===\n")
cat("M1 → M2 (adding party + speech_type):\n"); print(anova_12)
cat("M2 → M3 (adding year×party interaction):\n"); print(anova_23)

# ── Extract and tidy Model 2 coefficients ────────────────────────────────────

tidy_m2 <- tidy(m2, conf.int = TRUE, exponentiate = TRUE) %>%
  mutate(
    sig = case_when(
      p.value < 0.001 ~ "***",
      p.value < 0.01  ~ "**",
      p.value < 0.05  ~ "*",
      p.value < 0.1   ~ ".",
      TRUE            ~ ""
    ),
    term_clean = case_when(
      term == "(Intercept)"              ~ "Intercept (A, Hovedinnlegg, 2016)",
      term == "year_c"                   ~ "Year (per year increase)",
      str_starts(term, "party")         ~ paste0("Party: ", str_remove(term, "party")),
      str_starts(term, "speech_type")   ~ paste0("Speech: ", str_remove(term, "speech_type")),
      TRUE ~ term
    )
  )

write_csv(tidy_m2, file.path(OUT_T, "logistic_m2_coefficients.csv"))

cat("\n=== Model 2 Odds Ratios (exponentiated) ===\n")
print(tidy_m2 %>% select(term_clean, estimate, conf.low, conf.high, p.value, sig) %>%
      mutate(across(c(estimate, conf.low, conf.high), ~round(., 3)),
             p.value = round(p.value, 4)))

# ── Predicted probabilities: year effect ─────────────────────────────────────

year_grid <- crossing(
  year_c      = 0:8,       # 2016–2024
  party       = "A",
  speech_type = "Hovedinnlegg"
)
year_grid$year_start <- year_grid$year_c + 2016

pred_year <- predict(m2, newdata = year_grid, type = "response", se.fit = TRUE)
year_grid$prob     <- pred_year$fit
year_grid$prob_lo  <- pred_year$fit - 1.96 * pred_year$se.fit
year_grid$prob_hi  <- pred_year$fit + 1.96 * pred_year$se.fit

# Observed means for comparison
obs_year <- mdat %>%
  filter(party == "A", speech_type == "Hovedinnlegg") %>%
  group_by(year_start) %>%
  summarise(obs_prob = mean(has_petroleum), n = n(), .groups = "drop")

p_year_pred <- ggplot(year_grid, aes(x = year_start)) +
  geom_ribbon(aes(ymin = prob_lo, ymax = prob_hi), fill = "#C0392B", alpha = 0.18) +
  geom_line(aes(y = prob), color = "#C0392B", linewidth = 1.3) +
  geom_point(data = obs_year, aes(y = obs_prob), color = "#2C3E50",
             size = 3, shape = 18) +
  scale_x_continuous(breaks = 2016:2024) +
  scale_y_continuous(labels = scales::percent_format(), limits = c(0, 0.18)) +
  labs(
    title    = "Predicted probability of petroleum mention by year",
    subtitle = "Logistic regression (Model 2) | Reference: Labour, Hovedinnlegg\nRibbon = 95% CI | Points = observed party means",
    x = "Year", y = "P(speech mentions 'petroleum*')",
    caption  = "POLARIS v1.0 | Kalcer Institute, 2026"
  ) +
  theme_minimal(base_family = "Helvetica", base_size = 12) +
  theme(plot.title = element_text(face = "bold"), panel.grid.minor = element_blank())

# ── Predicted probabilities: party effect (controlling for year) ──────────────

party_grid <- crossing(
  year_c      = 4,   # 2020 — midpoint of corpus
  party       = major_parties,
  speech_type = "Hovedinnlegg"
)

pred_party <- predict(m2, newdata = party_grid, type = "response", se.fit = TRUE)
party_grid$prob    <- pred_party$fit
party_grid$prob_lo <- pred_party$fit - 1.96 * pred_party$se.fit
party_grid$prob_hi <- pred_party$fit + 1.96 * pred_party$se.fit

party_colors <- c(
  "A"="#D73E3E","H"="#0070B8","FrP"="#003580","Sp"="#2B8B2B",
  "SV"="#CC0000","MDG"="#5DAC44","R"="#8B0000","V"="#00A651",
  "KrF"="#FFAD00","Statsråd"="#555555"
)

p_party_pred <- party_grid %>%
  mutate(party = fct_reorder(party, prob)) %>%
  ggplot(aes(x = party, y = prob, color = party)) +
  geom_hline(yintercept = predict(m2,
    newdata = data.frame(year_c=4, party="A", speech_type="Hovedinnlegg"),
    type = "response"),
    linetype = "dashed", color = "#888888") +
  geom_linerange(aes(ymin = prob_lo, ymax = prob_hi), linewidth = 1.2) +
  geom_point(size = 4) +
  scale_color_manual(values = party_colors, guide = "none") +
  scale_y_continuous(labels = scales::percent_format()) +
  coord_flip() +
  labs(
    title    = "Party effect on petroleum mention probability (2020, controlled)",
    subtitle = "Logistic regression Model 2 | Controlling for year and speech type\nPoints = predicted probability; bars = 95% CI | Dashed = Labour reference",
    x = NULL, y = "P(mentions 'petroleum*')",
    caption  = "POLARIS v1.0 | Kalcer Institute, 2026"
  ) +
  theme_minimal(base_family = "Helvetica", base_size = 12) +
  theme(plot.title = element_text(face = "bold"), panel.grid.minor = element_blank())

# ── Coefficient plot ──────────────────────────────────────────────────────────

p_coef <- tidy_m2 %>%
  filter(term != "(Intercept)") %>%
  mutate(term_clean = fct_reorder(term_clean, estimate)) %>%
  ggplot(aes(x = term_clean, y = estimate, color = sig != "")) +
  geom_hline(yintercept = 1, linetype = "dashed", color = "#AAAAAA") +
  geom_linerange(aes(ymin = conf.low, ymax = conf.high), linewidth = 1) +
  geom_point(size = 3) +
  geom_text(aes(label = sig), hjust = -0.5, size = 4, color = "#333333") +
  scale_color_manual(values = c("TRUE" = "#C0392B", "FALSE" = "#AAAAAA"),
                     guide = "none") +
  scale_y_log10() +
  coord_flip() +
  labs(
    title    = "Logistic regression: odds ratios for petroleum mention",
    subtitle = "Model 2 (year + party + speech type) | OR on log scale\n* p<.05  ** p<.01  *** p<.001 | Robust SEs (HC3)",
    x = NULL, y = "Odds Ratio (log scale)",
    caption  = "POLARIS v1.0 | Kalcer Institute, 2026"
  ) +
  theme_minimal(base_family = "Helvetica", base_size = 12) +
  theme(plot.title = element_text(face = "bold"), panel.grid.minor = element_blank())

# ── Save ──────────────────────────────────────────────────────────────────────

ggsave(file.path(OUT_F, "INF01_logistic_year_effect.png"),
       p_year_pred, width = 10, height = 6, dpi = 250, bg = "white")
ggsave(file.path(OUT_F, "INF02_logistic_party_effect.png"),
       p_party_pred, width = 9, height = 6, dpi = 250, bg = "white")
ggsave(file.path(OUT_F, "INF03_logistic_coefficients.png"),
       p_coef, width = 10, height = 7, dpi = 250, bg = "white")

# Key inferential result
cat("\n=== KEY INFERENTIAL RESULT ===\n")
year_or <- tidy_m2 %>% filter(str_detect(term, "year_c"))
cat(sprintf("Year effect (OR per year): %.3f [%.3f, %.3f], p = %.4f %s\n",
            year_or$estimate, year_or$conf.low, year_or$conf.high,
            year_or$p.value, year_or$sig))
cat("Interpretation: each additional year reduces the odds of a speech\n")
cat(sprintf("  mentioning petroleum by %.1f%% (holding party and speech type constant)\n",
            (1 - year_or$estimate) * 100))

cat("\nLogistic regression complete. Figures: INF01–03\n")
