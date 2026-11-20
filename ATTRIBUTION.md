# Attribution

The two response/predictor specifications and diagnostic sequence come from the user-supplied student-performance and employee-satisfaction R coursework scripts. Their byte hashes are preserved in `docs/PROVENANCE.json`; the original files were not changed or bundled with private datasets.

The project uses standard R statistical methods and credits the packages used when their optional functions are executed:

- [R `stats`: linear models](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/lm.html), coefficient intervals, ANOVA, `step`, Shapiro–Wilk and influence measures.
- [CRAN `lmtest`](https://cran.r-project.org/package=lmtest): Breusch–Pagan and Durbin–Watson diagnostics.
- [CRAN `car`](https://cran.r-project.org/package=car): variance-inflation diagnostics.

These libraries are dependencies, not copied vendor source. Their licenses remain their own. No collaborator authorship or blanket rights over the original datasets are inferred. The synthetic fixtures and publication refactor are explicitly separated from empirical research evidence.

The MIT license in this repository covers the newly prepared refactor and invented
software-test fixtures. It does not grant rights over original respondent records,
third-party coursework material or dependency implementations.
