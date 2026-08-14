test_that("a Cox model reports the person-time behind each subgroup", {
  skip_if_not_installed("survival")
  d <- foresty_cohort
  fit <- survival::coxph(
    survival::Surv(followup_years, wheeze) ~ no2 + sex, data = d
  )
  est <- fy_est(foresty_interaction(fit, exposure = "no2", interaction = "sex"))

  expect_true(all(is.finite(est$person_time)))
  expect_equal(sum(est$person_time), sum(d$followup_years), tolerance = 1e-8)
  expect_equal(est$person_time[1],
               sum(d$followup_years[d$sex == "Female"]), tolerance = 1e-8)
})

test_that("a counting-process outcome measures the interval, not the stop time", {
  skip_if_not_installed("survival")
  d <- foresty_cohort
  d$start <- 0.25
  fit <- survival::coxph(
    survival::Surv(start, followup_years, wheeze) ~ no2 + sex,
    data = d[d$followup_years > 0.25, ]
  )
  info <- fy_model_info(fit)
  kept <- d[d$followup_years > 0.25, ]
  expect_equal(info$person_time, sum(kept$followup_years - 0.25),
               tolerance = 1e-8)
})

test_that("a Poisson model with an offset reports rates and person-time", {
  d <- foresty_cohort
  set.seed(1)
  d$follow_up <- stats::runif(nrow(d), 1, 5)
  fit <- glm(asthma ~ no2 + sex + offset(log(follow_up)),
             family = poisson, data = d)

  # An offset is what makes a Poisson model a rate model, so its ratio is an
  # incidence rate ratio rather than a risk ratio.
  expect_equal(fy_model_info(fit)$measure, "IRR")

  est <- fy_est(foresty_interaction(fit, exposure = "no2", interaction = "sex"))
  expect_equal(sum(est$person_time), sum(d$follow_up), tolerance = 1e-6)
  expect_equal(est$person_time[1], sum(d$follow_up[d$sex == "Female"]),
               tolerance = 1e-6)
})

test_that("a Poisson model without an offset reports risk and no person-time", {
  fit <- glm(asthma ~ no2 + sex, family = poisson, data = foresty_cohort)
  expect_equal(fy_model_info(fit)$measure, "RR")
  expect_true(is.na(fy_est(foresty_main(list(fit), exposure = "no2"))$person_time))
})

test_that("a model with no time at all reports none", {
  est <- fy_est(foresty_main(list(fy_test_logistic()), exposure = "no2"))
  expect_true(is.na(est$person_time))
})
