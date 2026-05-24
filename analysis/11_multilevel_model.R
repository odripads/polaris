###############################################################################
# POLARIS Inferential Analysis — Script 11: Multilevel / Mixed-Effects Model
# Kalcer Institute | Odri | May 2026
#
# Speeches are not independent — they cluster within:
#   - Sessions (shared political context)
#   - Parties (shared institutional voice)
#   - Speakers (individual rhetorical patterns)
#
# A mixed-effects logistic regression with random intercepts for party and
# session gives more honest standard errors AND decomposes the variance:
# how much of the variation in petroleum mention is between parties, between
# sessions, and between individual speeches?
#
# High between-session variance, low between-party variance = the YEAR
# effect is real; the PARTY effect is weak relative to shared context.
# This is the structural argument made statistically rigorous.
#
# Model: has_petroleum ~ year_c + speech_type + (1|party) + (1|session_id)
###############################################################################

library(tidyverse)
library(lme4)
library(broom.mixed)
library(ggrepel)

BASE  <- "/Users/odripads/Desktop/GitHub/ngdc"
OUT_F <- file.path(BASE, "outputs", "figures")
OUT_T <- file.path(BASE, "outputs", "tables")

corpus <- readRDS(file.path(BASE, "outputs", "corpus.rds"))

major_parties <- c("A","H","FrP","SV","MDG","R","V","KrF","Sp","Statsråd")

mdat <- corpus %>%
  filter(party %in% major_parties) %>%
  mutate(
    year_c      = year_start - 2016,
    has_petroleum = as.integer(has_petroleum),
    has_klima     = as.integer(has_klima),
    speech_type = fct_relevel(speech_type, "Hovedinnlegg")
  )

cat(sprintf("Multilevel dataset: %d speeches\n", nrow(mdat)))

# ── Model A: Random intercept for party + session ─────────────────────────────

cat("Fitting Model A: year + speech_type + (1|party) + (1|session_id)...\n")
mA <- glmer(
  has_petroleum ~ year_c + speech_type + (1 | party) + (1 | session_id),
  data   = mdat,
  family = binomial(link = "logit"),
  control = glmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 2e5))
)
cat("Model A fitted.\n")

# ── Model B: Add speaker random effect (most honest) ─────────────────────────

cat("Fitting Model B: year + speech_type + (1|party) + (1|session_id) + (1|speaker_name)...\n")
mB <- glmer(
  has_petroleum ~ year_c + speech_type +
    (1 | party) + (1 | session_id) + (1 | speaker_name),
  data   = mdat,
  family = binomial(link = "logit"),
  control = glmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 2e5))
)
cat("Model B fitted.\n")

# ── Variance decomposition ────────────────────────────────────────────────────
# ICC = intraclass correlation: how much variance is attributable to grouping?

extract_icc <- function(model, label) {
  vc <- as.data.frame(VarCorr(model))
  total_var <- sum(vc$vcov) + (pi^2 / 3)  # logistic residual variance
  vc %>%
    filter(!is.na(vcov)) %>%
    mutate(
      model = label,
      icc   = vcov / total_var,
      pct   = icc * 100
    ) %>%
    select(model, group = grp, variance = vcov, icc, pct)
}

icc_A <- extract_icc(mA, "Model A (party + session)")
icc_B <- extract_icc(mB, "Model B (party + session + speaker)")

cat("\n=== Variance Decomposition (ICC) ===\n")
cat("\nModel A:\n"); print(icc_A %>% mutate(across(where(is.numeric), ~round(., 4))))
cat("\nModel B:\n"); print(icc_B %>% mutate(across(where(is.numeric), ~round(., 4))))

write_csv(bind_rows(icc_A, icc_B), file.path(OUT_T, "multilevel_icc.csv"))

# ── Fixed effects ──────────────────────────────────────────────────────────────

tidy_mB <- tidy(mB, conf.int = TRUE, exponentiate = TRUE,
                effects = "fixed") %>%
  mutate(
    sig = case_when(
      p.value < 0.001 ~ "***", p.value < 0.01 ~ "**",
      p.value < 0.05 ~ "*",   p.value < 0.1 ~ ".",
      TRUE ~ ""
    ),
    term_clean = case_when(
      term == "(Intercept)"            ~ "Intercept (2016, Hovedinnlegg)",
      term == "year_c"                 ~ "Year (per year increase)",
      str_starts(term, "speech_type") ~ paste0("Speech: ", str_remove(term, "speech_type")),
      TRUE ~ term
    )
  )

write_csv(tidy_mB, file.path(OUT_T, "multilevel_fixed_effects.csv"))

cat("\n=== Fixed Effects (Model B, OR) ===\n")
print(tidy_mB %>% select(term_clean, estimate, conf.low, conf.high, p.value, sig) %>%
      mutate(across(c(estimate, conf.low, conf.high), ~round(., 3)),
             p.value = round(p.value, 4)))

# ── Random effects: party-level intercepts ────────────────────────────────────
# These show how much each party deviates from the grand mean AFTER
# controlling for year and speech type. Small values = cross-partisan similarity.

re_party <- ranef(mB)$party %>%
  as.data.frame() %>%
  rownames_to_column("party") %>%
  rename(re_intercept = `(Intercept)`) %>%
  mutate(
    prob_deviation = plogis(re_intercept) - 0.5,  # approx deviation in probability
    party = fct_reorder(party, re_intercept)
  )

write_csv(re_party, file.path(OUT_T, "multilevel_party_random_effects.csv"))

party_colors <- c(
  "A"="#D73E3E","H"="#0070B8","FrP"="#003580","Sp"="#2B8B2B",
  "SV"="#CC0000","MDG"="#5DAC44","R"="#8B0000","V"="#00A651",
  "KrF"="#FFAD00","Statsråd"="#555555"
)

p_re_party <- re_party %>%
  ggplot(aes(x = party, y = re_intercept, fill = party)) +
  geom_col() +
  geom_hline(yintercept = 0, linetype = "dashed") +
  scale_fill_manual(values = party_colors, guide = "none") +
  coord_flip() +
  labs(
    title    = "Party-level random effects (log-odds deviation from grand mean)",
    subtitle = "Model B: has_petroleum ~ year + speech_type + (1|party) + (1|session) + (1|speaker)\nControlling for year and speech type — residual party-level variation",
    x = NULL, y = "Random intercept (log-odds)",
    caption  = "POLARIS v1.0 | Kalcer Institute, 2026"
  ) +
  theme_minimal(base_family = "Helvetica", base_size = 12) +
  theme(plot.title = element_text(face = "bold"), panel.grid.minor = element_blank())

# ── Session-level random effects ──────────────────────────────────────────────

re_session <- ranef(mB)$session_id %>%
  as.data.frame() %>%
  rownames_to_column("session_id") %>%
  rename(re_intercept = `(Intercept)`) %>%
  mutate(year = as.integer(str_sub(session_id, 1, 4)))

p_re_session <- re_session %>%
  ggplot(aes(x = year, y = re_intercept)) +
  geom_col(fill = "#8E44AD", alpha = 0.8) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  scale_x_continuous(breaks = 2016:2024) +
  labs(
    title    = "Session-level random effects (log-odds deviation)",
    subtitle = "After controlling for year trend — residual session-level context effects",
    x = "Session start year", y = "Random intercept (log-odds)",
    caption  = "POLARIS v1.0 | Kalcer Institute, 2026"
  ) +
  theme_minimal(base_family = "Helvetica", base_size = 12) +
  theme(plot.title = element_text(face = "bold"), panel.grid.minor = element_blank())

# ── Variance decomposition plot ────────────────────────────────────────────────

p_icc <- icc_B %>%
  mutate(
    group = recode(group,
      party        = "Party",
      session_id   = "Session (year)",
      speaker_name = "Speaker (individual)"
    ),
    group = fct_reorder(group, pct)
  ) %>%
  ggplot(aes(x = group, y = pct, fill = group)) +
  geom_col() +
  scale_fill_manual(values = c(
    "Party"              = "#C0392B",
    "Session (year)"     = "#8E44AD",
    "Speaker (individual)" = "#2980B9"
  ), guide = "none") +
  geom_text(aes(label = sprintf("%.1f%%", pct)), vjust = -0.3, size = 4) +
  labs(
    title    = "Variance decomposition: what explains petroleum mention rates?",
    subtitle = "ICC from mixed-effects logistic regression (Model B)\nRemainder = individual speech-level variation (unexplained)",
    x = NULL, y = "% of total variance",
    caption  = "POLARIS v1.0 | Kalcer Institute, 2026"
  ) +
  theme_minimal(base_family = "Helvetica", base_size = 12) +
  theme(plot.title = element_text(face = "bold"), panel.grid.minor = element_blank())

# ── Save ──────────────────────────────────────────────────────────────────────

ggsave(file.path(OUT_F, "INF06_multilevel_party_re.png"),
       p_re_party, width = 9, height = 6, dpi = 250, bg = "white")
ggsave(file.path(OUT_F, "INF07_multilevel_session_re.png"),
       p_re_session, width = 10, height = 5, dpi = 250, bg = "white")
ggsave(file.path(OUT_F, "INF08_variance_decomposition.png"),
       p_icc, width = 9, height = 6, dpi = 250, bg = "white")

cat("\n=== KEY STRUCTURAL CLAIM RESULT ===\n")
cat("If disavowal is STRUCTURAL (not party-driven), party-level ICC should be\n")
cat("low relative to session-level ICC (which captures shared context).\n\n")
cat(sprintf("Party ICC:   %.1f%% of variance\n", icc_B$pct[icc_B$group == "party"]))
cat(sprintf("Session ICC: %.1f%% of variance\n", icc_B$pct[icc_B$group == "session_id"]))
cat(sprintf("Speaker ICC: %.1f%% of variance\n", icc_B$pct[icc_B$group == "speaker_name"]))
cat("\nMultilevel model complete. Figures: INF06–08\n")
