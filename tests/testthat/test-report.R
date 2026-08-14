test_that("the report holds every section, the numbers and the plot", {
  skip_if_not_installed("gt")
  x <- foresty_interaction(fy_test_logistic(), exposure = "no2",
                           interaction = "sex")
  file <- fy_temp_html()
  on.exit(unlink(file), add = TRUE)
  foresty_report(x, file = file)

  expect_true(file.exists(file))
  html <- paste(readLines(file, warn = FALSE), collapse = "\n")

  for (section in c("Model", "Interaction", "Subgroup-specific estimates",
                    "Forest plot", "Full coefficient table")) {
    expect_match(html, paste0("<h2>", section), fixed = TRUE)
  }
  expect_match(html, "src=\"data:image/png;base64,", fixed = TRUE)
  expect_match(html, "Ratio of odds ratios", fixed = TRUE)
  # The default test of the interaction, named as what it is.
  expect_match(html, "Likelihood ratio chi-square", fixed = TRUE)
  expect_match(html, "<table", fixed = TRUE)

  # The heading over the test and the table of ratios under it say what the
  # test is a test of, so the test is written as the test and nothing restates
  # the hypothesis.
  expect_false(grepl("term is zero", html, fixed = TRUE))
})

test_that("a report of several models carries each of them", {
  skip_if_not_installed("gt")
  d <- foresty_cohort
  x <- foresty_main(
    list(glm(asthma ~ no2 + sex, family = binomial, data = d),
         glm(asthma ~ black_carbon + sex, family = binomial, data = d)),
    exposure = c("no2", "black_carbon")
  )
  file <- fy_temp_html()
  on.exit(unlink(file), add = TRUE)
  foresty_report(x, file = file)
  html <- paste(readLines(file, warn = FALSE), collapse = "\n")

  # Headed with the exposure each was fitted for, since that is what tells them
  # apart.
  expect_match(html, "<h2>Model: no2", fixed = TRUE)
  expect_match(html, "<h2>Model: black_carbon", fixed = TRUE)
  expect_match(html, "<h2>Full coefficient table: no2", fixed = TRUE)
  expect_match(html, "<h2>Full coefficient table: black_carbon", fixed = TRUE)

  # `model` cuts it down to one, which is then headed as a single model is.
  second <- fy_temp_html()
  on.exit(unlink(second), add = TRUE)
  foresty_report(x, file = second, model = 2)
  only <- paste(readLines(second, warn = FALSE), collapse = "\n")
  expect_match(only, "<h2>Model</h2>", fixed = TRUE)
  expect_false(grepl("no2 +", only, fixed = TRUE))
})

test_that("the report names whichever test was taken", {
  skip_if_not_installed("gt")
  file <- fy_temp_html()
  on.exit(unlink(file), add = TRUE)
  foresty_report(
    foresty_interaction(fy_test_logistic(), exposure = "no2",
                        interaction = "sex", test = "wald"),
    file = file
  )
  expect_match(paste(readLines(file, warn = FALSE), collapse = "\n"),
               "Wald chi-square", fixed = TRUE)
})

test_that("the html argument writes the same report", {
  skip_if_not_installed("gt")
  file <- fy_temp_html()
  on.exit(unlink(file), add = TRUE)
  foresty_interaction(fy_test_logistic(), exposure = "no2",
                      interaction = "sex", html = file)
  expect_true(file.exists(file))
  expect_gt(file.size(file), 10000)
})

test_that("html = TRUE writes the report under the variables' names", {
  skip_if_not_installed("gt")
  dir <- file.path(tempdir(), "foresty-html")
  dir.create(dir, showWarnings = FALSE)
  old <- setwd(dir)
  on.exit({
    setwd(old)
    unlink(dir, recursive = TRUE)
  }, add = TRUE)

  # The exposure and the modifier, joined by an underscore.
  foresty_interaction(fy_test_logistic(), exposure = "no2",
                      interaction = "sex", html = TRUE)
  expect_true(file.exists("no2_sex.html"))

  # A figure with no modifier behind it is named for its exposures alone.
  foresty_main(list(fy_test_logistic()), exposure = "no2", html = TRUE)
  expect_true(file.exists("no2.html"))

  d <- foresty_cohort
  foresty_main(
    list(glm(asthma ~ no2 + sex, family = binomial, data = d),
         glm(asthma ~ black_carbon + sex, family = binomial, data = d)),
    exposure = c("no2", "black_carbon"), html = TRUE
  )
  expect_true(file.exists("no2_black_carbon.html"))

  # FALSE, the default, writes nothing: nothing leaves the session unless it is
  # asked for.
  written <- sort(list.files())
  foresty_interaction(fy_test_logistic(), "no2", "maternal_smoking")
  expect_equal(sort(list.files()), written)

  expect_error(foresty_main(list(fy_test_logistic()), "no2", html = 1),
               "must be TRUE or FALSE")
})

test_that("a list of figures is not a report", {
  d <- foresty_cohort
  figures <- foresty_combine(
    NO2 = foresty_main(list(glm(asthma ~ no2 + sex, family = binomial,
                                data = d)), "no2"),
    `Black carbon` = foresty_main(
      list(glm(asthma ~ black_carbon + sex, family = binomial, data = d)),
      "black_carbon")
  )
  expect_error(foresty_report(figures, file = tempfile()), "one figure at a time")
})

test_that("an extension is added when one is missing", {
  skip_if_not_installed("gt")
  x <- foresty_main(list(fy_test_logistic()), exposure = "no2")
  stem <- tempfile()
  written <- foresty_report(x, file = stem)
  expect_equal(written, paste0(stem, ".html"))
  expect_true(file.exists(written))
  unlink(written)
})

test_that("a report of a linear model reports differences, not ratios", {
  skip_if_not_installed("gt")
  x <- foresty_interaction(fy_test_linear(), exposure = "black_carbon",
                           interaction = "sex")
  file <- fy_temp_html()
  on.exit(unlink(file), add = TRUE)
  foresty_report(x, file = file)
  html <- paste(readLines(file, warn = FALSE), collapse = "\n")

  expect_match(html, "Mean difference", fixed = TRUE)
  expect_match(html, "Difference in effect", fixed = TRUE)
  expect_false(grepl("Odds ratio", html, fixed = TRUE))
})

test_that("only a foresty object can be reported", {
  expect_error(foresty_report(list(a = 1), file = tempfile()),
               "foresty_interaction")
})
