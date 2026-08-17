# Changelog

## foresty 0.0.1

First release.

### Features

- [`foresty_app()`](https://akishiroshita.github.io/foresty/reference/foresty_app.md)
  provides a Shiny interface for interactively selecting exposures,
  modifiers, contrasts, colors, and plot layouts. Its R code tab writes
  the code twice over: the `foresty` calls that drew the figures, and
  the same estimates worked out in base R and the `car` package with
  nothing from this package in them – the interaction term, the linear
  combination of the coefficients each subgroup estimate is, and the
  joint test beside it. For a multinomial fit that linear combination is
  a difference of blocks of coefficients, one block per equation, and
  the script writes that out too.
- [`foresty_data()`](https://akishiroshita.github.io/foresty/reference/foresty_data.md)
  draws the same figure – the forest plot and the table of numbers
  beside it, aligned row for row, in any of the journal styles – from
  estimates you already have: a `data.frame`, `tibble` or `data.table`
  with one row per row of the figure. It is the entry point for numbers
  that did not come out of a model this package can read: a
  meta-analysis, a table being redrawn from a paper, a model fitted by
  something else.
- Supports [`glm()`](https://rdrr.io/r/stats/glm.html),
  [`lm()`](https://rdrr.io/r/stats/lm.html), `survival` models, and
  `lme4` models, with robust and cluster-robust standard errors through
  `sandwich`.
- Supports ordinal outcomes through
  [`MASS::polr()`](https://rdrr.io/pkg/MASS/man/polr.html) and nominal
  outcomes through
  [`nnet::multinom()`](https://rdrr.io/pkg/nnet/man/multinom.html). A
  multinomial fit holds one equation per non-reference level of the
  outcome, so the figure carries one row per level. `outcome_reference`
  says which level they are all read against and `outcome_reference_row`
  draws that level as a row of its own. The interaction is tested
  jointly across the equations, so its p-value is a chunk test spending
  one degree of freedom for each coefficient the interaction added.
- Supports categorical and continuous exposures, including spline terms
  and contrasts between specified exposure values.
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
