# Agreement across model classes. These are the tests that matter most: the
# same data fitted two ways has to give the same subgroup estimates, whatever
# the fitting function chose to call its coefficients.

expect_same_result <- function(a, b, tolerance = 1e-6, p_tolerance = 1e-4) {
  expect_equal(fy_est(a)$estimate, fy_est(b)$estimate, tolerance = tolerance)
  expect_equal(fy_est(a)$se, fy_est(b)$se, tolerance = tolerance)
  # The p-value is compared more loosely than the estimate it came from. Two
  # functions that fit the same model by different algorithms agree on the
  # coefficients to more figures than they do out in the tail of the
  # distribution, and that difference is theirs rather than foresty's.
  expect_equal(fy_test(a)$p.value, fy_test(b)$p.value,
               tolerance = p_tolerance)
}

test_that("glm and rms::lrm agree", {
  skip_if_not_installed("rms")
  d <- foresty_cohort
  a <- foresty_interaction(
    glm(asthma ~ no2 + sex + maternal_age, family = binomial, data = d),
    exposure = "no2", interaction = "sex"
  )
  b <- foresty_interaction(
    rms::lrm(asthma ~ no2 + sex + maternal_age, data = d),
    exposure = "no2", interaction = "sex"
  )
  expect_same_result(a, b)
})

test_that("survival::coxph and rms::cph agree", {
  skip_if_not_installed("rms")
  skip_if_not_installed("survival")
  d <- foresty_cohort
  a <- foresty_interaction(
    survival::coxph(survival::Surv(followup_years, wheeze) ~ no2 + sex, data = d),
    exposure = "no2", interaction = "sex"
  )
  b <- foresty_interaction(
    rms::cph(survival::Surv(followup_years, wheeze) ~ no2 + sex, data = d),
    exposure = "no2", interaction = "sex"
  )
  expect_same_result(a, b, tolerance = 1e-3, p_tolerance = 0.05)
})

test_that("lm and rms::ols agree", {
  skip_if_not_installed("rms")
  d <- foresty_cohort
  a <- foresty_interaction(
    lm(no2 ~ black_carbon + sex, data = d),
    exposure = "black_carbon", interaction = "sex"
  )
  b <- foresty_interaction(
    rms::ols(no2 ~ black_carbon + sex, data = d),
    exposure = "black_carbon", interaction = "sex"
  )
  expect_same_result(a, b)
})

test_that("the effect measure is read from the model", {
  d <- foresty_cohort
  expect_equal(fy_model_info(fy_test_logistic())$measure, "OR")
  expect_equal(fy_model_info(fy_test_linear())$measure, "MD")
  expect_equal(
    fy_model_info(glm(asthma ~ no2, family = poisson(link = "log"), data = d))$measure,
    "RR"
  )
  skip_if_not_installed("survival")
  expect_equal(
    fy_model_info(survival::coxph(
      survival::Surv(followup_years, wheeze) ~ no2, data = d
    ))$measure,
    "HR"
  )
})

test_that("a supplied measure overrides the one read from the model", {
  x <- foresty_main(list(fy_test_logistic()), exposure = "no2", measure = "Coefficient")
  expect_equal(fy_result(x)$measure, "Coefficient")
  expect_false(fy_result(x)$exponentiate)
  expect_lt(fy_est(x)$estimate, 0.5)
})

test_that("a ratio can be left on the scale it was fitted on", {
  fit <- fy_test_logistic()
  ratio <- fy_est(foresty_main(list(fit), exposure = "no2"))
  logged <- foresty_main(list(fit), exposure = "no2", exponentiate = FALSE)
  est <- fy_est(logged)

  # The same estimate, before it was exponentiated.
  expect_equal(est$estimate, log(ratio$estimate), tolerance = 1e-10)
  expect_equal(est$conf.low, log(ratio$conf.low), tolerance = 1e-10)
  expect_equal(est$se, ratio$se, tolerance = 1e-10)
  expect_equal(est$p.value, ratio$p.value, tolerance = 1e-10)

  # It is still an odds ratio, still referred to a normal rather than a t, and
  # the figure says which scale it is drawn on.
  expect_equal(fy_result(logged)$measure, "OR")
  expect_false(fy_result(logged)$exponentiate)
  expect_equal(fy_infos(logged)[[1L]]$error_df, Inf)
  expect_match(fy_result(logged)$measure_label, "^Log odds ratio for asthma")
  expect_match(gsub("\n", " ", fy_title(logged), fixed = TRUE),
               "^Adjusted log odds ratio for asthma")

  # The subgroup estimates of an interaction figure go the same way.
  by_sex <- foresty_interaction(fit, exposure = "no2", interaction = "sex",
                                exponentiate = FALSE)
  expect_equal(
    fy_est(by_sex)$estimate,
    log(fy_est(foresty_interaction(fit, exposure = "no2",
                                   interaction = "sex"))$estimate),
    tolerance = 1e-10
  )

  # `exponentiate = TRUE` is the default, and it means "as the measure asks".
  # A mean difference is on that scale already, so it is drawn as a difference
  # either way rather than as the exponential of one.
  linear <- foresty_main(list(fy_test_linear()), exposure = "black_carbon")
  expect_false(fy_result(linear)$exponentiate)
  expect_equal(
    fy_est(foresty_main(list(fy_test_linear()), exposure = "black_carbon",
                        exponentiate = TRUE))$estimate,
    fy_est(linear)$estimate
  )
  expect_equal(
    fy_est(foresty_main(list(fy_test_linear()), exposure = "black_carbon",
                        exponentiate = FALSE))$estimate,
    fy_est(linear)$estimate
  )

  # And the two scales cannot be drawn against one axis.
  expect_error(
    foresty_combine(foresty_main(list(fit), exposure = "no2"), by_sex),
    "some of the figures report a ratio"
  )
})

test_that("estimates survive a Cox model and count its events", {
  skip_if_not_installed("survival")
  fit <- survival::coxph(
    survival::Surv(followup_years, wheeze) ~ no2 + sex + maternal_asthma,
    data = foresty_cohort
  )
  x <- foresty_interaction(fit, exposure = "no2", interaction = "sex")
  expect_equal(fy_result(x)$measure, "HR")
  expect_true(all(is.finite(fy_est(x)$estimate)))
  expect_equal(sum(fy_est(x)$events), sum(foresty_cohort$wheeze))
  expect_equal(sum(fy_est(x)$n), nrow(foresty_cohort))
})

test_that("a covariate entered as a spline does not disturb the exposure", {
  d <- foresty_cohort
  plain <- foresty_interaction(
    glm(asthma ~ no2 + sex + maternal_age, family = binomial, data = d),
    exposure = "no2", interaction = "sex"
  )
  splined <- foresty_interaction(
    glm(asthma ~ no2 + sex + splines::ns(maternal_age, 3),
        family = binomial, data = d),
    exposure = "no2", interaction = "sex"
  )
  # Not identical, since the models differ, but the same to within a hair.
  expect_length(fy_est(splined)$estimate, 2L)
  expect_equal(fy_est(plain)$estimate, fy_est(splined)$estimate,
               tolerance = 0.01)

  skip_if_not_installed("rms")
  # rms has to be attached for rcs() to be found when the model is fitted, as
  # it would be in any script that uses it.
  library(rms)
  rms_fit <- foresty_interaction(
    rms::lrm(asthma ~ no2 + sex + rcs(maternal_age, 4), data = d),
    exposure = "no2", interaction = "sex"
  )
  expect_equal(fy_est(rms_fit)$estimate, fy_est(splined)$estimate,
               tolerance = 0.01)
})

test_that("lme4 fits of both kinds are supported, and are tested by ML", {
  skip_if_not_installed("lme4")
  d <- foresty_cohort
  d$site <- factor(rep(seq_len(20), length.out = nrow(d)))

  # A linear mixed model, whose measure is a mean difference.
  linear <- lme4::lmer(no2 ~ black_carbon + sex + (1 | site), data = d)
  x <- foresty_interaction(linear, exposure = "black_carbon",
                           interaction = "sex")
  expect_equal(fy_result(x)$measure, "MD")
  expect_length(fy_est(x)$estimate, 2L)
  expect_true(all(is.finite(fy_est(x)$se)))

  # A REML likelihood belongs to the fixed effects it was computed under, so
  # the test is taken over the same models refitted by maximum likelihood,
  # which is what lme4's own anova() does.
  reference <- stats::anova(
    lme4::lmer(no2 ~ black_carbon + sex + (1 | site), data = d),
    lme4::lmer(no2 ~ black_carbon * sex + (1 | site), data = d)
  )
  expect_equal(fy_test(x)$p.value, reference[["Pr(>Chisq)"]][2],
               tolerance = 1e-6)

  # And a generalized one, whose measure is an odds ratio.
  logistic <- lme4::glmer(asthma ~ no2 + sex + (1 | site), family = binomial,
                          data = d)
  y <- foresty_interaction(logistic, exposure = "no2", interaction = "sex")
  expect_equal(fy_result(y)$measure, "OR")
  expect_equal(
    fy_test(y)$p.value,
    stats::anova(
      logistic,
      lme4::glmer(asthma ~ no2 * sex + (1 | site), family = binomial, data = d)
    )[["Pr(>Chisq)"]][2],
    tolerance = 1e-6
  )
})
