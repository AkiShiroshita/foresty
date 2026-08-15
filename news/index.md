# Changelog

## foresty 0.0.1

First release.

### Features

- [`foresty_app()`](https://akishiroshita.github.io/foresty/reference/foresty_app.md)
  provides a Shiny interface for interactively selecting exposures,
  modifiers, contrasts, colours, and plot layouts.
- [`foresty_main()`](https://akishiroshita.github.io/foresty/reference/foresty_main.md)
  creates forest plots for exposure effects from fitted models.
- [`foresty_interaction()`](https://akishiroshita.github.io/foresty/reference/foresty_interaction.md)
  estimates exposure effects within levels of a modifier, tests the
  interaction, and displays the results in a forest plot.
- [`foresty_combine()`](https://akishiroshita.github.io/foresty/reference/foresty_combine.md)
  combines overall and subgroup results into a single forest plot.
- Supports [`glm()`](https://rdrr.io/r/stats/glm.html),
  [`lm()`](https://rdrr.io/r/stats/lm.html), `survival` models, and
  `lme4` models, with robust and cluster-robust standard errors through
  `sandwich`.
- Supports categorical and continuous exposures, including spline terms
  and contrasts between specified exposure values.
- Effects can be reported per specified increments or per interquartile
  range using `contrast`.
- Interaction tests can use Wald, likelihood ratio, or both tests. GEE
  and quasi-likelihood models use the Wald test.
- Results are returned as `ggplot2` objects and can be further
  customized with standard `ggplot2` syntax.
- Forest plot layouts can be customized through
  [`foresty_layout()`](https://akishiroshita.github.io/foresty/reference/foresty_layout.md),
  with predefined styles including `"classic"`, `"jama"`, `"nejm"`,
  `"lancet"`, `"bmj"`, and `"revman"`.
- [`foresty_report()`](https://akishiroshita.github.io/foresty/reference/foresty_report.md)
  and the `html` argument provide self-contained HTML reports containing
  the model results, interaction tests, coefficient tables, and forest
  plots.
- Results can be exported as PNG or SVG figures and as `.rds` objects.
- [`summary()`](https://rdrr.io/r/base/summary.html),
  [`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html),
  [`broom::tidy()`](https://generics.r-lib.org/reference/tidy.html),
  [`broom::glance()`](https://generics.r-lib.org/reference/glance.html),
  [`coef()`](https://rdrr.io/r/stats/coef.html),
  [`vcov()`](https://rdrr.io/r/stats/vcov.html),
  [`predict()`](https://rdrr.io/r/stats/predict.html),
  [`formula()`](https://rdrr.io/r/stats/formula.html), and
  [`nobs()`](https://rdrr.io/r/stats/nobs.html) are supported for
  foresty results.
