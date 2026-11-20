# Usage from repository root:
# Rscript scripts/run_study.R student authorized.csv results/runs/student [--ordered]
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 3 || !(args[[1]] %in% c("student", "employee"))) {
  stop("Usage: Rscript scripts/run_study.R student|employee INPUT.csv NEW_OUTPUT_DIR [--ordered]")
}
script_arg <- grep("^--file=", commandArgs(), value = TRUE)
script <- normalizePath(sub("^--file=", "", script_arg[[1]]), mustWork = TRUE)
root <- dirname(dirname(script))
source(file.path(root, "R", "diagnostics.R"))
input <- read.csv(args[[2]], fileEncoding = "UTF-8-BOM", check.names = TRUE)
run_study(input, args[[1]], args[[3]], ordered = "--ordered" %in% args,
          label = "user-supplied data; publication permission is the caller's responsibility")
cat("Completed exploratory diagnostics. Inspect diagnostic_status.csv for executed/skipped/failed tests.\n")
