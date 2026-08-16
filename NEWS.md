# foresty 0.0.1

First release.

## Features

* `foresty_app()` provides a Shiny interface for interactively selecting exposures, modifiers, contrasts, colours, and plot layouts. It opens in the system browser by default; pass `launch.browser = FALSE` to have it print its address instead.
* The application wears the same `bslib` "flatly" interface as the `ggstratify` package -- grey title bar, green tabs, a sidebar of accordion panels -- so that the two are read as one pair of tools.
* Its **R code** tab writes the code twice over: the `foresty` call that drew the figures, and, under *How to calculate effect estimates for each subgroup*, where those numbers come from in base R and the `car` package with nothing from this package in them -- the interaction term, the linear combination of the coefficients each subgroup estimate is, and the joint test reported beside them. It comes to the estimates on the Plot tab exactly and draws nothing.
* `reference` in `foresty_interaction()` reads every combination of a categorical exposure and a categorical modifier against one combination of them -- `reference = c(ecog = "0-1", egfr_mutation = "Negative")` -- rather than reading each subgroup against its own reference level, which is the table of groups against a baseline group a paper reports. The **Model** panel of `foresty_app()` offers it once per effect modifier, with menus naming the group.
* `foresty_data()` draws the same figure -- the forest plot and the table of numbers beside it, aligned row for row, in any of the journal styles -- from estimates you already have: a `data.frame`, `tibble` or `data.table` with one row per row of the figure. It is the entry point for numbers that did not come out of a model this package can read: a meta-analysis, a table being redrawn from a paper, a model fitted by something else. The columns holding the estimate and its interval are found by name where they are not named, so a frame from `broom::tidy(conf.int = TRUE)` needs nothing said about it. `group` blocks the rows into subgroups, `emphasis` marks the overall row drawn apart from them, and `interaction_p` is written once per block, so the figure `foresty_app()` draws can be reproduced from its numbers alone.
* `foresty_main()` creates forest plots for exposure effects from fitted models.
* `foresty_interaction()` estimates exposure effects within levels of a modifier, tests the interaction, and displays the results in a forest plot.
* `foresty_combine()` combines overall and subgroup results into a single forest plot.
* Supports `glm()`, `lm()`, `survival` models, and `lme4` models, with robust and cluster-robust standard errors through `sandwich`.
* Supports categorical and continuous exposures, including spline terms and contrasts between specified exposure values.
* Effects can be reported per specified increments or per interquartile range using `contrast`.
* Interaction tests can use Wald, likelihood ratio, or both tests. GEE and quasi-likelihood models use the Wald test.
* Results are returned as `ggplot2` objects and can be further customized with standard `ggplot2` syntax.
* Forest plot layouts can be customized through `foresty_layout()`, with predefined styles including `"classic"`, `"jama"`, `"nejm"`, `"lancet"`, `"bmj"`, and `"revman"`.
* The plot keeps a share of the figure when the table beside it is wide, so that a survival model reporting N, events and person-time does not squeeze the axis into a row of overprinted numbers. The share is set by `min_plot_width` in `foresty_layout()`.
* `foresty_report()` and the `html` argument provide self-contained HTML reports containing the model results, interaction tests, coefficient tables, and forest plots.
* Results can be exported as PNG or SVG figures and as `.rds` objects.
* `summary()`, `as.data.frame()`, `broom::tidy()`, `broom::glance()`, `coef()`, `vcov()`, `predict()`, `formula()`, and `nobs()` are supported for foresty results.

