# write your script here
# writing an expression
var_1 <- 10 * 5

# loading packages
library(readr)
library(ggplot2)

# loading the monster_jobs dataset
monster_jobs_clean <- read_csv("./scources/monster_jobs_clean.csv")
View(monster_jobs_clean)

# ploting job_id vs salary_min
qplot(data = monster_jobs_clean,
      x = job_id,
      y = salary_min,
      color = job_type)
