# Summarize a foresty figure

Reports what the figure was drawn from: the model, its whole coefficient
table with standard errors and p-values in the manner of
[`summary.glm()`](https://rdrr.io/r/stats/summary.glm.html), the
exposure or subgroup estimates on the reported scale, and the joint test
of the interaction where there is one.

## Usage

``` r
# S3 method for class 'foresty'
summary(object, model = NULL, ...)

# S3 method for class 'summary.foresty'
print(x, ...)
```

## Arguments

- object:

  A `foresty` object.

- model:

  Which model to report, when the figure covers several. Defaults to the
  only one.

- ...:

  Ignored.

- x:

  A `summary.foresty` object.

## Value

An object of class `summary.foresty`, a list with elements `call`,
`coefficients`, `estimates` and, for an interaction, `interaction_test`.

## Details

The coefficient table is on the scale the model was fitted on, as a
model summary is, so a logistic regression reports log odds. The
estimates underneath are on the reported scale, exponentiated where the
measure is a ratio.

## Examples

``` r
fit <- glm(asthma ~ no2 + sex + maternal_age, family = binomial,
           data = foresty_cohort)
summary(foresty_interaction(fit, exposure = "no2", interaction = "sex"))
#> 
#> Call:
#> glm(formula = asthma ~ no2 + sex + maternal_age + no2:sex, family = binomial, 
#>     data = foresty_cohort)
#> 
#> Model:      glm, lm
#> Measure:    Odds ratio for asthma
#> Observations: 4,000   Events: 802
#> 
#> Coefficients:
#>                Estimate Std. Error z value Pr(>|z|)
#> (Intercept)  -2.2713952  0.3103048  -7.320 2.48e-13
#> no2           0.0328459  0.0107842   3.046  0.00232
#> sexMale      -0.4429622  0.2965603  -1.494  0.13526
#> maternal_age  0.0002275  0.0075311   0.030  0.97590
#> no2:sexMale   0.0474688  0.0145338   3.266  0.00109
#> 
#> Odds ratio for asthma (95% CI):
#>  Subgroup Variable   OR    95% CI      p     N Events
#>    Female      no2 1.03 1.01-1.06  0.002 2,009    327
#>      Male      no2 1.08 1.06-1.10 <0.001 1,991    475
#> 
#> Interaction (no2 by sex):
#>   Likelihood ratio chi-square = 10.69 on 1 df, p = 0.001
```
