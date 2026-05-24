###############################################################################
# NGDC Analysis — Script 04: KWIC and Collocation
# Kalcer Institute | Odri | May 2026
#
# KWIC = Keyword In Context. The disavowal thesis predicts:
#   - "petroleum" appears in economic/managerial/technical contexts
#   - "klima" appears in identity-claiming/aspirational/moral contexts
#   - "fornybar" appears in substitution/transition frames
#
# Collocation reveals the semantic fields surrounding each keyword.
# quanteda is used throughout — the gold-standard R corpus analysis package.
###############################################################################

library(tidyverse)
library(quanteda)
library(quanteda.textstats)
library(quanteda.textplots)
library(ggplot2)

BASE  <- "/Users/odripads/Desktop/GitHub/ngdc"
OUT_F <- file.path(BASE, "outputs", "figures")
OUT_T <- file.path(BASE, "outputs", "tables")

corpus_df <- readRDS(file.path(BASE, "outputs", "corpus.rds"))

# ── Build quanteda corpus ─────────────────────────────────────────────────────

cat("Building quanteda corpus...\n")

qcorp <- corpus(
  corpus_df$speech_text,
  docvars = corpus_df %>% select(session_id, year_start, party, speech_type,
                                  speaker_name, word_count, extended_only,
                                  has_petroleum, has_klima)
)
docnames(qcorp) <- paste0("doc_", seq_len(nrow(corpus_df)))

# Tokenise — no stemming (Norwegian morphology is complex; we want raw tokens)
toks <- tokens(qcorp,
               remove_punct = TRUE,
               remove_symbols = TRUE,
               remove_numbers = TRUE,
               remove_separators = TRUE)

# ── Norwegian stopwords (quanteda built-in + custom) ─────────────────────────

no_stop <- c(
  stopwords("no", source = "snowball"),
  "jeg", "det", "er", "og", "at", "en", "til", "av", "som", "på", "for",
  "med", "har", "ikke", "men", "vi", "han", "hun", "de", "et", "om", "så",
  "vil", "kan", "også", "når", "da", "mer", "skal", "bare", "dette",
  "disse", "noe", "seg", "her", "nå", "fra", "etter", "presidenten",
  "representanten", "statsråd", "statsminister", "arbeiderpartiet",
  "høyre", "fremskrittspartiet", "senterpartiet", "sosialistisk",
  "venstrepartiet", "miljøpartiet", "rødt"
)

toks_clean <- tokens_remove(toks, pattern = no_stop, padding = FALSE)

# ── 1. KWIC: 'petroleum' ──────────────────────────────────────────────────────

cat("Running KWIC analysis...\n")

kwic_petro <- kwic(toks, pattern = "petroleum*", window = 8)
kwic_klima <- kwic(toks, pattern = "klima*",    window = 8)
kwic_forny <- kwic(toks, pattern = "fornybar*", window = 8)
kwic_omst  <- kwic(toks, pattern = "omstilling*", window = 8)
kwic_karbf <- kwic(toks, pattern = "karbonfangst*", window = 8)

# Save KWIC tables
write_csv(as.data.frame(kwic_petro), file.path(OUT_T, "kwic_petroleum.csv"))
write_csv(as.data.frame(kwic_klima),  file.path(OUT_T, "kwic_klima.csv"))
write_csv(as.data.frame(kwic_forny),  file.path(OUT_T, "kwic_fornybar.csv"))
write_csv(as.data.frame(kwic_omst),   file.path(OUT_T, "kwic_omstilling.csv"))
write_csv(as.data.frame(kwic_karbf),  file.path(OUT_T, "kwic_karbonfangst.csv"))

cat(sprintf("  petroleum KWIC hits: %d\n", nrow(kwic_petro)))
cat(sprintf("  klima* KWIC hits: %d\n",    nrow(kwic_klima)))
cat(sprintf("  fornybar* KWIC hits: %d\n", nrow(kwic_forny)))

# ── 2. Collocations: what words appear near 'petroleum'? ─────────────────────

cat("Computing collocations...\n")

# Collocations within +/- 5 tokens
col_petro <- tokens_select(toks_clean, pattern = "petroleum*", selection = "keep",
                            window = 5) %>%
  dfm() %>%
  dfm_trim(min_termfreq = 3) %>%
  textstat_frequency()

col_klima <- tokens_select(toks_clean, pattern = "klima*", selection = "keep",
                            window = 5) %>%
  dfm() %>%
  dfm_trim(min_termfreq = 5) %>%
  textstat_frequency()

col_forny <- tokens_select(toks_clean, pattern = c("fornybar*", "bærekraft*"), selection = "keep",
                            window = 5) %>%
  dfm() %>%
  dfm_trim(min_termfreq = 3) %>%
  textstat_frequency()

write_csv(col_petro %>% head(60), file.path(OUT_T, "collocates_petroleum.csv"))
write_csv(col_klima  %>% head(60), file.path(OUT_T, "collocates_klima.csv"))
write_csv(col_forny  %>% head(60), file.path(OUT_T, "collocates_fornybar.csv"))

# ── 3. FCM (Feature Co-occurrence Matrix) ─────────────────────────────────────

cat("Building feature co-occurrence matrix...\n")

# Keep only the theoretically important terms for FCM
key_terms <- c("petroleum*", "olje*", "klima*",
               "fornybar*", "bærekraft*", "omstilling*", "utslipp*",
               "karbonfangst*", "oljefondet*", "nbim*", "energi*",
               "grønn*", "vekst*", "ansvar*", "eksport*", "fond*")

# Build FCM, then select only to key terms for a plottable network
fcm_full <- fcm(toks_clean, context = "window", window = 5, tri = FALSE)
# Resolve wildcards to actual vocabulary
key_feat  <- featnames(dfm_select(dfm(toks_clean), pattern = key_terms))
fcm_key   <- fcm_select(fcm_full, pattern = key_feat, valuetype = "fixed")
cat(sprintf("  FCM after selection: %d x %d\n", nrow(fcm_key), ncol(fcm_key)))

# FCM network plot — shows the co-occurrence structure
png(file.path(OUT_F, "fig10_fcm_network.png"), width = 1400, height = 1000, res = 150)
tryCatch({
  textplot_network(fcm_key,
                   min_freq    = 0.7,
                   edge_alpha  = 0.5,
                   edge_color  = "#AAAAAA",
                   vertex_labelsize = 3,
                   edge_size   = 3)
  title(main = "Key term co-occurrence network | NGDC filtered corpus",
        sub  = "Kalcer Institute, 2026")
}, error = function(e) {
  plot.new()
  text(0.5, 0.5, paste("FCM network error:", conditionMessage(e)), cex = 0.8)
})
dev.off()

# ── 4. Collocation comparison plots ──────────────────────────────────────────

theme_bar <- function() {
  theme_minimal(base_family = "Helvetica", base_size = 11) +
    theme(plot.title = element_text(size = 13, face = "bold"),
          plot.subtitle = element_text(size = 10, color = "#555555"),
          panel.grid.minor = element_blank(),
          panel.grid.major.y = element_blank(),
          legend.position = "none")
}

# Top 25 collocates of 'petroleum' (excluding the obvious stopwords)
p_col_petro <- col_petro %>%
  filter(!feature %in% c(no_stop, "petroleum", "olje", "klima")) %>%
  head(25) %>%
  mutate(feature = fct_reorder(feature, frequency)) %>%
  ggplot(aes(x = feature, y = frequency)) +
  geom_col(fill = "#C0392B") +
  coord_flip() +
  labs(
    title    = "Top collocates of 'petroleum'",
    subtitle = "Words appearing within ±5 tokens of 'petroleum' | NGDC corpus",
    x = NULL, y = "Co-occurrence frequency",
    caption  = "NGDC | Kalcer Institute, 2026"
  ) +
  theme_bar()

p_col_klima <- col_klima %>%
  filter(!feature %in% c(no_stop, "klima", "klimaendring", "klimapolitikk")) %>%
  head(25) %>%
  mutate(feature = fct_reorder(feature, frequency)) %>%
  ggplot(aes(x = feature, y = frequency)) +
  geom_col(fill = "#27AE60") +
  coord_flip() +
  labs(
    title    = "Top collocates of 'klima*'",
    subtitle = "Words appearing within ±5 tokens of 'klima' | NGDC corpus",
    x = NULL, y = "Co-occurrence frequency",
    caption  = "NGDC | Kalcer Institute, 2026"
  ) +
  theme_bar()

ggsave(file.path(OUT_F, "fig11_collocates_petroleum.png"),
       p_col_petro, width = 8, height = 7, dpi = 200, bg = "white")
ggsave(file.path(OUT_F, "fig12_collocates_klima.png"),
       p_col_klima, width = 8, height = 7, dpi = 200, bg = "white")

# ── 5. Keyness: which terms distinguish petroleum speeches from non-petroleum?─

cat("Running keyness analysis...\n")

dfmat <- dfm(toks_clean)
dfmat <- dfm_trim(dfmat, min_termfreq = 10)

# Add petroleum flag as docvar
dfmat$target <- corpus_df$has_petroleum

keyness <- textstat_keyness(dfmat, target = dfmat$target == TRUE)
write_csv(keyness %>% head(100), file.path(OUT_T, "keyness_petroleum_speeches.csv"))

p_key <- textplot_keyness(keyness, n = 25,
                           color = c("#C0392B", "#2C3E50"))
ggsave(file.path(OUT_F, "fig13_keyness_petroleum.png"),
       p_key, width = 9, height = 7, dpi = 200, bg = "white")

cat("\nCollocation/KWIC analysis complete.\n")
cat("Outputs in outputs/tables/ and outputs/figures/\n")
cat("\nTop 15 petroleum collocates:\n")
print(col_petro %>% filter(!feature %in% c(no_stop, "petroleum")) %>% head(15))
cat("\nTop 15 klima collocates:\n")
print(col_klima %>% filter(!feature %in% c(no_stop, "klima")) %>% head(15))
