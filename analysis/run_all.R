###############################################################################
# POLARIS — Run all analysis scripts in sequence
# Kalcer Institute | Odri | May 2026
#
# Usage:  Rscript analysis/run_all.R
# Time:   ~10-15 minutes (STM takes longest)
###############################################################################

scripts <- c(
  "analysis/01_corpus_build.R",
  "analysis/02_temporal_trends.R",
  "analysis/03_party_analysis.R",
  "analysis/04_kwic_collocation.R",
  "analysis/05_topic_model_stm.R",
  "analysis/06_cross_institutional.R",
  "analysis/07_findings_synthesis.R",
  "analysis/08_stm_interpret.R"
)

for (s in scripts) {
  cat(sprintf("\n=== Running: %s ===\n", s))
  tryCatch(
    source(s, local = new.env()),
    error = function(e) cat(sprintf("ERROR in %s: %s\n", s, conditionMessage(e)))
  )
}

cat("\n=== All scripts complete ===\n")
cat("Figures: outputs/figures/\n")
cat("Tables:  outputs/tables/\n")
cat("Summary: outputs/ANALYSIS_FINDINGS.md\n")
