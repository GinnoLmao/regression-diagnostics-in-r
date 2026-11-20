# Input schema (no original records included)

Column names below are those expected after base R's `check.names=TRUE` normalization.

**Student:** numeric `Student_Performance`, `Study_Hours`, `Attendance_Rate`, `Extracurricular_Activities`, `Learning_Resources`, `Teacher_Support`. The original numeric-predictor specification is preserved; the extracurricular variable's coding/scale must be checked against the actual data dictionary before substantive interpretation.

**Employee:** identifier `Resp_No` (not a predictor), numeric `Emp_Satisfac`, `Transfo_Lead`, `Orga_Climate`, and these factors in reference-first order:

| Column | Allowed levels |
|---|---|
| `Sex` | Female; Male |
| `Age` | 20-30; 31-40; 41-50; 51 and above |
| `Length.of.Service` | Less than a year; 1-3 years; 4-6 years; More than 6 years |
| `Skill` | Beginner; Intermediate; Advanced |
| `Educational.Attainment` | College Graduate; Post-graduate Masters; Post-graduate Doctorate |

Unknown categories cause an error instead of silently turning into missing values. Missing model values are removed by complete-case selection and counted. IDs are not included in fitting or output tables. Predictor scales and substantive coding should be verified with the data owner; this schema is not an endorsement of demographic modeling for real-world decisions.

Place authorized data outside the repository or in this ignored directory. Review all new outputs before publishing them.
