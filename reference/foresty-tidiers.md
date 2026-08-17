# Turn a foresty figure into a data frame

`tidy()` returns the estimates the figure was drawn from, one row
apiece, in the columns `broom` uses and in the order it puts them, so
the result reads beside a tidied model and drops into the same
pipelines. `glance()` returns one row describing the fit.

## Usage

``` r
# S3 method for class 'foresty'
tidy(
  x,
  what = c("estimates", "coefficients"),
  conf.int = TRUE,
  model = NULL,
  ...
)

# S3 method for class 'foresty'
glance(x, ...)

# S3 method for class 'foresty'
as.data.frame(x, row.names = NULL, optional = FALSE, ...)
```

## Arguments

- x:

  A `foresty` object.

- what:

  `"estimates"`, the default, returns the rows drawn on the figure.
  `"coefficients"` returns the whole coefficient table of the model
  instead, on the scale it was fitted on.

- conf.int:

  Whether to include the confidence interval. Defaults to `TRUE`, an
  interval being the point of a forest plot.

- model:

  Which model to take the coefficients from, when the figure covers
  several.

- ...:

  Ignored.

- row.names, optional:

  Ignored, present for consistency with the generic.

## Value

A data frame.

## Details

[`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html) returns
everything the figure carries instead, the display labels included,
which is what to use when the estimates are going back into a plot
rather than into a table. It is the one of the three that needs nothing
installed.

`tidy()` and `glance()` are `broom`'s generics, and `foresty` registers
its methods on them rather than carrying `broom` itself: install it if
you want them, and call them as `broom::tidy(x)` or after
[`library(broom)`](https://broom.tidymodels.org/).

## Examples

``` r
fit <- glm(asthma ~ no2 + sex + maternal_age, family = binomial,
           data = foresty_cohort)
x <- foresty_interaction(fit, exposure = "no2", interaction = "sex")
as.data.frame(x)
#>   variable level contrast_label reference estimate          se conf.low
#> 1      no2  <NA>           <NA>     FALSE 1.033391 0.010784218 1.011778
#> 2      no2  <NA>           <NA>     FALSE 1.083628 0.009736242 1.063145
#>   conf.high statistic      p.value    n events person_time outcome_level
#> 1  1.055466  3.045733 2.321135e-03 2009    327          NA          <NA>
#> 2  1.104505  8.249037 1.596761e-16 1991    475          NA          <NA>
#>   outcome_reference outcome_label modifier_level interaction_p modifier
#> 1              <NA>          <NA>         Female   0.001076479      sex
#> 2              <NA>          <NA>           Male   0.001076479      sex
#>   variable_label label modifier_label
#> 1            no2   no2         Female
#> 2            no2   no2           Male

if (requireNamespace("broom", quietly = TRUE)) {
  broom::tidy(x)
  broom::glance(x)
}
#>   measure    n events person_time conf.ci_level robust n_models
#> 1      OR 4000    802          NA          0.95  FALSE        1
#>   interaction.statistic interaction.df interaction.p.value
#> 1              10.69117              1         0.001076479
```
