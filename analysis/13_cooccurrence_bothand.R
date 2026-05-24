###############################################################################
# NGDC Analysis — Script 13: The "Both/And" Frame + Fund Naming
# Kalcer Institute | Odri | May 2026
#
# Two analyses:
#
# A. BOTH/AND CO-OCCURRENCE
#    Speeches that name both 'petroleum*' AND 'klima*' in the same text
#    are the most concentrated sites of disavowal — the moment a speaker
#    holds the contradiction explicitly and must manage it in language.
#    What happens in these speeches? How does their rate change over time?
#    What vocabulary frames the co-occurrence?
#
# B. FUND NAMING: Oljefondet vs. SPU
#    The fund has two names:
#    - "Oljefondet" (Oil Fund) — popular name, names the petroleum origin
#    - "Statens pensjonsfond utland" / "SPU" — official name, suppresses it
#    Does parliament use the name that names the oil, or the one that
#    doesn't? How has this shifted over time? This is disavowal at the
#    level of the proper noun.
###############################################################################

library(tidyverse)
library(scales)
library(ggrepel)
library(patchwork)

BASE  <- "/Users/odripads/Desktop/GitHub/ngdc"
OUT_F <- file.path(BASE, "outputs", "figures")
OUT_T <- file.path(BASE, "outputs", "tables")

corpus <- readRDS(file.path(BASE, "outputs", "corpus.rds"))

# ═══════════════════════════════════════════════════════════════════════════════
# A. BOTH/AND CO-OCCURRENCE
# ═══════════════════════════════════════════════════════════════════════════════

corpus <- corpus %>%
  mutate(
    both_petro_klima  = has_petroleum & has_klima,
    both_petro_forny  = has_petroleum & has_fornybar,
    only_petroleum    = has_petroleum & !has_klima & !has_fornybar,
    only_klima        = has_klima & !has_petroleum,
    triple            = has_petroleum & has_klima & has_fornybar
  )

cat("=== BOTH/AND CO-OCCURRENCE ===\n")
cat(sprintf("Both petroleum* AND klima*:    %d speeches (%.1f%% of corpus)\n",
            sum(corpus$both_petro_klima), mean(corpus$both_petro_klima)*100))
cat(sprintf("Both petroleum* AND fornybar*: %d speeches (%.1f%%)\n",
            sum(corpus$both_petro_forny), mean(corpus$both_petro_forny)*100))
cat(sprintf("Triple (petro + klima + forny): %d speeches (%.1f%%)\n",
            sum(corpus$triple), mean(corpus$triple)*100))
cat(sprintf("Only petroleum (no klima/forny): %d speeches (%.1f%%)\n",
            sum(corpus$only_petroleum), mean(corpus$only_petroleum)*100))
cat(sprintf("Only klima (no petroleum): %d speeches (%.1f%%)\n",
            sum(corpus$only_klima), mean(corpus$only_klima)*100))

# ── Temporal trend: both/and rate by session ──────────────────────────────────

bothand_time <- corpus %>%
  group_by(year_start, session_label) %>%
  summarise(
    n              = n(),
    rate_petro     = mean(has_petroleum),
    rate_klima     = mean(has_klima),
    rate_both      = mean(both_petro_klima),
    rate_triple    = mean(triple),
    rate_only_petro = mean(only_petroleum),
    # Conditional: given petroleum is mentioned, how often also klima?
    klima_given_petro = sum(both_petro_klima) / pmax(sum(has_petroleum), 1),
    .groups = "drop"
  )

cat("\n=== Both/and rate over time ===\n")
print(bothand_time %>%
  select(session_label, rate_petro, rate_both, klima_given_petro) %>%
  mutate(across(where(is.numeric), ~round(., 3))))

write_csv(bothand_time, file.path(OUT_T, "bothand_temporal.csv"))

p_bothand <- bothand_time %>%
  pivot_longer(c(rate_petro, rate_both, rate_triple),
               names_to = "type", values_to = "rate") %>%
  mutate(type = recode(type,
    rate_petro  = "Any petroleum* mention",
    rate_both   = "Petroleum* AND klima* (both/and)",
    rate_triple = "Petroleum* AND klima* AND fornybar* (triple)"
  )) %>%
  ggplot(aes(x = year_start, y = rate, color = type, group = type)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2.5) +
  scale_color_manual(values = c(
    "Any petroleum* mention"                        = "#C0392B",
    "Petroleum* AND klima* (both/and)"              = "#8E44AD",
    "Petroleum* AND klima* AND fornybar* (triple)"  = "#27AE60"
  )) +
  scale_y_continuous(labels = percent_format(accuracy = 0.1)) +
  scale_x_continuous(breaks = 2016:2024) +
  labs(
    title    = "The 'both/and' frame: petroleum co-occurring with klima and fornybar",
    subtitle = "Rate of co-occurrence in the same speech | NGDC filtered corpus",
    x = "Session start year", y = "% of corpus speeches",
    color    = NULL,
    caption  = "NGDC v1.0 | Kalcer Institute, 2026"
  ) +
  theme_minimal(base_family = "Helvetica", base_size = 12) +
  theme(
    plot.title    = element_text(face = "bold", size = 14),
    legend.position = "bottom",
    panel.grid.minor = element_blank()
  )

# ── Who produces the "both/and" — party breakdown ─────────────────────────────

major_parties <- c("A","H","FrP","SV","MDG","R","V","KrF","Sp","Statsråd")
party_colors  <- c("A"="#D73E3E","H"="#0070B8","FrP"="#003580","Sp"="#2B8B2B",
                   "SV"="#CC0000","MDG"="#5DAC44","R"="#8B0000","V"="#00A651",
                   "KrF"="#FFAD00","Statsråd"="#555555")

bothand_party <- corpus %>%
  filter(party %in% major_parties) %>%
  group_by(party) %>%
  summarise(
    n = n(),
    rate_both    = mean(both_petro_klima) * 100,
    klima_given_petro = sum(both_petro_klima) / pmax(sum(has_petroleum), 1),
    .groups = "drop"
  ) %>%
  mutate(party = fct_reorder(party, rate_both))

p_bothand_party <- bothand_party %>%
  ggplot(aes(x = party, y = rate_both, fill = party)) +
  geom_col() +
  scale_fill_manual(values = party_colors, guide = "none") +
  coord_flip() +
  scale_y_continuous(labels = function(x) paste0(x, "%")) +
  labs(
    title    = "Both/and speeches by party",
    subtitle = "% of each party's speeches mentioning BOTH petroleum* AND klima*\nThese speeches are the densest sites of managed disavowal",
    x = NULL, y = "% both/and speeches",
    caption  = "NGDC v1.0 | Kalcer Institute, 2026"
  ) +
  theme_minimal(base_family = "Helvetica", base_size = 12) +
  theme(plot.title = element_text(face = "bold"), panel.grid.minor = element_blank())

# ── Sample both/and speeches ──────────────────────────────────────────────────

both_sample <- corpus %>%
  filter(both_petro_klima) %>%
  select(session_label, party, speaker_name, speech_type, speech_text) %>%
  sample_n(min(30, sum(corpus$both_petro_klima)))

write_csv(both_sample, file.path(OUT_T, "bothand_speech_sample.csv"))

# ═══════════════════════════════════════════════════════════════════════════════
# B. FUND NAMING: Oljefondet vs. SPU
# ═══════════════════════════════════════════════════════════════════════════════

corpus <- corpus %>%
  mutate(
    text_lower      = str_to_lower(speech_text),
    mentions_oljefondet = str_detect(text_lower, "oljefondet"),
    mentions_spu        = str_detect(text_lower, "\\bspu\\b|statens pensjonsfond"),
    mentions_nbim       = str_detect(text_lower, "\\bnbim\\b"),
    # Count raw occurrences
    n_oljefondet = str_count(text_lower, "oljefondet"),
    n_spu        = str_count(text_lower, "\\bspu\\b|statens pensjonsfond"),
    n_nbim       = str_count(text_lower, "\\bnbim\\b")
  )

cat("\n\n=== FUND NAMING ===\n")
cat(sprintf("Speeches using 'Oljefondet': %d (%.1f%%)\n",
            sum(corpus$mentions_oljefondet), mean(corpus$mentions_oljefondet)*100))
cat(sprintf("Speeches using 'SPU':         %d (%.1f%%)\n",
            sum(corpus$mentions_spu), mean(corpus$mentions_spu)*100))
cat(sprintf("Speeches using 'NBIM':        %d (%.1f%%)\n",
            sum(corpus$mentions_nbim), mean(corpus$mentions_nbim)*100))
cat(sprintf("\nTotal 'Oljefondet' tokens: %d\n", sum(corpus$n_oljefondet)))
cat(sprintf("Total 'SPU' tokens:         %d\n", sum(corpus$n_spu)))
cat(sprintf("Total 'NBIM' tokens:        %d\n", sum(corpus$n_nbim)))
cat(sprintf("\nOljefondet:SPU ratio (tokens): %.2f\n",
            sum(corpus$n_oljefondet) / max(sum(corpus$n_spu), 1)))

# ── Temporal trend in fund naming ─────────────────────────────────────────────

naming_time <- corpus %>%
  group_by(year_start) %>%
  summarise(
    n_speeches      = n(),
    total_words     = sum(word_count, na.rm = TRUE),
    oljefondet_rate = sum(n_oljefondet) / total_words * 10000,
    spu_rate        = sum(n_spu)        / total_words * 10000,
    nbim_rate       = sum(n_nbim)       / total_words * 10000,
    # Naming share: out of all fund references, what % uses the oil name?
    fund_mentions   = sum(n_oljefondet) + sum(n_spu) + sum(n_nbim),
    oljefondet_share = sum(n_oljefondet) / pmax(fund_mentions, 1),
    .groups = "drop"
  )

write_csv(naming_time, file.path(OUT_T, "fund_naming_temporal.csv"))

cat("\n=== Fund naming over time ===\n")
print(naming_time %>%
  select(year_start, oljefondet_rate, spu_rate, nbim_rate, oljefondet_share) %>%
  mutate(across(where(is.numeric), ~round(., 3))))

p_naming <- naming_time %>%
  pivot_longer(c(oljefondet_rate, spu_rate, nbim_rate),
               names_to = "name", values_to = "rate_per_10k") %>%
  mutate(name = recode(name,
    oljefondet_rate = "'Oljefondet' (Oil Fund — names origin)",
    spu_rate        = "'SPU' / 'Statens pensjonsfond' (suppresses origin)",
    nbim_rate       = "'NBIM' (institutional, suppresses origin)"
  )) %>%
  ggplot(aes(x = year_start, y = rate_per_10k, color = name, group = name)) +
  geom_line(linewidth = 1.3) +
  geom_point(size = 3) +
  scale_color_manual(values = c(
    "'Oljefondet' (Oil Fund — names origin)"       = "#C0392B",
    "'SPU' / 'Statens pensjonsfond' (suppresses origin)" = "#2C3E50",
    "'NBIM' (institutional, suppresses origin)"    = "#7F8C8D"
  )) +
  scale_x_continuous(breaks = 2016:2024) +
  labs(
    title    = "Fund naming in parliament: 'Oljefondet' vs 'SPU/NBIM'",
    subtitle = "Rate per 10,000 words | Does parliament name the oil, or suppress it?\nRed = 'Oil Fund' (names origin) | Dark = official names (suppress origin)",
    x = "Session start year", y = "Rate per 10,000 words",
    color    = NULL,
    caption  = "NGDC v1.0 | Kalcer Institute, 2026"
  ) +
  theme_minimal(base_family = "Helvetica", base_size = 12) +
  theme(
    plot.title    = element_text(face = "bold", size = 14),
    legend.position = "bottom",
    panel.grid.minor = element_blank()
  )

# Share of fund references that use the oil name
p_naming_share <- naming_time %>%
  ggplot(aes(x = year_start, y = oljefondet_share)) +
  geom_ribbon(aes(ymin = 0, ymax = oljefondet_share),
              fill = "#C0392B", alpha = 0.15) +
  geom_line(linewidth = 1.4, color = "#C0392B") +
  geom_point(size = 3.5, color = "#C0392B") +
  geom_label_repel(aes(label = sprintf("%.0f%%", oljefondet_share*100)),
                   size = 3.2, color = "#C0392B", min.segment.length = 0.3) +
  scale_x_continuous(breaks = 2016:2024) +
  scale_y_continuous(labels = percent_format(), limits = c(0, 1)) +
  labs(
    title    = "'Oljefondet' as share of all fund references in Stortinget",
    subtitle = "% of fund mentions (Oljefondet + SPU + NBIM) that use the oil-naming form\nDeclining share = parliament progressively suppresses the oil origin of the fund",
    x = "Session start year",
    y = "Share of fund refs using 'Oljefondet'",
    caption  = "NGDC v1.0 | Kalcer Institute, 2026"
  ) +
  theme_minimal(base_family = "Helvetica", base_size = 12) +
  theme(plot.title = element_text(face = "bold"), panel.grid.minor = element_blank())

# ── Party naming preferences ──────────────────────────────────────────────────

naming_party <- corpus %>%
  filter(party %in% major_parties) %>%
  group_by(party) %>%
  summarise(
    n_oil_name    = sum(n_oljefondet),
    n_official    = sum(n_spu) + sum(n_nbim),
    total_fund    = n_oil_name + n_official,
    oil_share     = n_oil_name / pmax(total_fund, 1),
    .groups = "drop"
  ) %>%
  filter(total_fund >= 10) %>%
  mutate(party = fct_reorder(party, oil_share))

p_naming_party <- naming_party %>%
  ggplot(aes(x = party, y = oil_share, fill = party)) +
  geom_col() +
  scale_fill_manual(values = party_colors, guide = "none") +
  scale_y_continuous(labels = percent_format()) +
  geom_hline(yintercept = 0.5, linetype = "dashed", color = "#AAAAAA") +
  coord_flip() +
  labs(
    title    = "Which parties name the oil?",
    subtitle = "Share of fund references using 'Oljefondet' (vs SPU/NBIM) by party\nAbove 50%: oil-naming dominant | Below 50%: institutional naming dominant",
    x = NULL, y = "Share using 'Oljefondet'",
    caption  = "NGDC v1.0 | Kalcer Institute, 2026"
  ) +
  theme_minimal(base_family = "Helvetica", base_size = 12) +
  theme(plot.title = element_text(face = "bold"), panel.grid.minor = element_blank())

# ── Save ──────────────────────────────────────────────────────────────────────

ggsave(file.path(OUT_F, "FIGURE_G_bothand_temporal.png"),
       p_bothand, width = 11, height = 6, dpi = 250, bg = "white")
ggsave(file.path(OUT_F, "FIGURE_H_bothand_party.png"),
       p_bothand_party, width = 9, height = 6, dpi = 250, bg = "white")
ggsave(file.path(OUT_F, "FIGURE_I_fund_naming.png"),
       p_naming, width = 11, height = 6, dpi = 250, bg = "white")
ggsave(file.path(OUT_F, "FIGURE_J_fund_naming_share.png"),
       p_naming_share, width = 10, height = 6, dpi = 250, bg = "white")
ggsave(file.path(OUT_F, "FIGURE_K_fund_naming_party.png"),
       p_naming_party, width = 9, height = 6, dpi = 250, bg = "white")

cat("\nBoth/and + fund naming analysis complete.\n")
cat("Figures: FIGURE_G through K\n")
