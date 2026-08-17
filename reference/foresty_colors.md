# The qualitative palettes a figure can be colored from

The ColorBrewer qualitative palettes, as
[`RColorBrewer::brewer.pal()`](https://rdrr.io/pkg/RColorBrewer/man/ColorBrewer.html)
gives them, so that `color` and `colors` in
[`foresty_layout()`](https://akishiroshita.github.io/foresty/reference/foresty_layout.md)
can be answered by naming a palette and a place in it rather than by
pasting a hex code. The values are the palettes' own and are held here
so that the package needs nothing installed to draw in them.

## Usage

``` r
foresty_colors(palette = c("Dark2", "Set1", "Set2"), n = NULL, start = 1)
```

## Arguments

- palette:

  Name of the palette: `"Dark2"`, the default, which is the one a figure
  printed in color is usually drawn from, `"Set1"` or `"Set2"`.

- n:

  How many colors to return. `NULL`, the default, returns the whole
  palette. More than the palette holds cycles round it, since a figure
  with more categories than the palette has colors has to draw them
  somehow.

- start:

  Which color of the palette to begin at, counting from 1. The palette
  is rotated rather than trimmed, so that every color is still available
  after it.

## Value

A character vector of colors.

## See also

[`foresty_layout()`](https://akishiroshita.github.io/foresty/reference/foresty_layout.md),
whose `color` and `colors` arguments these are for.

## Examples

``` r
foresty_colors("Dark2")
#> [1] "#1B9E77" "#D95F02" "#7570B3" "#E7298A" "#66A61E" "#E6AB02" "#A6761D"
#> [8] "#666666"

# The third color of Dark2, for one figure drawn in one color.
foresty_colors("Dark2")[3]
#> [1] "#7570B3"

# A palette beginning there, for a figure whose rows are colored by their
# category.
foresty_colors("Dark2", start = 3)
#> [1] "#7570B3" "#E7298A" "#66A61E" "#E6AB02" "#A6761D" "#666666" "#1B9E77"
#> [8] "#D95F02"
```
