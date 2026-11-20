# Intentionally invented fixtures for software checks; not original study observations.
synthetic_student <- function(n = 200L) {
  set.seed(20261120)
  data <- data.frame(Study_Hours = runif(n, 1, 10), Attendance_Rate = runif(n, 50, 100),
    Extracurricular_Activities = sample(0:1, n, replace = TRUE), Learning_Resources = runif(n, 1, 5),
    Teacher_Support = runif(n, 1, 5))
  data$Student_Performance <- 20 + 2 * data$Study_Hours + .3 * data$Attendance_Rate +
    data$Teacher_Support + rnorm(n, sd = 4)
  data
}

synthetic_employee <- function(n = 240L) {
  set.seed(20261121)
  spec <- study_spec("employee")
  data <- data.frame(Resp_No = seq_len(n))
  for (variable in names(spec$factors)) data[[variable]] <- rep(spec$factors[[variable]], length.out = n)[sample.int(n)]
  data$Transfo_Lead <- runif(n, 1, 5)
  data$Orga_Climate <- runif(n, 1, 5)
  data$Emp_Satisfac <- 1 + .45 * data$Transfo_Lead + .3 * data$Orga_Climate + rnorm(n, sd = .5)
  data
}
