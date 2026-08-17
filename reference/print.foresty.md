# Draw a forest plot

Draws the figure, having first made sure the plot in it has room for its
axis. A column of text is as wide as what it holds, and the plot is
given what those columns leave, which is a decision that cannot be made
while the figure is being built: how much they leave depends on the
width the figure is drawn at. So a table wide enough – a survival model
reporting N, events and person-time beside the estimates – can leave the
plot a centimetre and the numbers under its axis printed one on top of
another. The floor is applied here, where the width being drawn at is
known: see the `min_plot_width` argument of
[`foresty_layout()`](https://akishiroshita.github.io/foresty/reference/foresty_layout.md).
Where it has to act, the columns of text stop being as wide as what they
hold and share what the plot leaves in proportion to it, which is where
the room for the axis comes from; a figure with room for its columns
already is drawn exactly as it was built.

## Usage

``` r
# S3 method for class 'foresty'
print(x, ...)

# S3 method for class 'foresty'
plot(x, ...)

# S3 method for class 'foresty'
grid.draw(x, recording = TRUE)
```

## Arguments

- x:

  A figure returned by
  [`foresty_main()`](https://akishiroshita.github.io/foresty/reference/foresty_main.md),
  [`foresty_interaction()`](https://akishiroshita.github.io/foresty/reference/foresty_interaction.md)
  or
  [`foresty_combine()`](https://akishiroshita.github.io/foresty/reference/foresty_combine.md).

- ...:

  Passed on to patchwork's and ggplot2's own print methods.

- recording:

  Whether to record the drawing on the display list, as in
  [`grid::grid.draw()`](https://rdrr.io/r/grid/grid.draw.html).

## Value

`x`, invisibly.

## Examples

``` r
fit <- glm(asthma ~ no2 + sex, family = binomial, data = foresty_cohort)
print(foresty_interaction(fit, "no2", "sex", table = TRUE))

```
