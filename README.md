# Regression diagnostics in R

Two exploratory multiple linear regression workflows, organized around student performance and employee satisfaction schemas. The repository preserves the original questions and model terms while replacing machine-specific scripts with a shared, parameterized analysis module.

**Original student/employee records are not distributed.** Their provenance and redistribution rights were not established. The included synthetic fixtures test software behavior; they do not reproduce, replace or substantiate the original studies' findings.

## Questions and methods

| Workflow | Response | Predictors |
|---|---|---|
| Student performance | `Student_Performance` | Study hours, attendance, extracurricular activities, learning resources, teacher support |
| Employee satisfaction | `Emp_Satisfac` | Sex, age group, service-length group, skill group, education group, transformational leadership, organizational climate |

Both workflows fit a full OLS model, report coefficient estimates and 95% confidence intervals, produce a sequential ANOVA table, screen residuals/influence and fit an AIC-selected model using bidirectional `step()`. Full and selected models receive the same diagnostic treatment.

- Base R: Shapiro–Wilk test, Q-Q plot, fitted/residual plot, externally studentized residuals, Cook's distance, confidence intervals and AIC selection.
- Optional `lmtest`: studentized Breusch–Pagan test; Durbin–Watson test only when meaningful row order is explicitly declared.
- Optional `car`: VIF/GVIF. For multi-level factors inspect `GVIF^(1/(2*Df))` and degrees of freedom rather than comparing raw GVIF with numeric-predictor VIF thresholds.

## Setup

R 4.2 or newer is required; base-R checks were executed with **R 4.6.1**. Package installation is an explicit user action, never a script side effect:

```r
# Optional, for the additional BP/DW and VIF/GVIF diagnostics:
install.packages(c("lmtest", "car"), repos = "https://cloud.r-project.org")
```

Missing optional packages produce `skipped_missing_package` entries in `diagnostic_status.csv`. They do not silently produce fabricated test values or abort the base-R workflow.

## Run the verified synthetic demonstration

From this repository's root:

```bash
Rscript --vanilla tests/smoke.R
Rscript --vanilla scripts/run_synthetic_demo.R
```

The synthetic generator contains explicit fixed seeds and known invented formulas. A small, clearly labeled example output is retained in `results/synthetic_demo/`. New runs default to ignored `results/runs/synthetic_<timestamp>/`; an optional first argument selects another new/empty output directory. Existing results are protected from overwrite. See [docs/VALIDATION.md](docs/VALIDATION.md) for actual checks and skipped diagnostics.

## Analyze an authorized dataset

Review [data/README.md](data/README.md) for exact columns and factor levels, and [DATA_SOURCES.md](DATA_SOURCES.md) for the data-rights limitation. Then supply your own authorized CSV and a fresh output directory:

```bash
Rscript --vanilla scripts/run_study.R student /path/to/authorized.csv results/runs/student
Rscript --vanilla scripts/run_study.R employee /path/to/authorized.csv results/runs/employee
```

`scripts/run_student.R` and `scripts/run_employee.R` provide equivalent convenience entry points. Input paths are explicit; there are no embedded local user paths, auto-installs or global workspace clearing commands. `read.csv(..., check.names=TRUE)` converts spaces to periods in column names.

Only use `--ordered` if successive rows represent a meaningful sequence and the assumptions of the serial-correlation test are appropriate. Arbitrary CSV order in a cross-sectional survey does not establish that condition.

Each run writes model summaries, coefficient/CI tables, sequential ANOVA, diagnostic execution status, influence screening and a four-panel diagnostics PDF. Respondent IDs, raw records and response values in flagged rows are not exported. Even aggregate outputs from sensitive data still require disclosure review before sharing.

## Interpretation and limitations

1. Nonsignificant assumption tests do not prove that assumptions hold. Use plots, context and power considerations together.
2. OLS describes conditional associations under its assumptions; this work establishes no causal effect or clinical/employment decision rule.
3. AIC selection and inference use the same observations. Selected-model p-values and intervals are exploratory and do not account for model-selection uncertainty.
4. ANOVA is sequential (Type I): term order affects sums of squares. Coefficient tests condition on the other included terms.
5. Cook's D > 4/n and |studentized residual| > 3 are screening rules, not reasons to delete observations automatically. No rows are removed on those criteria.
6. Complete-case analysis can be biased when missingness is informative; removed-row counts are reported.
7. No held-out prediction evaluation is included. R², coefficients and significance from synthetic examples are not results for the original student/employee populations.

## What changed and credits

The supplied coursework scripts were refactored into `R/diagnostics.R`, preserving their response/predictor specifications and statistical methods. Corrections include explicit inputs, no package auto-installation, no global `analysis_data` dependency inside diagnostics, rejection of unknown factor labels, nonnumeric/infinite-value checks, rank-deficiency guards, protected output directories and honest diagnostic skip states.

Coursework supplied by **Ginno D. Arostique Jr.**, BS Computer Science (AI), West Visayas State University. Publication preparation added shared code and synthetic software checks. No original numerical result or sole authorship of standard statistical methods is claimed. See [ATTRIBUTION.md](ATTRIBUTION.md).
