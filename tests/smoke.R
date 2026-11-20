script_arg <- grep("^--file=", commandArgs(), value = TRUE)
root <- dirname(dirname(normalizePath(sub("^--file=", "", script_arg[[1]]))))
source(file.path(root, "R", "diagnostics.R"))
source(file.path(root, "tests", "synthetic_data.R"))
expect_error <- function(expr) stopifnot(inherits(tryCatch({force(expr); NULL}, error = identity), "error"))
for (study in c("student", "employee")) {
  data <- if (study == "student") synthetic_student() else synthetic_employee()
  result <- run_study(data, study, NULL, write_outputs = FALSE)
  stopifnot(nobs(result$full_model) == nrow(data), df.residual(result$full_model) > 1,
    all(is.finite(coef(result$full_model))), AIC(result$selected_model) <= AIC(result$full_model) + 1e-8,
    result$full_diagnostics$durbin_watson$status == "skipped_unordered_rows",
    nrow(coefficient_table(result$full_model)) == length(coef(result$full_model)))
  # Diagnostics use model-owned rows, not a global analysis_data variable.
  stopifnot(length(result$selected_diagnostics$raw_residuals) == nrow(data))
  incomplete <- data
  incomplete[[study_spec(study)$response]][1] <- NA_real_
  stopifnot(prepare_data(incomplete, study)$removed_n == 1L)
}
bad <- synthetic_employee()
bad$Sex[1] <- "unknown"
expect_error(prepare_data(bad, "employee"))
bad <- synthetic_student()
bad$Study_Hours <- "not numeric"
expect_error(prepare_data(bad, "student"))
expect_error(prepare_data(data.frame(unexpected = 1), "student"))
collinear <- synthetic_student()
collinear$Teacher_Support <- collinear$Study_Hours
expect_error(run_study(collinear, "student", NULL, write_outputs = FALSE))
cat("PASS: two synthetic study fits, AIC/CI checks, missingness, category/type/schema and alias guards.\n")
cat("Optional packages: lmtest=", requireNamespace("lmtest", quietly = TRUE),
    "; car=", requireNamespace("car", quietly = TRUE), ". No original-study results reproduced.\n", sep = "")
