# Model methods for foresty figures

These pass through to the model the figure was drawn from, so that a
foresty result can be used wherever the fit itself would have been.

## Usage

``` r
# S3 method for class 'foresty'
predict(object, ..., model = NULL)

# S3 method for class 'foresty'
coef(object, ..., model = NULL)

# S3 method for class 'foresty'
vcov(object, ..., model = NULL)

# S3 method for class 'foresty'
formula(x, ..., model = NULL)

# S3 method for class 'foresty'
nobs(object, ..., model = NULL)

# S3 method for class 'foresty'
model.frame(formula, ..., model = NULL)
```

## Arguments

- object, x, formula:

  A `foresty` object. The argument is named `formula` in
  [`model.frame()`](https://rdrr.io/r/stats/model.frame.html) only
  because the generic names it that.

- ...:

  Passed on to the method for the underlying fit.

- model:

  Which model is meant, when the figure covers several.

## Value

Whatever the corresponding method for the underlying model returns.

## Examples

``` r
fit <- glm(asthma ~ no2 + sex, family = binomial, data = foresty_cohort)
x <- foresty_interaction(fit, exposure = "no2", interaction = "sex")
head(predict(x, type = "response"))
#>         1         2         3         4         5         6 
#> 0.2041944 0.1448737 0.2940672 0.1463728 0.1130710 0.1893753 
formula(x)
#> asthma ~ no2 + sex + no2:sex
#> <environment: 0x56220c74e208>
nobs(x)
#> [1] 4000
```
