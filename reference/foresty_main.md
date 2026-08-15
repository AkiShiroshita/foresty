# Forest plot of exposure effects across models

Draws the effect of one exposure from each of several fitted models, one
row apiece, so that exposures that were each fitted in their own model
come onto a single figure. None of the models may interact its exposure
with anything; use
[`foresty_interaction()`](https://akishiroshita.github.io/foresty/reference/foresty_interaction.md)
for those.

## Usage

``` r
foresty_main(
  fits,
  exposure,
  measure = NULL,
  exponentiate = TRUE,
  labels = NULL,
  outcome = NULL,
  ci_level = 0.95,
  contrast = NULL,
  at = NULL,
  vcov = NULL,
  cluster = NULL,
  table = TRUE,
  columns = NULL,
  person_time = NULL,
  layout = NULL,
  title = NULL,
  subtitle = NULL,
  xlab = NULL,
  html = FALSE
)
```

## Arguments

- fits:

  A list of fitted models. Models fitted by
  [`stats::glm()`](https://rdrr.io/r/stats/glm.html),
  [`stats::lm()`](https://rdrr.io/r/stats/lm.html) and the `survival`
  package are supported, as is any fit supplying
  [`coef()`](https://rdrr.io/r/stats/coef.html),
  [`vcov()`](https://rdrr.io/r/stats/vcov.html) and a model frame.

- exposure:

  Name of the exposure variable in each model, as a character vector:
  either one name for all of them, or one name per model. Naming an
  element, as `exposure = c(NO2 = "no2")`, gives that variable its label
  on the figure, which saves repeating it in `labels`.

- measure:

  Effect measure, one of `"OR"`, `"RR"`, `"HR"`, `"IRR"`, `"MD"` or
  `"Coefficient"`. The default reads it from the model: a logistic
  regression gives an odds ratio, a Cox model a hazard ratio, a Poisson
  model with an offset an incidence rate ratio, and a linear model a
  mean difference. Ratios are exponentiated; differences are not.

- exponentiate:

  Whether a ratio measure is drawn as a ratio. `TRUE`, the default,
  draws an odds ratio as an odds ratio. `FALSE` leaves it on the scale
  the model was fitted on: the figure reports a log odds ratio, read
  against zero rather than against one, and the estimates and their
  intervals come back on that scale from
  [`tidy()`](https://generics.r-lib.org/reference/tidy.html) as well. It
  says nothing about a mean difference or a coefficient, which are on
  that scale already and are never exponentiated.

- labels:

  Named character vector giving the label to draw for a variable, as
  `c(no2 = "Nitrogen dioxide")`. Names not matched are left as they are.
  This is where the exposure is renamed, and naming it where it is
  chosen – `exposure = c(NO2 = "no2")` – comes to the same thing.

- outcome:

  What to call the outcome, as `outcome = "incident asthma"`. The
  default takes it from the left of the model's formula, which is the
  name of a column – `asthma_ever_dx`, `evt5` – and is rarely what a
  figure should say the effect is an effect on. It is written wherever
  the outcome is named: the axis under the plot, the title the package
  writes for itself, and the HTML report. `NA` names none, leaving
  "Adjusted odds ratio" on its own for a figure whose caption says what
  of.

- ci_level:

  Confidence level of the intervals. Defaults to `0.95`.

- contrast:

  For a continuous exposure, the increment the effect is reported per.
  `NULL`, the default, is one unit and is not written on the figure. An
  increment you name is: `contrast = 10` draws the row as
  `"NO2 (per 10)"` and `contrast = 1` draws it as `"NO2 (per 1)"`, the
  same estimate as the default said out loud. No unit is invented, since
  the package cannot know what a column's numbers mean; name the unit in
  `labels`, as `c(no2 = "NO2, ug/m3")`, and the row reads
  `"NO2, ug/m3 (per 10)"`. `contrast = "iqr"` takes the increment from
  the data instead: the interquartile range of the exposure as the model
  saw it, which is what an exposure with no natural unit is usually
  reported per. The range it came to is written beside the variable, as
  `"NO2 (per IQR, 8.44)"`, because an effect per interquartile range
  cannot be compared with anything unless the figure says which range
  that was. `contrast` says nothing about a categorical exposure, whose
  comparisons are its levels.

- at:

  The two values of the exposure to contrast, as `c(from, to)`. Which
  two they were is written beside the exposure, as `"NO2 (10 -> 20)"`,
  wherever the exposure is named: every row of a figure is that same
  comparison taken within another subgroup, so it is said once rather
  than on each of them. An exposure entered as a spline, or in any other
  way that spreads it over more than one coefficient, has no single
  effect to report and is drawn only when `at` names the two values; any
  other exposure may be given them too, `at` and `contrast` being two
  ways of saying the same thing and only one of them accepted at a time.
  For a categorical exposure the two values are two of its levels.

- vcov:

  Robust standard errors. `NULL`, the default, uses the model's own.
  `"robust"` gives the heteroskedasticity-consistent sandwich estimator
  (`HC1`), and `"HC0"` to `"HC4"` name one exactly; both come from the
  `sandwich` package. A function is called on the fit, and a matrix is
  used as it stands. For a Cox model refit with `robust = TRUE`; a fit
  that is already robust is used as it is.

- cluster:

  Cluster-robust standard errors, passed to
  [`sandwich::vcovCL()`](https://zeileis.codeberg.page/sandwich/reference/vcovCL.html).
  It says which observations belong together, so it takes a column name,
  a vector of one identifier per observation, or a one-sided formula:
  `cluster = "practice_id"`, `cluster = data$practice_id` or
  `cluster = ~practice_id`.

- table:

  Whether to draw the table of numbers beside the plot. Defaults to
  `TRUE`, a forest plot being read from the numbers as much as from the
  marks; `table = FALSE` leaves a plain figure, and
  [`summary()`](https://rdrr.io/r/base/summary.html) and
  [`tidy()`](https://generics.r-lib.org/reference/tidy.html) report the
  same numbers at the console either way.

- columns:

  Which columns the table carries, from `"estimate"`, `"p"`, `"n"`,
  `"events"`, `"person_time"`, `"interaction_p"` and, where both tests
  of an interaction were asked for, `"interaction_p_lrt"`. The default
  shows the estimate and the p-value together with whichever of the
  others the models can supply. On a figure reporting a test of an
  interaction the p-value of each row is left off, being easily read as
  the test beside it; name it in `columns` to have it back.

- person_time:

  The unit person-time is reported in, for a model that carries any.
  `NULL`, the default, reports the total the model was fitted over. A
  number divides by it, so `person_time = 1000` draws a column of
  thousands of person-years and heads it `"Person-time (per 1,000)"`,
  since a count of person-time that does not say what it counts cannot
  be read against another study's. Naming the number heads the column
  outright, as `person_time = c("Person-years (per 1,000)" = 1000)`. The
  unit reaches the figure,
  [`summary()`](https://rdrr.io/r/base/summary.html) and the HTML report
  alike. It does not refit the model or change its estimates, confidence
  intervals, or p-values: `person_time` controls only how the
  person-time column is written.

- layout:

  How the figure is drawn: the name of a style, as `layout = "jama"`, or
  a layout built by
  [`foresty_layout()`](https://akishiroshita.github.io/foresty/reference/foresty_layout.md)
  when something about it has to be changed. The styles are `"classic"`,
  `"jama"`, `"nejm"`, `"lancet"`, `"bmj"` and `"revman"`.

- title:

  Plot title. The default names the measure, the outcome it is a measure
  of, the exposure it is reported for and the fact that the estimate
  comes from a model with no interaction term in it, as
  `"Adjusted odds ratio for asthma associated with NO2, from one model without an interaction term"`.
  `NA` draws none, and the journal styles draw none, a caption being
  where a journal puts that.

- subtitle:

  Plot subtitle. `NULL`, the default, draws none.

- xlab:

  The label under the plot, which by default names the measure and the
  outcome, as `"Adjusted odds ratio for asthma"`. A string is drawn as
  it was given – `xlab = "Odds ratio (95% CI), NO2 per 10 ug/m3"` – and
  `NA` draws none. Renaming only the outcome is what `outcome` is for;
  this replaces the whole line.

- html:

  Whether to write the HTML report – the model it was drawn from, the
  estimates, the figure and the whole coefficient table, on a page that
  is a single file and can be sent on. `FALSE`, the default, writes
  nothing, so nothing leaves the session unless it is asked for. `TRUE`
  writes it to a file named for the exposures it is about, joined by
  underscores where there is more than one, so that a figure of NO2 is
  written to `no2.html` in the working directory. A path writes it there
  instead, as `html = "reports/no2.html"`. The report can also be
  written at any time afterwards with
  [`foresty_report()`](https://akishiroshita.github.io/foresty/reference/foresty_report.md).

## Value

A `ggplot2` object, of class `foresty`, carrying the estimates it was
drawn from. Print it to draw it.
[`summary()`](https://rdrr.io/r/base/summary.html) reports the
coefficients and tests behind it,
[`tidy()`](https://generics.r-lib.org/reference/tidy.html) returns the
estimates as a data frame, and
[`predict()`](https://rdrr.io/r/stats/predict.html) passes through to
the underlying model.

## Details

The effect is the difference between two rows of the model's own design
matrix, one at the baseline value of the exposure and one at the value
it is compared with, so it is read off correctly whether the exposure is
continuous, binary or a factor with several levels, and whatever
contrast coding the fitting function used. The estimate and its
confidence interval are computed by
[`car::linearHypothesis()`](https://rdrr.io/pkg/car/man/linearHypothesis.html).

A categorical exposure gets one row per level, the reference level
included and marked as such, with the levels named on the rows and the
variable named once at the left of the figure.

## A splined exposure

An exposure entered as a spline has no single effect to report: the
difference it makes depends on where along the curve it is taken. So the
two values are named, and the row says which they were:

    fit <- glm(asthma ~ splines::ns(no2, 3) + sex, family = binomial, data = d)
    foresty_main(list(fit), exposure = "no2", at = c(10, 20))

The basis has to be built inside the formula, by
[`splines::ns()`](https://rdrr.io/r/splines/ns.html),
[`splines::bs()`](https://rdrr.io/r/splines/bs.html),
[`stats::poly()`](https://rdrr.io/r/stats/poly.html) or another function
of the variable, so the two design-matrix rows can be evaluated at the
two values.

A basis computed before the fit and entered as columns of its own –
[`Hmisc::rcspline.eval()`](https://rdrr.io/pkg/Hmisc/man/rcspline.eval.html)
written into `spline1`, `spline2`, `spline3` and then fitted as
`y ~ spline1 + spline2 + spline3` – cannot be handled that way, because
nothing in the fit records that those three columns are one variable or
how to recompute them at another value. Name the exposure and the model
refuses, saying that it is not in the model. Put the basis in the
formula instead, which fits exactly the same model:

    knots <- quantile(d$age, probs = c(0.05, 0.35, 0.65, 0.95))
    fit <- glm(y ~ splines::ns(age, 4) + sex, family = binomial, data = d)
    foresty_main(list(fit), exposure = "age", at = c(30, 60))

## Adjusting the figure

The result is a `ggplot2` object, so layers, scales and themes are added
to it as usual, and `+` always reaches the forest:

    foresty_main(list(fit), "no2") + ggplot2::coord_cartesian(xlim = c(0.8, 2))
    foresty_main(list(fit), "no2") + ggplot2::theme_minimal(base_size = 14)

`&` reaches every panel of a figure that has more than one, which is
worth knowing about but rarely what you want: a scale or a coordinate
system applied to the table of numbers beside the plot will spoil it.
Use `+`.

## See also

[`foresty_interaction()`](https://akishiroshita.github.io/foresty/reference/foresty_interaction.md),
[`foresty_layout()`](https://akishiroshita.github.io/foresty/reference/foresty_layout.md),
[`foresty_report()`](https://akishiroshita.github.io/foresty/reference/foresty_report.md).

## Examples

``` r
fit_no2 <- glm(asthma ~ no2 + sex + maternal_smoking + maternal_age,
               family = binomial, data = foresty_cohort)
fit_bc <- glm(asthma ~ black_carbon + sex + maternal_smoking + maternal_age,
              family = binomial, data = foresty_cohort)

foresty_main(
  list(fit_no2, fit_bc),
  exposure = c("no2", "black_carbon"),
  labels = c(no2 = "NO2", black_carbon = "Black carbon")
)


# A categorical exposure: the levels are named, the variable once at the left.
fit_urban <- glm(asthma ~ urbanicity + sex + maternal_age,
                 family = binomial, data = foresty_cohort)
foresty_main(list(fit_urban), exposure = "urbanicity")


# In the layout of a journal, and without the numbers beside the plot.
foresty_main(list(fit_urban), exposure = "urbanicity", layout = "jama")

foresty_main(list(fit_urban), exposure = "urbanicity", table = FALSE)


# Per 10 units of the exposure rather than per 1, which the row says.
foresty_main(list(fit_no2), exposure = "no2", contrast = 10)


# A rate model. The offset is the time each child was followed for, so the
# measure is an incidence rate ratio and the person-time behind each row is
# drawn beside the counts.
fit_rate <- glm(asthma ~ no2 + sex + maternal_age +
                  offset(log(followup_years)),
                family = poisson, data = foresty_cohort)
foresty_main(list(fit_rate), exposure = "no2",
             labels = c(no2 = "NO2"), contrast = 10)


# A splined exposure: the two values being compared are named.
fit_spline <- glm(asthma ~ splines::ns(no2, 3) + sex + maternal_age,
                  family = binomial, data = foresty_cohort)
foresty_main(list(fit_spline), exposure = "no2", at = c(10, 20))


# On the scale the model was fitted on, as a log odds ratio about zero.
foresty_main(list(fit_no2), exposure = "no2", exponentiate = FALSE)


# The exposure, the outcome and the axis all named by hand.
foresty_main(list(fit_no2), exposure = c(`NO2, ug/m3` = "no2"),
             outcome = "incident asthma by age 8",
             xlab = "Adjusted odds ratio (95% CI)")


# Person-time reported per 1,000 rather than as the total.
foresty_main(list(fit_rate), exposure = "no2", person_time = 1000)

```
