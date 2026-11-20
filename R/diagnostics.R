# Shared regression diagnostics refactored from the supplied coursework scripts.
# No package installation, workspace clearing, network requests or data reads at source time.

study_spec <- function(study) {
  if (identical(study, "student")) {
    return(list(response = "Student_Performance", id = NULL,
      predictors = c("Study_Hours", "Attendance_Rate", "Extracurricular_Activities",
                     "Learning_Resources", "Teacher_Support"), factors = list()))
  }
  if (identical(study, "employee")) {
    return(list(response = "Emp_Satisfac", id = "Resp_No",
      predictors = c("Sex", "Age", "Length.of.Service", "Skill", "Educational.Attainment",
                     "Transfo_Lead", "Orga_Climate"),
      factors = list(Sex = c("Female", "Male"),
        Age = c("20-30", "31-40", "41-50", "51 and above"),
        Length.of.Service = c("Less than a year", "1-3 years", "4-6 years", "More than 6 years"),
        Skill = c("Beginner", "Intermediate", "Advanced"),
        Educational.Attainment = c("College Graduate", "Post-graduate Masters", "Post-graduate Doctorate"))))
  }
  stop("study must be student or employee")
}

prepare_data <- function(data, study) {
  spec <- study_spec(study)
  required <- c(spec$id, spec$response, spec$predictors)
  missing <- setdiff(required, names(data))
  if (length(missing)) stop("Missing required columns: ", paste(missing, collapse = ", "))
  data <- data[, required, drop = FALSE]
  # Validate before factor conversion: unknown labels must not silently become NA.
  for (variable in names(spec$factors)) {
    values <- as.character(data[[variable]])
    unknown <- setdiff(unique(values[!is.na(values)]), spec$factors[[variable]])
    if (length(unknown)) stop("Unrecognized category in ", variable, "; review labels against the documented schema")
    data[[variable]] <- factor(values, levels = spec$factors[[variable]])
  }
  numeric_variables <- setdiff(c(spec$response, spec$predictors), names(spec$factors))
  for (variable in numeric_variables) {
    if (!is.numeric(data[[variable]])) stop(variable, " must be numeric; no silent coercion is performed")
    if (any(!is.finite(data[[variable]]) & !is.na(data[[variable]]))) stop(variable, " contains infinite values")
  }
  complete <- complete.cases(data[, c(spec$response, spec$predictors), drop = FALSE])
  removed <- sum(!complete)
  source_rows <- which(complete)
  data <- droplevels(data[complete, , drop = FALSE])
  if (!nrow(data)) stop("No complete observations remain")
  list(data = data, spec = spec, source_rows = source_rows,
       input_n = length(complete), removed_n = removed)
}

check_model <- function(model) {
  if (anyNA(coef(model))) stop("Rank-deficient model: review redundant predictors or empty factor combinations")
  if (df.residual(model) <= 1) stop("Too few residual degrees of freedom for diagnostics")
  if (!is.finite(summary(model)$sigma) || summary(model)$sigma < sqrt(.Machine$double.eps)) {
    stop("Residual variation is too small for reliable studentized diagnostics")
  }
  invisible(TRUE)
}

package_test <- function(package, expr) {
  if (!requireNamespace(package, quietly = TRUE)) {
    return(list(status = "skipped_missing_package", detail = paste("Optional package", package, "not installed"), result = NULL))
  }
  tryCatch(list(status = "executed", detail = "", result = force(expr)),
           error = function(e) list(status = "failed", detail = conditionMessage(e), result = NULL))
}

diagnose_model <- function(model, ordered = FALSE) {
  check_model(model)
  residual <- residuals(model)
  studentized <- rstudent(model)
  cooks <- cooks.distance(model)
  n <- nobs(model)
  shapiro <- if (n >= 3 && n <= 5000) {
    list(status = "executed", detail = "Residual normality test; nonsignificance does not prove normality", result = shapiro.test(residual))
  } else list(status = "skipped_sample_size", detail = "Shapiro-Wilk requires 3 to 5000 observations", result = NULL)
  bp <- package_test("lmtest", lmtest::bptest(model))
  dw <- if (isTRUE(ordered)) package_test("lmtest", lmtest::dwtest(model, alternative = "two.sided")) else {
    list(status = "skipped_unordered_rows", detail = "No meaningful row order declared; DW would depend on arbitrary CSV order", result = NULL)
  }
  terms_n <- length(attr(terms(model), "term.labels"))
  vif <- if (terms_n >= 2) package_test("car", car::vif(model)) else {
    list(status = "skipped_fewer_than_two_terms", detail = "VIF/GVIF is not informative for an intercept-only or single-term model", result = NULL)
  }
  flagged <- which(cooks > 4 / n | abs(studentized) > 3)
  list(shapiro_wilk = shapiro, breusch_pagan = bp, durbin_watson = dw, vif = vif,
    raw_residuals = residual, fitted = fitted(model), studentized_residuals = studentized,
    cooks_distance = cooks, flagged_rows = flagged, cook_cutoff = 4 / n,
    durbin_watson_statistic = sum(diff(residual)^2) / sum(residual^2))
}

coefficient_table <- function(model) {
  estimates <- coef(summary(model))
  intervals <- confint(model, level = 0.95)
  data.frame(term = rownames(estimates), estimate = estimates[, 1], standard_error = estimates[, 2],
    t_value = estimates[, 3], p_value = estimates[, 4], ci_lower = intervals[, 1], ci_upper = intervals[, 2], row.names = NULL)
}

diagnostic_status <- function(diagnostics) {
  keys <- c("shapiro_wilk", "breusch_pagan", "durbin_watson", "vif")
  do.call(rbind, lapply(keys, function(key) {
    entry <- diagnostics[[key]]
    result <- entry$result
    data.frame(diagnostic = key, status = entry$status, detail = entry$detail,
      statistic = if (inherits(result, "htest")) unname(result$statistic) else NA_real_,
      p_value = if (inherits(result, "htest")) result$p.value else NA_real_)
  }))
}

write_diagnostic_outputs <- function(model, diagnostics, directory, label) {
  dir.create(directory, recursive = TRUE, showWarnings = FALSE)
  write.csv(coefficient_table(model), file.path(directory, "coefficients.csv"), row.names = FALSE)
  write.csv(as.data.frame(anova(model)), file.path(directory, "anova_sequential.csv"))
  write.csv(diagnostic_status(diagnostics), file.path(directory, "diagnostic_status.csv"), row.names = FALSE)
  capture.output(summary(model), file = file.path(directory, "model_summary.txt"))
  if (!is.null(diagnostics$vif$result)) {
    capture.output(diagnostics$vif$result, file = file.path(directory, "vif.txt"))
  }
  # Source row indices only; no respondent IDs, response values or raw observations are exported.
  flagged <- diagnostics$flagged_rows
  influence <- data.frame(analysis_row = flagged,
    studentized_residual = diagnostics$studentized_residuals[flagged],
    cooks_distance = diagnostics$cooks_distance[flagged])
  write.csv(influence, file.path(directory, "influence_screening.csv"), row.names = FALSE)
  pdf(file.path(directory, "diagnostics.pdf"), width = 9, height = 7)
  on.exit(dev.off(), add = TRUE)
  par(mfrow = c(2, 2))
  qqnorm(diagnostics$studentized_residuals, main = paste(label, "Q-Q plot"), pch = 19, cex = .5)
  qqline(diagnostics$studentized_residuals, col = "firebrick")
  plot(diagnostics$fitted, diagnostics$studentized_residuals, xlab = "Fitted", ylab = "Studentized residual", main = "Residuals vs fitted", pch = 19, cex = .5)
  abline(h = 0, col = "firebrick", lty = 2)
  lines(lowess(diagnostics$fitted, diagnostics$studentized_residuals), col = "steelblue")
  plot(diagnostics$cooks_distance, type = "h", main = "Cook's distance", xlab = "Analysis row", ylab = "Cook's D")
  abline(h = diagnostics$cook_cutoff, col = "firebrick", lty = 2)
  plot(diagnostics$studentized_residuals, main = "Studentized residual screening", xlab = "Analysis row", ylab = "Residual", pch = 19, cex = .5)
  abline(h = c(-3, 3), col = "firebrick", lty = 2)
}

run_study <- function(data, study, output_dir, ordered = FALSE, label = "user-supplied data", write_outputs = TRUE) {
  prepared <- prepare_data(data, study)
  spec <- prepared$spec
  formula <- reformulate(spec$predictors, response = spec$response)
  full <- lm(formula, data = prepared$data, na.action = na.fail)
  check_model(full)
  selected <- step(full, scope = list(lower = ~1, upper = formula), direction = "both", k = 2, trace = 0)
  check_model(selected)
  full_diagnostics <- diagnose_model(full, ordered)
  selected_diagnostics <- diagnose_model(selected, ordered)
  if (write_outputs) {
    if (dir.exists(output_dir) && length(list.files(output_dir, all.files = TRUE, no.. = TRUE))) {
      stop("Output directory is not empty; choose a new run directory to preserve prior results")
    }
    dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
    write_diagnostic_outputs(full, full_diagnostics, file.path(output_dir, "full"), paste(study, "full model"))
    write_diagnostic_outputs(selected, selected_diagnostics, file.path(output_dir, "aic_selected"), paste(study, "AIC-selected model"))
    writeLines(c(paste("Study:", study), paste("Evidence label:", label),
      paste("Input rows:", prepared$input_n), paste("Complete rows:", nrow(prepared$data)),
      paste("Dropped missing rows:", prepared$removed_n), paste("Meaningful order declared:", ordered),
      paste("Full formula:", deparse(formula)), paste("Selected formula:", deparse(formula(selected))),
      "Selection and inference use the same data; post-selection p-values/CIs are exploratory.",
      "No causal or held-out predictive performance claim is made."), file.path(output_dir, "RUN_NOTES.txt"))
    capture.output(sessionInfo(), file = file.path(output_dir, "sessionInfo.txt"))
  }
  invisible(list(full_model = full, selected_model = selected, prepared = prepared,
                 full_diagnostics = full_diagnostics, selected_diagnostics = selected_diagnostics))
}
