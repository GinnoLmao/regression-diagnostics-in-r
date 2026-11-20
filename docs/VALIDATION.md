# Validation record — 20 November 2026

**Runtime:** R 4.6.1 on Windows. `lmtest` and `car` were not installed. The process emitted locale-startup warnings; both validation commands nevertheless exited successfully. No packages were automatically installed.

## Executed checks

`Rscript --vanilla tests/smoke.R` passed:

- Both invented student (n=200) and employee (n=240) workflows fit full and AIC-selected models.
- Finite coefficients, sufficient residual degrees of freedom, confidence-interval table shape and non-increasing AIC were checked.
- Missing-row accounting, unknown-factor rejection, nonnumeric input rejection, required-schema rejection and rank-deficiency rejection were checked.
- Diagnostics operate on their own model rather than a global data-frame variable.
- Durbin–Watson was skipped when meaningful row order was not declared.

`Rscript --vanilla scripts/run_synthetic_demo.R` also completed and wrote both studies' summaries, confidence intervals, sequential ANOVA, influence screening, diagnostic status, notes and four-panel PDF plots. All outputs are in `results/synthetic_demo/` and carry synthetic-only evidence labels.

## Explicitly unexecuted or unavailable

- Breusch–Pagan and VIF/GVIF calls are recorded as `skipped_missing_package`; no values were invented for them.
- Ordered-row Durbin–Watson p-values were not evaluated. The optional package is unavailable and arbitrary row order is not scientifically meaningful.
- Original student/employee CSV rows were not read or copied for this preparation. Original regression coefficients, R² values, p-values, consent and redistribution rights remain unverified.
- No predictive holdout, causal identification or post-selection-adjusted inference was performed.

Synthetic results validate a portable code path; they provide no empirical conclusion about real student performance or employee satisfaction.
