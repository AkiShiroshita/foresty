# Build a forest plot by clicking

Opens a Shiny app on a model you have already fitted, so that the
exposures, the modifiers and the layout can be chosen from menus rather
than typed, retyped and re-run. Every figure the app draws is drawn by
[`foresty_interaction()`](https://akishiroshita.github.io/foresty/reference/foresty_interaction.md),
[`foresty_main()`](https://akishiroshita.github.io/foresty/reference/foresty_main.md)
or
[`foresty_combine()`](https://akishiroshita.github.io/foresty/reference/foresty_combine.md),
and the code that drew it is shown in a tab of its own for copying back
into your script.

## Usage

``` r
foresty_app(
  fit,
  measure = NULL,
  launch = interactive(),
  launch.browser = TRUE,
  ...
)
```

## Arguments

- fit:

  A fitted model, as passed to
  [`foresty_main()`](https://akishiroshita.github.io/foresty/reference/foresty_main.md)
  or
  [`foresty_interaction()`](https://akishiroshita.github.io/foresty/reference/foresty_interaction.md).
  Its variables become the menus of exposures and modifiers.

- measure:

  The effect measure, as in
  [`foresty_main()`](https://akishiroshita.github.io/foresty/reference/foresty_main.md).
  `NULL`, the default, takes the one the model implies.

- launch:

  Whether to start the app. `TRUE` in an interactive session. `FALSE`
  returns the Shiny app object without running it, which is what tests
  and [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html)
  want.

- launch.browser:

  Passed to
  [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html).
  `TRUE`, the default, opens the app in the system browser as soon as it
  starts, rather than leaving a URL to be clicked or drawing it into the
  viewer pane of an IDE. `FALSE` starts it and says where it is, which
  is what a remote session or a scripted screenshot wants.

- ...:

  Passed to
  [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html), so
  that `port` and `host` can be set.

## Value

The Shiny app object, invisibly when the app was run.

## What the app does not do

It does not fit your model. The estimates a forest plot reports come out
of the coefficients and the covariance matrix of a fit, so the model has
to exist before there is anything to draw, and which model to fit is the
part of the analysis that should be written down in a script rather than
clicked together and forgotten. The app is for the part that is fiddling
–
[`foresty_layout()`](https://akishiroshita.github.io/foresty/reference/foresty_layout.md)
alone has some thirty arguments, and finding the figure a journal wants
by editing a call and re-running it is slow.

It does not change the type of your variables either. A modifier stored
as a number but taking only two values is drawn as the two subgroups it
is, needing no change; one taking three or more is refused, and the
refusal is shown where the figure would have been, because turning it
into a factor means fitting a different model and that is a decision to
make in the script, not a checkbox. See the `interaction` argument of
[`foresty_interaction()`](https://akishiroshita.github.io/foresty/reference/foresty_interaction.md).

## More than one pair

The exposure and the modifier menus both take as many variables as you
select, and what is drawn is every pair of them: three exposures and two
modifiers are six figures. The overall effect, which comes from the
model with no interaction term in it, is a checkbox of its own, so it
can be drawn beside the subgroups rather than instead of them. Where
more than one figure is drawn the app offers to combine them, which is
[`foresty_combine()`](https://akishiroshita.github.io/foresty/reference/foresty_combine.md)
and follows its rules: figures of one exposure become the blocks of one
figure, and figures of different exposures stay apart, since rows
reporting the effects of different exposures are not read against each
other.

How big a difference in the exposure each estimate is for – one unit, an
interquartile range, an increment you name, its two ends either way
round, the first to the third quantile, two values you name – is asked
once for each continuous exposure rather than once for all of them,
since two exposures rarely want the same answer. The lowest and highest
values it takes are written under the choice, and are where naming two
values starts from. Whichever was chosen is written on the figure
wherever the exposure is named, one unit included – `"no2 (per 1)"`,
`"no2 (per 10)"`, `"no2 (per IQR, 8.44)"` – since a reader comparing two
figures across a screen should not have to know that a row saying
nothing means one.

Which way round the comparison runs is written with an arrow rather than
as "from ... to ...", since that is the part a reader gets wrong:
`Lowest value -> Highest value` is the effect of being at the top of the
exposure rather than the bottom, and **Reverse the direction** turns it
into the same estimate the other way up, which is how a protective
effect is drawn as one. The two boxes that name two values are headed
the same way, and so is the figure: two values compared are written
beside the exposure as `"no2 (4.102 -> 38.72)"` rather than as "38.72 vs
4.102", which says which two values were compared without saying which
of them the estimate is the effect of moving to.

From one quantile to another is not the interquartile range, though it
begins at the quartiles: the range is a width, and an effect per one of
it is a step along a slope, whereas the quantiles are two values of the
exposure and are compared as `at = c(from, to)`. So it can be asked of a
splined exposure, which has no single slope to report a width per, and
the two probabilities can be set to anything – the 10th against the
90th, the median against the top decile – rather than only 0.25 and
0.75.

## One reference group instead of one per subgroup

A subgroup figure reads each subgroup against its own reference level,
so the rows of one subgroup are not comparisons with the rows of
another. Where the exposure and the modifier both have levels there is a
second question: what every combination of the two comes to against one
of them, which is the table of groups against a baseline group a paper
reports. **Model** asks it once per effect modifier chosen – *Compare
every combination of the exposure and ... with one group* – and the
menus under the box say which combination the rest are read against: a
level of the modifier, and a level of each exposure that has levels.

Every row is then that whole cell – this level of the exposure, this
level of the modifier – against the one chosen, all of it out of the
same interaction model, and the cell chosen is drawn as the reference it
is. The p-value beside the rows is the same joint test of the
interaction either way: it asks whether the effect of the exposure
depends on the modifier, and it is not a test of the rows. See the
`reference` argument of
[`foresty_interaction()`](https://akishiroshita.github.io/foresty/reference/foresty_interaction.md).

A continuous exposure has no levels to combine, so a pair with one is
drawn as it always was whatever the box says: its rows are the effect of
a difference in the exposure rather than groups of people.

## Figure style names

The rows, the axis and the columns of a figure are named after columns
of a data set, and a column is called what the data set calls it.
**Figure style** renames the outcome – which is otherwise taken from the
left of your formula, `asthma_ever_dx` and all – replaces the label
under the plot outright, and names each selected exposure. A model
carrying person-time is also asked what unit to count it in, 1,000 or
100,000 being how a paper reports a rate and six figures beside the plot
being width the plot could have had.

## A model too slow to redraw

Every change to a control refits the model once per pair of menus, and
while that is happening the app looks exactly as it did before, so a
line saying that it is working is shown above the tabs and the figure on
the screen is the previous one until it goes.

On a model where that wait is not seconds but minutes, **Write the R
code only** stops it: nothing is fitted and nothing is drawn, the menus
and the style controls go on working, and the **R code** tab goes on
writing the call they come to, which is what to paste into the script
and run once. The other tabs report on models the app fitted and say so
instead.

## Colours and the panel

A figure is drawn in one colour, which is asked for per exposure and can
be named as a place in a ColorBrewer palette – the third colour of Dark2
– or typed as a hex code, which is how a figure is drawn in the colour a
journal or a slide deck already uses. **What the colours change with**
draws it in more than one instead: a colour per category of the rows,
which is the levels of a categorical exposure or the subgroups of the
modifier, or a colour per row. Those come from a palette, or from hex
codes typed beside it – `#1B9E77, #D95F02` – which is the same list
`colours` takes. See `colour_by` in
[`foresty_layout()`](https://akishiroshita.github.io/foresty/reference/foresty_layout.md).

## The tabs

**Plot** draws them, each figure carrying the exposure it is of under
its title, which is a line that can be turned off on its own where the
title says it already. **Models** writes out, in R, how each figure was
arrived at: the term added to your model, the linear combination each
subgroup estimate is, and the test reported beside them. That code is
meant to be run: it is the call `foresty` made, with the same design
matrix, the same coefficients and covariance, the same degrees of
freedom and the same test, so pasting it beside the model reproduces the
numbers on the figure rather than approximating them. **summary(fit)**
is the summary of the model you fitted and of every model the app fitted
from it by adding an interaction term. Both tabs head each block with
the outcome, the exposure and the effect modifier the figure under it is
of, since a coefficient table says none of them. **R code** is the code
twice over. *With foresty* is the code that drew what is beside it,
deparsed rather than reconstructed, so it cannot drift from what you are
looking at; several pairs are written as a loop over the pairs rather
than as one call apiece. It names the model with the name you passed to
`foresty_app()`, so pasting it into a script next to that model works as
it stands. *How to calculate effect estimates for each subgroup* is
where those numbers come from, in base R and the `car` package with
nothing from this package in them: the interaction term, the linear
combination of the coefficients each subgroup estimate is, and the joint
test reported beside them. It is there for a reader deciding whether to
take the dependency at all, and for one who would rather see what is
being done on their behalf than take it on trust. It comes to the
estimates on the Plot tab exactly – the same design matrix, the same
coefficients and covariance, the same degrees of freedom and the same
test – and draws nothing: drawing them is what the call above it is for.

## What comes out

The figure downloads as PNG and as SVG, at the size and resolution set
beside the buttons; where the pairs are not being combined, one file per
figure comes down in a zip. The reports do the same, one HTML page per
model. The objects themselves download as an `.rds` file holding a named
list – one element per pair, plus the combined figure where there is one
– so that a session that ended in the app can go on in a script:
`figures <- readRDS("...")` and then `summary(figures[[1]])`,
`as.data.frame(figures[[1]])` or
`foresty_report(figures[[1]], "x.html")`.

## See also

[`foresty_interaction()`](https://akishiroshita.github.io/foresty/reference/foresty_interaction.md),
[`foresty_main()`](https://akishiroshita.github.io/foresty/reference/foresty_main.md),
[`foresty_combine()`](https://akishiroshita.github.io/foresty/reference/foresty_combine.md),
[`foresty_layout()`](https://akishiroshita.github.io/foresty/reference/foresty_layout.md).

## Examples

``` r
fit <- glm(asthma ~ no2 + sex + maternal_smoking + maternal_age,
           family = binomial, data = foresty_cohort)

# Opens the app in an interactive session.
if (interactive()) {
  foresty_app(fit)
}
```
