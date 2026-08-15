# foresty 0.0.1

First release.

## Features

* `foresty_app()` provides a Shiny interface for interactively selecting exposures, modifiers, contrasts, colours, and plot layouts.
* `foresty_main()` creates forest plots for exposure effects from fitted models.
* `foresty_interaction()` estimates exposure effects within levels of a modifier, tests the interaction, and displays the results in a forest plot.
* `foresty_combine()` combines overall and subgroup results into a single forest plot.
* Supports `glm()`, `lm()`, `survival` models, and `lme4` models, with robust and cluster-robust standard errors through `sandwich`.
* Supports categorical and continuous exposures, including spline terms and contrasts between specified exposure values.
* Effects can be reported per specified increments or per interquartile range using `contrast`.
* Interaction tests can use Wald, likelihood ratio, or both tests. GEE and quasi-likelihood models use the Wald test.
* Results are returned as `ggplot2` objects and can be further customized with standard `ggplot2` syntax.
* Forest plot layouts can be customized through `foresty_layout()`, with predefined styles including `"classic"`, `"jama"`, `"nejm"`, `"lancet"`, `"bmj"`, and `"revman"`.
* `foresty_report()` and the `html` argument provide self-contained HTML reports containing the model results, interaction tests, coefficient tables, and forest plots.
* Results can be exported as PNG or SVG figures and as `.rds` objects.
* `summary()`, `as.data.frame()`, `broom::tidy()`, `broom::glance()`, `coef()`, `vcov()`, `predict()`, `formula()`, and `nobs()` are supported for foresty results.

