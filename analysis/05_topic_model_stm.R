###############################################################################
# NGDC Analysis — Script 05: Structural Topic Model (STM)
# Kalcer Institute | Odri | May 2026
#
# STM (Roberts et al. 2019) is ideal here because it allows covariates —
# we can ask: how do topics VARY by year and party? Unlike plain LDA,
# STM can show that the same underlying semantic structure (disavowal)
# is produced differently across institutional positions.
#
# We model K=10 topics on the filtered corpus (15,210 speeches).
# The theoretical question: do topics cluster around petroleum (extractivist)
# vs climate (green identity) vs transition (disavowal-as-management)?
###############################################################################

library(tidyverse)
library(stm)
library(quanteda)
library(ggrepel)

BASE  <- "/Users/odripads/Desktop/GitHub/ngdc"
OUT_F <- file.path(BASE, "outputs", "figures")
OUT_T <- file.path(BASE, "outputs", "tables")

corpus_df <- readRDS(file.path(BASE, "outputs", "corpus.rds"))

cat("Preparing corpus for STM...\n")

# ── Preprocessing ─────────────────────────────────────────────────────────────

no_stop <- unique(c(
  stopwords("no", source = "snowball"),
  stopwords("no", source = "stopwords-iso"),
  # explicit high-freq Norwegian function words (incl. Nynorsk variants)
  "jeg", "det", "er", "og", "at", "en", "til", "av", "som", "på", "for",
  "med", "har", "ikke", "men", "vi", "han", "hun", "de", "et", "om", "så",
  "vil", "kan", "også", "når", "da", "mer", "skal", "bare", "dette",
  "disse", "noe", "seg", "her", "nå", "fra", "etter",
  "å", "på", "er", "og", "i", "av", "til", "en", "et", "de",
  "men", "for", "med", "om", "som", "det", "vi", "at", "at",
  "jo", "ja", "nei", "så", "nå", "da", "der", "den", "dem",
  "sin", "sitt", "sine", "deg", "meg", "ham", "henne", "oss",
  "dere", "alle", "mye", "lite", "mange", "noen", "ingen",
  "blitt", "hadde", "har", "have", "ble", "blir", "var", "er",
  "være", "vært", "gjøre", "gjort", "gjør",
  # Nynorsk
  "ei", "frå", "det", "dei", "den", "eit", "av", "til",
  # institutional boilerplate
  "presidenten", "representanten", "representant", "statsråd",
  "statsminister", "hr", "spm", "stortinget", "nr", "st"
))

qcorp <- corpus(corpus_df$speech_text,
                docvars = corpus_df %>%
                  select(year_start, party, speech_type, word_count))

toks <- tokens(qcorp, remove_punct = TRUE, remove_numbers = TRUE,
               remove_symbols = TRUE) %>%
  tokens_remove(no_stop, padding = FALSE) %>%
  tokens_tolower()

dfmat <- dfm(toks) %>%
  dfm_trim(min_termfreq = 10, min_docfreq = 5)

cat(sprintf("DFM: %d documents × %d features\n", nrow(dfmat), ncol(dfmat)))

# Convert to STM format
stm_input <- convert(dfmat, to = "stm")

# Metadata
meta <- corpus_df %>%
  select(year_start, party, speech_type) %>%
  mutate(
    year_scaled = scale(year_start)[,1],
    is_minister = as.integer(party == "Statsråd"),
    is_frp      = as.integer(party == "FrP"),
    is_left     = as.integer(party %in% c("SV", "MDG", "R")),
    speech_main = as.integer(speech_type == "Hovedinnlegg")
  )

# ── Fit STM K=10 ─────────────────────────────────────────────────────────────
# Prevalence formula: how does topic proportion vary with year and party type?

cat("Fitting STM (K=10)... this takes ~2-5 minutes\n")

set.seed(42)
stm_fit <- stm(
  documents = stm_input$documents,
  vocab     = stm_input$vocab,
  K         = 10,
  prevalence = ~ year_scaled + is_minister + is_frp + is_left,
  data      = meta,
  init.type = "Spectral",
  verbose   = TRUE
)

saveRDS(stm_fit, file.path(BASE, "outputs", "stm_k10.rds"))
cat("STM model saved.\n")

# ── Topic summaries ───────────────────────────────────────────────────────────

topic_labels <- labelTopics(stm_fit, n = 10)
cat("\n=== Topic Labels (FREX — most distinctive terms) ===\n")
for (k in 1:10) {
  cat(sprintf("Topic %02d: %s\n", k,
              paste(topic_labels$frex[k,], collapse = ", ")))
}

# Top 10 FREX terms per topic — save as table
frex_df <- as.data.frame(topic_labels$frex)
colnames(frex_df) <- paste0("term_", 1:ncol(frex_df))
frex_df$topic <- paste0("Topic_", 1:10)
write_csv(frex_df, file.path(OUT_T, "stm_topic_labels.csv"))

# Prevalence by topic
topic_prop <- colMeans(stm_fit$theta)
prop_df <- tibble(
  topic     = paste0("Topic ", 1:10),
  proportion = topic_prop,
  frex_top3 = apply(topic_labels$frex[, 1:3], 1, paste, collapse = " / ")
) %>% arrange(desc(proportion))

write_csv(prop_df, file.path(OUT_T, "stm_topic_proportions.csv"))

# ── Topic proportion plot ─────────────────────────────────────────────────────

p_prop <- prop_df %>%
  mutate(label = sprintf("%s\n(%s)", topic, frex_top3),
         label = fct_reorder(label, proportion)) %>%
  ggplot(aes(x = label, y = proportion)) +
  geom_col(fill = "#2C3E50") +
  scale_y_continuous(labels = scales::percent_format()) +
  coord_flip() +
  labs(
    title    = "STM topic proportions (K=10)",
    subtitle = "Top FREX terms shown | NGDC filtered corpus (N=15,210 speeches)",
    x = NULL, y = "Mean topic proportion",
    caption  = "NGDC | Kalcer Institute, 2026"
  ) +
  theme_minimal(base_family = "Helvetica", base_size = 11) +
  theme(plot.title = element_text(face = "bold"))

ggsave(file.path(OUT_F, "fig14_stm_topic_proportions.png"),
       p_prop, width = 11, height = 7, dpi = 200, bg = "white")

# ── Effect estimates: how topics vary by year and party ────────────────────────

cat("Estimating topic prevalence effects...\n")

effects <- estimateEffect(
  formula  = 1:10 ~ year_scaled + is_minister + is_frp + is_left,
  stmobj   = stm_fit,
  metadata = meta,
  uncertainty = "Global"
)

# Year effects: which topics are growing/shrinking?
year_effects <- summary(effects, topics = 1:10)

# Plot year effect for each topic
png(file.path(OUT_F, "fig15_stm_year_effects.png"),
    width = 1400, height = 900, res = 150)
plot(effects, covariate = "year_scaled",
     topics = 1:10,
     model  = stm_fit,
     method = "continuous",
     xlab   = "Year (scaled)",
     main   = "Topic prevalence over time (STM year effect)")
dev.off()

# FrP vs Left comparison
png(file.path(OUT_F, "fig16_stm_frp_vs_left.png"),
    width = 1200, height = 800, res = 150)
plot(effects,
     covariate = "is_frp",
     topics    = 1:10,
     model     = stm_fit,
     method    = "difference",
     cov.value1 = 1, cov.value2 = 0,
     xlab      = "← Left bloc more  |  FrP more →",
     main      = "Topic prevalence: FrP vs. rest of corpus",
     labeltype = "frex")
dev.off()

cat("\nSTM analysis complete.\n")
cat("\nTopic proportions:\n")
print(prop_df)
