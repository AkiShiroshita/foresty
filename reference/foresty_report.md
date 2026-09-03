# Write a foresty figure and its numbers to a self-contained HTML page

Writes what an interaction p-value was standing in for: the exposure
effect within each level of the modifier, the joint test of the
interaction, the ratio of the effects between levels, the whole
coefficient table of the updated model, and the figure. Everything is
inlined, so the file can be opened or sent on its own.

## Usage

``` r
foresty_report(
  x,
  file,
  title = NULL,
  model = NULL,
  width = 10,
  height = NULL,
  open = FALSE
)
```

## Arguments

- x:

  An object returned by
  [`foresty_interaction()`](https://akishiroshita.github.io/foresty/reference/foresty_interaction.md)
  or
  [`foresty_main()`](https://akishiroshita.github.io/foresty/reference/foresty_main.md).

- file:

  Path to write to. A `.html` extension is added if missing.

- title:

  Browser page title. The default names the exposure and the modifier;
  it is not displayed in the report body.

- model:

  Which model to report the coefficients of, when the figure covers
  several. The default reports every one of them.

- width, height:

  Size of the embedded plot in inches. `height` defaults to a size that
  fits the number of rows.

- open:

  Whether to open the file when it has been written. Defaults to
  `FALSE`.

## Value

The path written to, invisibly.

## Details

A figure drawn from several models –
[`foresty_main()`](https://akishiroshita.github.io/foresty/reference/foresty_main.md)
over a list of them – describes each of them on the page and gives each
its own coefficient table, headed with the exposure it was fitted for.
`model` cuts those sections down to one. The rest of the page is the
figure itself – the estimates, the test and the plot – and is the whole
of it whichever model is named, a figure being one figure however many
models went into it.

## Examples

``` r
# Writing the page renders the figure and lays the tables out with `gt`,
# which is the slow part, so it is left out of the timed run.
# \donttest{
fit <- glm(asthma ~ no2 + sex + maternal_age, family = binomial,
           data = foresty_cohort)
x <- foresty_interaction(fit, exposure = "no2", interaction = "sex")
foresty_report(x, file = file.path(tempdir(), "no2_by_sex.html"))

# The same page can be asked for as the figure is made. `html = TRUE`
# writes it under a name taken from the variables it is about -- here
# no2_sex.html -- into the working directory; a path writes it there
# instead, which is what these examples do so that nothing is written
# outside the session's temporary directory.
foresty_interaction(fit, exposure = "no2", interaction = "sex",
                    html = file.path(tempdir(), "no2_sex.html"))

foresty_main(list(fit), exposure = "no2",
             html = file.path(tempdir(), "no2.html"))

# }
```
