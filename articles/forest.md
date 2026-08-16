# foresty

``` r

library(foresty)
```

## What is foresty?

An interaction p-value indicates whether the effect of an exposure
differs across subgroups. It does not show the size or direction of the
effect in each subgroup. `foresty` presents those subgroup-specific
estimates alongside the interaction test in a publication-ready forest
plot. You can use it directly from R or through a local Shiny app, which
generates the code for each figure.

## Before you start

Fit the model in an R script before opening the app. The app works with
an existing fitted model; it does not select a model or alter the data.
Start without the exposure-by-modifier interaction term. `foresty` adds
the two-way term when performing a subgroup analysis.

Categorical effect modifiers should be factors, with levels ordered as
you want them to appear. A numeric modifier with three or more values
must be categorized, and the model must then be refitted before it can
be used.

``` r

cohort <- transform(
  foresty_cohort,
  sex = factor(sex, levels = c("Female", "Male")),
  maternal_smoking = factor(maternal_smoking)
)
```

The package includes a simulated birth cohort for examples.

``` r

str(foresty_cohort, max.level = 1)
#> 'data.frame':    4000 obs. of  11 variables:
#>  $ asthma          : int  0 0 0 1 0 1 0 0 0 0 ...
#>  $ wheeze          : int  0 0 0 0 1 0 0 1 0 1 ...
#>  $ followup_years  : num  4.368 5.494 2.964 2.055 0.285 ...
#>  $ no2             : num  27.54 11.61 22.81 11.76 8.07 ...
#>  $ black_carbon    : num  0.644 0.393 0.69 0.322 0.253 ...
#>  $ sex             : Factor w/ 2 levels "Female","Male": 1 2 2 2 2 2 2 1 1 1 ...
#>  $ maternal_smoking: Factor w/ 2 levels "No","Yes": 1 1 1 1 1 1 1 1 1 1 ...
#>  $ maternal_asthma : Factor w/ 2 levels "No","Yes": 1 1 1 2 1 2 2 1 1 1 ...
#>  $ maternal_age    : num  29 30 38 23 32 22 29 27 24 30 ...
#>  $ birth_year      : Factor w/ 10 levels "2005","2006",..: 8 5 8 5 7 6 5 9 10 2 ...
#>  $ urbanicity      : Factor w/ 3 levels "Rural","Suburban",..: 3 1 3 3 2 3 1 2 3 2 ...
```

## Fit a model

For example, we can estimate the association between infant NO2 exposure
and asthma, adjusting for sex, maternal smoking, and maternal age:

``` r

fit <- glm(
  asthma ~ no2 + sex + maternal_smoking + maternal_age,
  family = binomial,
  data = cohort
)
```

For logistic models, `foresty` reports odds ratios by default. It also
supports common linear, survival, mixed-effects, and marginal models,
provided they include coefficients, a covariance matrix, and a model
frame.

## Launch the app

``` r

foresty_app(fit)
```

The app runs locally and uses the fitted model in your current R
session. Choose one or more exposures and effect modifiers from the
model variables. If you select several exposures and modifiers, the app
creates a figure for each exposure-modifier pair. You can also include
the overall exposure effect from the original model.

## Choose the comparison

For a continuous exposure, choose the comparison represented by each
estimate:

- **One unit**
- **An interquartile range**
- **An increment you specify**, such as 10 units
- **Two values to compare**, including selected quantiles

The figure states the selected comparison. For example, `contrast = 10`
reports the effect for a 10-unit increase, whereas `at = c(10, 20)`
compares an exposure value of 20 with one of 10. The latter is
particularly useful for nonlinear or spline-transformed exposures.

## Create an interaction figure in R

You can run the same analysis directly in a script. The following call
adds the NO2-by-sex interaction, if it is not already in the fitted
model, and then estimates the NO2 effect separately for each sex.

``` r

by_sex <- foresty_interaction(
  fit,
  exposure = "no2",
  interaction = "sex",
  contrast = 10
)

by_sex
```

[`foresty_interaction()`](https://akishiroshita.github.io/foresty/reference/foresty_interaction.md)
reports a joint interaction test and confidence intervals for the
subgroup estimates. All subgroup estimates come from one interaction
model, rather than separate models fitted within each subgroup.

## Combine and style figures

Use
[`foresty_main()`](https://akishiroshita.github.io/foresty/reference/foresty_main.md)
for an overall effect and
[`foresty_combine()`](https://akishiroshita.github.io/foresty/reference/foresty_combine.md)
to place it beside one or more subgroup analyses.

``` r

overall <- foresty_main(list(fit), exposure = "no2", contrast = 10)
figure <- foresty_combine(Overall = overall, Sex = by_sex, layout = "jama")

figure
```

Available layouts include `"classic"`, `"jama"`, `"nejm"`, `"lancet"`,
`"bmj"`, and `"revman"`. You can further customize a figure with
standard `ggplot2` layers.

## Reproduce and export results

The app’s **R code** tab shows the code used to create the current
figure, which you can copy into an analysis script. You can download PNG
and SVG figures, HTML reports, and the resulting R objects. When
downloading multiple figures, the app bundles them in a zip file.

You can also create an HTML report from a result in R:

``` r

foresty_report(by_sex, file = "no2_by_sex.html")
```

The report records the subgroup estimates, interaction test, and model
coefficients used for the figure.

## Where to read next

- [`?foresty_app`](https://akishiroshita.github.io/foresty/reference/foresty_app.md)
  — explore interactions interactively.
- [`?foresty_interaction`](https://akishiroshita.github.io/foresty/reference/foresty_interaction.md)
  — visualize two-way interactions.
- [`?foresty_main`](https://akishiroshita.github.io/foresty/reference/foresty_main.md)
  — visualize overall effects.
- [`?foresty_combine`](https://akishiroshita.github.io/foresty/reference/foresty_combine.md)
  — combine multiple analyses.
- [`?foresty_layout`](https://akishiroshita.github.io/foresty/reference/foresty_layout.md)
  — customize forest plots.
- [`?foresty_report`](https://akishiroshita.github.io/foresty/reference/foresty_report.md)
  — create HTML reports.
