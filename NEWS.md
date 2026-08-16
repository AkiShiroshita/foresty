# foresty 0.0.1

First release.

## Features

* `foresty_app()` provides a Shiny interface for interactively selecting exposures, modifiers, contrasts, colours, and plot layouts. 
* `foresty_data()` draws the same figure -- the forest plot and the table of numbers beside it, aligned row for row, in any of the journal styles -- from estimates you already have: a `data.frame`, `tibble` or `data.table` with one row per row of the figure. It is the entry point for numbers that did not come out of a model this package can read: a meta-analysis, a table being redrawn from a paper, a model fitted by something else. 
* Supports `glm()`, `lm()`, `survival` models, and `lme4` models, with robust and cluster-robust standard errors through `sandwich`.
* Supports categorical and continuous exposures, including spline terms and contrasts between specified exposure values.
* `summary()`, `as.data.frame()`, `broom::tidy()`, `broom::glance()`, `coef()`, `vcov()`, `predict()`, `formula()`, and `nobs()` are supported for foresty results.

