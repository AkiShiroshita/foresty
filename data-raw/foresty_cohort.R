# Simulates the example cohort shipped as data/foresty_cohort.rda.
#
# The exposure effect is built to differ by child sex and not by maternal
# smoking, so that the package examples can show both the case where an
# interaction is real and the case where it is not.

set.seed(20260813)
n <- 4000

sex <- factor(sample(c("Female", "Male"), n, replace = TRUE),
              levels = c("Female", "Male"))
maternal_smoking <- factor(sample(c("No", "Yes"), n, replace = TRUE,
                                  prob = c(0.82, 0.18)),
                           levels = c("No", "Yes"))
maternal_asthma <- factor(sample(c("No", "Yes"), n, replace = TRUE,
                                 prob = c(0.88, 0.12)),
                          levels = c("No", "Yes"))
urbanicity <- factor(sample(c("Rural", "Suburban", "Urban"), n, replace = TRUE,
                            prob = c(0.25, 0.4, 0.35)),
                     levels = c("Rural", "Suburban", "Urban"))

maternal_age <- round(stats::rnorm(n, mean = 29, sd = 5.5))
maternal_age <- pmin(pmax(maternal_age, 15), 45)
birth_year <- factor(sample(2005:2014, n, replace = TRUE))

# Exposure rises with urbanicity, which is what makes it a confounded
# comparison worth adjusting.
urban_shift <- c(Rural = -3, Suburban = 0, Urban = 4)[as.character(urbanicity)]
no2 <- round(pmax(1, stats::rnorm(n, mean = 18 + urban_shift, sd = 5)), 2)
black_carbon <- round(pmax(0.05, 0.35 + 0.02 * no2 + stats::rnorm(n, 0, 0.25)), 3)

# Asthma. The NO2 effect is roughly doubled in boys and unchanged by maternal
# smoking, though smoking raises the risk on its own.
logit <- -1.9 +
  0.015 * (no2 - 18) +
  0.055 * (no2 - 18) * (sex == "Male") +
  0.30 * (sex == "Male") +
  0.42 * (maternal_smoking == "Yes") +
  0.95 * (maternal_asthma == "Yes") +
  0.010 * (maternal_age - 29) +
  0.18 * (urbanicity == "Urban")
asthma <- stats::rbinom(n, 1, stats::plogis(logit))

# A time to first wheeze episode, so that the same cohort can be used with a
# Cox model.
rate <- exp(-2.4 + 0.018 * (no2 - 18) + 0.035 * (no2 - 18) * (sex == "Male") +
              0.35 * (maternal_asthma == "Yes"))
time_to_event <- stats::rexp(n, rate = rate)
censor <- stats::runif(n, 0.5, 6)
# Floored above zero so that the cohort can also be used with the parametric
# survival models, which reject a survival time of exactly zero.
followup_years <- round(pmax(pmin(time_to_event, censor), 0.01), 3)
wheeze <- as.integer(time_to_event <= censor)

foresty_cohort <- data.frame(
  asthma = asthma,
  wheeze = wheeze,
  followup_years = followup_years,
  no2 = no2,
  black_carbon = black_carbon,
  sex = sex,
  maternal_smoking = maternal_smoking,
  maternal_asthma = maternal_asthma,
  maternal_age = maternal_age,
  birth_year = birth_year,
  urbanicity = urbanicity,
  stringsAsFactors = FALSE
)

usethis::use_data(foresty_cohort, overwrite = TRUE)
