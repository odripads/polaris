###############################################################################
# POLARIS Analysis — Script 08: STM Topic Interpretation
# Kalcer Institute | Odri | May 2026
#
# Takes the converged STM model and produces interpretable outputs:
# - Labelled topic proportion chart
# - Theoretical annotation of each topic
# - Topic × party heatmap
# - Topic × year trend chart
###############################################################################

library(tidyverse)
library(stm)
library(scales)
library(ggrepel)

BASE  <- "/Users/odripads/Desktop/GitHub/ngdc"
OUT_F <- file.path(BASE, "outputs", "figures")
OUT_T <- file.path(BASE, "outputs", "tables")

stm_fit   <- readRDS(file.path(BASE, "outputs", "stm_k10.rds"))
corpus_df <- readRDS(file.path(BASE, "outputs", "corpus.rds"))

# ── Human-readable topic labels ───────────────────────────────────────────────
# Assigned after inspection of FREX terms (see 05_topic_model_stm.R output)

topic_labels <- tibble(
  topic_n   = 1:10,
  label     = c(
    "Petroleum fiscal regime",         # T1: oljepenger, skatter, kr, mrd
    "Welfare state / social services", # T2: elever, skole, helsetjenesten
    "Parliamentary procedure / law",   # T3: departementet, loven, høring
    "Energy transition & industry",    # T4: havvind, vannkraft, fornybar, gass
    "Adversarial floor debate",        # T5: egentlig, synes, tror — unscripted
    "Nynorsk speech register",         # T6: frå, noreg, meir — dialect cluster
    "Climate policy & emissions",      # T7: utslipp, biodrivstoff, klimapolitikk
    "Transport & infrastructure",      # T8: jernbanen, motorveier, bompenger
    "Foreign policy & geopolitics",    # T9: sikkerhetsrådet, EØS, Russland
    "Nature & biodiversity / rural"    # T10: skogen, ulv, jordbruksoppgjøret
  ),
  theoretical_class = c(
    "EXTRACTIVE / FISCAL",
    "WELFARE LEGITIMATION",
    "PROCEDURAL",
    "DISAVOWAL (managed transition)",
    "DISAVOWAL UNDER PRESSURE",
    "REGISTER (not topical)",
    "GREEN IDENTITY PERFORMANCE",
    "EMISSION REDUCTION / TRANSITION",
    "GEOPOLITICAL FRAME",
    "NATURE / LAND"
  ),
  disavowal_relevance = c(
    "High — petroleum framed as state revenue, not extraction",
    "Medium — petroleum revenues fund welfare; cutting them threatens services",
    "Low — procedural",
    "Very High — core managed-transition disavowal site",
    "Very High — unscripted disavowal maintenance under adversarial pressure",
    "Low — dialect marker",
    "High — green identity performance; disavowal's affirmative side",
    "Medium — emission reductions without naming extraction",
    "Medium — energy security legitimates continued extraction post-Ukraine",
    "Low — biodiversity separate from petroleum discourse"
  )
)

write_csv(topic_labels, file.path(OUT_T, "stm_topic_interpretation.csv"))

# ── Topic proportion chart (labelled) ────────────────────────────────────────

prop_df <- tibble(
  topic_n    = 1:10,
  proportion = colMeans(stm_fit$theta)
) %>%
  left_join(topic_labels, by = "topic_n") %>%
  mutate(
    label_full = paste0("T", topic_n, ": ", label),
    label_full = fct_reorder(label_full, proportion),
    fill_color = case_when(
      str_detect(theoretical_class, "DISAVOWAL") ~ "#8E44AD",
      str_detect(theoretical_class, "GREEN")     ~ "#27AE60",
      str_detect(theoretical_class, "EXTRACT")   ~ "#C0392B",
      TRUE                                        ~ "#7F8C8D"
    )
  )

p_topics <- prop_df %>%
  ggplot(aes(x = label_full, y = proportion, fill = fill_color)) +
  geom_col() +
  scale_fill_identity(guide = guide_legend(
    title = "Theoretical class",
    override.aes = list(fill = c("#8E44AD", "#27AE60", "#C0392B", "#7F8C8D")),
    labels = c("Disavowal site", "Green identity", "Extractive/fiscal", "Other")
  )) +
  scale_y_continuous(labels = percent_format()) +
  coord_flip() +
  labs(
    title    = "STM topic structure of the POLARIS corpus (K=10)",
    subtitle = "Topic proportions with theoretical annotation | N = 15,210 speeches\nColour: purple = disavowal site; green = green identity; red = extractive/fiscal",
    x = NULL, y = "Mean topic proportion",
    caption  = "POLARIS v1.0 | Kalcer Institute, 2026"
  ) +
  theme_minimal(base_family = "Helvetica", base_size = 12) +
  theme(
    plot.title    = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 10, color = "#444444", lineheight = 1.3),
    plot.caption  = element_text(size = 9, color = "#888888"),
    panel.grid.minor = element_blank(),
    legend.position = "bottom"
  )

ggsave(file.path(OUT_F, "FIGURE_D_stm_topics.png"),
       p_topics, width = 12, height = 7, dpi = 250, bg = "white")

# ── Topic × party heatmap ─────────────────────────────────────────────────────
# Which topics does each party inhabit? Cross-partisan consistency = disavowal structural

theta_df <- as.data.frame(stm_fit$theta)
colnames(theta_df) <- paste0("T", 1:10)
theta_df$party <- corpus_df$party

party_topic_mean <- theta_df %>%
  filter(party %in% c("A", "H", "FrP", "SV", "MDG", "R", "V", "KrF", "Sp", "Statsråd")) %>%
  group_by(party) %>%
  summarise(across(T1:T10, mean), .groups = "drop") %>%
  pivot_longer(T1:T10, names_to = "topic", values_to = "proportion") %>%
  mutate(
    topic_n = as.integer(str_remove(topic, "T")),
    topic_label = topic_labels$label[topic_n]
  )

p_heatmap <- party_topic_mean %>%
  mutate(
    party = fct_relevel(party, "MDG", "SV", "R", "V", "KrF", "A", "Sp", "H", "FrP", "Statsråd"),
    topic_label = fct_reorder(topic_label, topic_n)
  ) %>%
  ggplot(aes(x = party, y = topic_label, fill = proportion)) +
  geom_tile(color = "white", linewidth = 0.5) +
  geom_text(aes(label = sprintf("%.0f%%", proportion * 100)),
            size = 2.8, color = "white") +
  scale_fill_gradient(low = "#ECF0F1", high = "#2C3E50",
                      labels = percent_format()) +
  labs(
    title    = "Topic distribution by party",
    subtitle = "Mean proportion of each topic in each party's corpus speeches\nOrdered left–right by political position",
    x = "Party ←left | right→", y = NULL,
    fill     = "Topic proportion",
    caption  = "POLARIS v1.0 | Kalcer Institute, 2026"
  ) +
  theme_minimal(base_family = "Helvetica", base_size = 11) +
  theme(
    plot.title    = element_text(face = "bold", size = 13),
    plot.subtitle = element_text(size = 10, color = "#444444"),
    axis.text.x   = element_text(angle = 30, hjust = 1),
    legend.position = "right",
    panel.grid = element_blank()
  )

ggsave(file.path(OUT_F, "FIGURE_E_topic_party_heatmap.png"),
       p_heatmap, width = 13, height = 8, dpi = 250, bg = "white")

# ── Topic × year trend ────────────────────────────────────────────────────────

topic_year <- theta_df %>%
  mutate(year = corpus_df$year_start) %>%
  group_by(year) %>%
  summarise(across(T1:T10, mean), .groups = "drop") %>%
  pivot_longer(T1:T10, names_to = "topic", values_to = "proportion") %>%
  mutate(
    topic_n = as.integer(str_remove(topic, "T")),
    topic_label = topic_labels$label[topic_n],
    class = topic_labels$theoretical_class[topic_n]
  )

# Focus on the theoretically important topics
key_topics <- c("T1", "T4", "T5", "T7")

p_year <- topic_year %>%
  filter(topic %in% key_topics) %>%
  ggplot(aes(x = year, y = proportion, color = topic_label, group = topic_label)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2.5) +
  scale_color_manual(values = c(
    "Petroleum fiscal regime"     = "#C0392B",
    "Energy transition & industry" = "#8E44AD",
    "Adversarial floor debate"    = "#2C3E50",
    "Climate policy & emissions"  = "#27AE60"
  )) +
  scale_x_continuous(breaks = 2016:2024) +
  scale_y_continuous(labels = percent_format()) +
  labs(
    title    = "Key topic proportions over time (STM)",
    subtitle = "Theoretically relevant topics only | Shows shift from fiscal petroleum to transition/climate",
    x = "Session start year", y = "Mean topic proportion",
    color    = NULL,
    caption  = "POLARIS v1.0 | Kalcer Institute, 2026"
  ) +
  theme_minimal(base_family = "Helvetica", base_size = 12) +
  theme(
    plot.title    = element_text(face = "bold", size = 14),
    legend.position = "bottom",
    panel.grid.minor = element_blank()
  )

ggsave(file.path(OUT_F, "FIGURE_F_topic_year_trends.png"),
       p_year, width = 11, height = 6, dpi = 250, bg = "white")

cat("STM interpretation complete.\n\n")
cat("=== TOPIC LABELS WITH THEORETICAL ANNOTATION ===\n")
print(topic_labels %>% select(topic_n, label, theoretical_class, disavowal_relevance) %>%
      mutate(proportion = round(colMeans(stm_fit$theta), 3)) %>%
      arrange(desc(proportion)))
