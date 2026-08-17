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

# Asthma severity, for an ordinal outcome. It is drawn from a latent logistic
# variable cut at three fixed thresholds, which is the proportional odds model
# the data are meant to be fitted by: one exposure effect shared by all three
# cutpoints, doubled again in boys, so MASS::polr() has the same interaction to
# find that the binary outcome has.
severity_lp <- 0.045 * (no2 - 18) +
  0.050 * (no2 - 18) * (sex == "Male") +
  0.30 * (sex == "Male") +
  0.40 * (maternal_smoking == "Yes") +
  0.85 * (maternal_asthma == "Yes") +
  0.012 * (maternal_age - 29)
severity_latent <- severity_lp + stats::rlogis(n)
asthma_severity <- cut(
  severity_latent,
  breaks = c(-Inf, 0.3, 1.6, 2.6, Inf),
  labels = c("None", "Mild", "Moderate", "Severe")
)
asthma_severity <- factor(asthma_severity,
                          levels = c("None", "Mild", "Moderate", "Severe"),
                          ordered = TRUE)

# A wheeze phenotype, for a nominal outcome with three unordered levels. The
# two non-reference levels are drawn from their own multinomial logits, and the
# NO2 effect differs between them -- small for the transient phenotype and
# raised in boys for the persistent one -- so the levels cannot be collapsed
# and nnet::multinom() has something an ordinal model would miss.
phenotype_transient <- -0.60 +
  0.030 * (no2 - 18) +
  0.010 * (no2 - 18) * (sex == "Male") +
  0.15 * (sex == "Male") +
  0.30 * (maternal_smoking == "Yes") +
  0.55 * (maternal_asthma == "Yes")
phenotype_persistent <- -1.40 +
  0.040 * (no2 - 18) +
  0.060 * (no2 - 18) * (sex == "Male") +
  0.35 * (sex == "Male") +
  0.45 * (maternal_smoking == "Yes") +
  0.95 * (maternal_asthma == "Yes")
phenotype_odds <- cbind(1, exp(phenotype_transient), exp(phenotype_persistent))
phenotype_probs <- phenotype_odds / rowSums(phenotype_odds)
phenotype_draw <- apply(phenotype_probs, 1L, function(p) {
  sample.int(3L, size = 1L, prob = p)
})
wheeze_phenotype <- factor(
  c("None", "Transient", "Persistent")[phenotype_draw],
  levels = c("None", "Transient", "Persistent")
)

foresty_cohort <- data.frame(
  asthma = asthma,
  asthma_severity = asthma_severity,
  wheeze = wheeze,
  wheeze_phenotype = wheeze_phenotype,
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
