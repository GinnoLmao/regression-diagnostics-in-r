script_arg <- grep("^--file=", commandArgs(), value = TRUE)
root <- dirname(dirname(normalizePath(sub("^--file=", "", script_arg[[1]]))))
source(file.path(root, "R", "diagnostics.R"))
source(file.path(root, "tests", "synthetic_data.R"))
args <- commandArgs(trailingOnly = TRUE)
output <- if (length(args)) args[[1]] else file.path(root, "results", "runs", paste0("synthetic_", format(Sys.time(), "%Y%m%d_%H%M%S")))
for (study in c("student", "employee")) {
  data <- if (study == "student") synthetic_student() else synthetic_employee()
  run_study(data, study, file.path(output, study), label = "SYNTHETIC SOFTWARE DEMONSTRATION; not original research findings")
}
cat("Synthetic-only demonstration saved in the selected new output directory.\n")
