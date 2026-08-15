# The qualitative palettes a figure can be coloured from

The ColorBrewer qualitative palettes, as
[`RColorBrewer::brewer.pal()`](https://rdrr.io/pkg/RColorBrewer/man/ColorBrewer.html)
gives them, so that `colour` and `colours` in
[`foresty_layout()`](https://akishiroshita.github.io/foresty/reference/foresty_layout.md)
can be answered by naming a palette and a place in it rather than by
pasting a hex code. The values are the palettes' own and are held here
so that the package needs nothing installed to draw in them.

## Usage

``` r
foresty_colours(palette = c("Dark2", "Set1", "Set2"), n = NULL, start = 1)
```

## Arguments

- palette:

  Name of the palette: `"Dark2"`, the default, which is the one a figure
  printed in colour is usually drawn from, `"Set1"` or `"Set2"`.

- n:

  How many colours to return. `NULL`, the default, returns the whole
  palette. More than the palette holds cycles round it, since a figure
  with more categories than the palette has colours has to draw them
  somehow.

- start:

  Which colour of the palette to begin at, counting from 1. The palette
  is rotated rather than trimmed, so that every colour is still
  available after it.

## Value

A character vector of colours.

## See also

[`foresty_layout()`](https://akishiroshita.github.io/foresty/reference/foresty_layout.md),
whose `colour` and `colours` arguments these are for.

## Examples

``` r
foresty_colours("Dark2")
#> [1] "#1B9E77" "#D95F02" "#7570B3" "#E7298A" "#66A61E" "#E6AB02" "#A6761D"
#> [8] "#666666"

# The third colour of Dark2, for one figure drawn in one colour.
foresty_colours("Dark2")[3]
#> [1] "#7570B3"

# A palette beginning there, for a figure whose rows are coloured by their
# category.
foresty_colours("Dark2", start = 3)
#> [1] "#7570B3" "#E7298A" "#66A61E" "#E6AB02" "#A6761D" "#666666" "#1B9E77"
#> [8] "#D95F02"
```
