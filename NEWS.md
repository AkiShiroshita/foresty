# foresty 0.0.1

First release.

* `foresty_main()` draws the effect of one exposure from each of a list of
  fitted models, one row apiece.
* `foresty_interaction()` updates a fitted model with an exposure by modifier
  interaction, estimates the exposure effect within each level of the modifier
  as a linear combination of the coefficients, tests the interaction jointly,
  and draws the levels one above the other.
* `foresty_combine()` draws figures already made as one: an overall effect
  from `foresty_main()` and the subgroup analyses from as many calls to
  `foresty_interaction()` as there are modifiers, each a block of rows under a
  heading of its own, with the interaction p-value beside each block. Nothing
  is refitted; every row is the row it was drawn from.
* `foresty_report()` writes a self-contained HTML page holding the model, the
  subgroup estimates, the joint interaction test, the full coefficient table
  and the forest plot. `foresty_main()` and `foresty_interaction()` write the
  same page as the figure is made, through `html = TRUE`, which names the file
  for the variables it is about. Nothing is written unless it is asked for, so
  nothing leaves the session on its own.
* The result is a `ggplot2` object, so layers, scales and themes are added to
  it with `+`, and with `&` to reach the table beside the plot as well. The
  estimates travel with the figure, so `summary()`, `as.data.frame()`,
  `broom::tidy()`, `broom::glance()`, `predict()`, `coef()`, `vcov()`,
  `formula()` and `nobs()` keep working after it has been retuned.
* `vcov` and `cluster` give robust and cluster-robust standard errors through
  `sandwich`. Where sandwich does not apply, the model's own mechanism is
  named instead of a wrong number being returned.
* A categorical exposure gets one row per level, the reference level included
  and drawn hollow, with the levels on the rows and the variable named once at
  the left of the figure.
* A Cox model, or a Poisson model with an offset, reports the person-time
  behind each row.
* The estimate and its interval share one column, headed with the measure the
  model produced, as `Adjusted odds ratio (95% CI)`.
* Linear combinations and their tests are delegated to `car`; models fitted by
  `stats::glm()`, `stats::lm()`, `survival`, `rms` and `lme4` are supported, as
  is any fit supplying `coef()` and `vcov()`.

## Not yet supported

These are known gaps rather than oversights, and are candidates for later
releases.

* Continuous effect modifiers. Categorize with `cut()` first.
* More than one effect modifier per call to `foresty_interaction()`. Call it
  once per modifier and put the results together with `foresty_combine()`.
* Exposures entered as splines, unless `at` gives the two values to contrast,
  and only when the basis is built in the formula: a basis computed beforehand
  and fitted as columns of its own records nothing that ties them to the
  variable.
* Pooling estimates across models, and average marginal effects.

## Changes during 0.0.1 development

* The package is a package for two-way interactions, and the README says so
  where a reader will meet it: one exposure crossed with one modifier per
  figure, two modifiers being two calls and two blocks of a combined figure
  rather than a three-way term. A model that already carries higher-order
  interactions is used as it was fitted, and the warning that says at which
  values the other interacting variables were held is what to read those
  figures by.
* `broom` is suggested rather than imported, since a forest plot does not need
  it. `tidy()` and `glance()` are registered on `broom`'s generics when `broom`
  is there, so they work exactly as before for anyone who has it; install it
  and call `broom::tidy(x)`, or attach it. `as.data.frame()` needs nothing and
  returns everything the figure carries.
* `foresty_main()` writes the HTML report too, through the same `html`
  argument `foresty_interaction()` has, and `html = TRUE` names the file for
  the variables it is about rather than asking for a path: the exposure and the
  modifier joined by an underscore, as `no2_sex.html`, and the exposures alone
  where there is no modifier, as `no2_black_carbon.html`. A path is still taken
  as it is, and `FALSE`, the default, writes nothing.
* The report of a figure drawn from several models carries every one of them,
  each in a section headed with the exposure it was fitted for, rather than
  refusing to be written until `model` named one. `model` still cuts it down.
* The report no longer restates the hypothesis over the interaction test. What
  the test is a test of is said by the heading over it and by the table of
  ratios under it, so the line now reads as the test: the statistic, its
  degrees of freedom and its p-value.
* The summary row of a combined figure is drawn as the subgroups are -- a mark
  on its confidence interval -- in a filled diamond half again the size of
  their squares. Drawing it as the wide diamond a paper draws, spanning the
  interval in place of it, left a shape whose meaning changed with the width of
  the interval and which was hard to read beside the rows under it. The whole
  figure is now read one way, and the diamond says which row is the summary.
  `emphasis_shape = "diamond"` draws the wide diamond for a figure that wants
  it, at `emphasis_height`.
* The title of a combined figure names the exposure again, as every other
  figure the package draws does: `Adjusted odds ratio for asthma associated
  with NO2, overall and within each subgroup`. It is named once however many
  blocks it was drawn under -- under the first label it was drawn with -- which
  is what stops a figure whose blocks were labelled one at a time being titled
  `associated with NO2 and no2`.
* `foresty_combine()` draws one figure per exposure. Every row of a combined
  figure is read against the rows above it, and rows reporting the effect of
  different exposures are not comparable that way, however alike their axes
  happen to be; a call covering NO2 and black carbon now returns the two
  figures in a list named for them, which draws them one after another when it
  is printed. A call covering one exposure returns that figure, as before.
* The README is written as `README.qmd` and rendered from there, so the figures
  and the console output in it are the ones the package produces rather than
  ones pasted in.

* A term that names something other than a variable in it -- the knots in
  `rms::rcs(no2, knots)` or `splines::ns(no2, knots = k)` -- is a term in one
  variable again. Every symbol in a term label was read as a variable of the
  model, so such a term looked like an interaction between the exposure and its
  own knots and the figure was refused with `"no2" is interacted with "knots"`.
  A term label is now split into the variable expressions it is built from, and
  the symbols in each are matched against the columns the model was fitted
  from. An exposure so entered is drawn with `at = c(from, to)`, and agrees
  with `rms::contrast()` and with a difference of two `predict()` calls.
* `contrast` and `at` are written on the figure. An effect reported per some
  increment other than one is drawn as `NO2 (per 10)`, and two values named by
  `at` as `NO2 (20 vs 10)`, wherever the exposure is named -- the row, the
  title, the title of a combined figure -- because a figure whose numbers move
  with an argument and whose labels do not cannot be read. `at` used to write
  its comparison as a level of the exposure, which the row of a subgroup figure
  had no room for and a one-row figure dropped altogether. No unit is invented;
  name it in `labels`.
* `at` and `contrast` given together are an error rather than one of them being
  ignored, and `contrast` warns when the exposure is categorical, its
  comparisons being its levels. `at` is documented for what it does: it names
  the two values of any exposure, not only of a splined one.
* `at` on a categorical exposure counts the level it compares. The counts were
  taken over rows whose level was the whole comparison, `"Urban vs Rural"`,
  which no row is, so the figure reported no observations behind the estimate.
* `exponentiate` defaults to `TRUE` rather than `NULL`, and means what it says:
  a ratio is drawn as a ratio, and `FALSE` leaves it on the scale the model was
  fitted on. It says nothing about a mean difference or a coefficient, which
  are on that scale already; asking for those to be exponentiated used to be an
  error and is now simply nothing.
* `level` is `ci_level`. It sets the confidence level of the intervals, and sat
  one argument away from the levels of a categorical exposure and of a
  modifier. `glance()` still reports it as `conf.level`.
* The title of a combined figure names the measure and the outcome, and no
  longer the exposure: every block is the same exposure within another set of
  subgroups, and blocks labelled one figure at a time put it in the title twice
  under two spellings, as `associated with NO2 and no2`. Where the effect is
  reported per an increment other than one the exposure is named once, with the
  increment, since the estimates cannot be read without it.
* The rows are the whole of the figure. The band holding the column headings
  used to be reserved in rows, which left a figure of two or three of them
  mostly empty and the estimates sitting in the bottom half of it; it is
  measured in points now, where the headings themselves are measured, and is
  drawn in the margin above the panel. The figure fills the height it is drawn
  at whatever it carries.
* A column of numbers is as wide as its text rather than as its character
  count. A decimal point is half the width of a digit and a bracket narrower
  still, so counting characters left every column a fifth wider than it needed
  to be; with the gap between columns narrowed to match, the plot takes about a
  sixth more of the width than it did.
* `tidy()` and `glance()` are taken from `broom` rather than from `generics`,
  so the generics a user has already attached for their model are the ones the
  methods are registered on.
* The table beside the plot is off by default. `summary()` reports the same
  numbers, and a plain figure is usually what a paper wants.
* The table carries a p-value column.
* `+` reaches the forest rather than the table beside it. patchwork hands a
  ggplot element to the last plot it was given, so the panels are passed with
  the forest last and put back in place by the layout.
* An interaction with one estimate per level of the modifier labels its rows
  with the levels, so the ticks read `Female` and `Male` rather than the
  exposure's name beside a separate strip.
* `cluster` is checked before `sandwich` sees it, so `cluster = TRUE` says what
  is wrong with it rather than reporting a length mismatch.
* The measure names its outcome: an axis reads `Adjusted odds ratio for asthma`
  rather than `Adjusted odds ratio`. A survival outcome is named by its event.
* The axis is linear rather than logged. Add
  `+ ggplot2::scale_x_continuous(transform = "log")` for the log version.
* `foresty_layout()` holds every drawing decision the figure makes, and
  `layout` takes it, or the name of one of the styles it builds: `"classic"`,
  `"jama"`, `"nejm"`, `"lancet"`, `"bmj"` and `"revman"`. The styles set the
  colours, the marks, the rules, which side the numbers go on, and how the
  numbers and p-values are written; anything they set can be overridden.
* The figure is drawn on one shared scale across its panels, rather than a
  discrete scale in the plot and a continuous one beside it, so a number sits
  at exactly the height of the interval it belongs to. The rules, the shading
  and the lines between subgroups read across the whole width.
* Each column of text is as wide as the widest thing in it, in centimetres,
  and the plot takes the width they leave, so a figure carrying six columns of
  numbers no longer clips them, and widening the figure widens the plot and
  nothing else. `plot_width` takes a fraction, as `0.6`, to give the plot that
  share of the figure outright, or a number of centimetres to fix it.
* The column headings sit on the rule under them, the way the head of a column
  in a table does, rather than floating in the middle of the band above it, and
  the band is no deeper than the headings are.
* The heading the model writes for the estimate is wrapped rather than left to
  set the width of the widest column, `column_gap` tightens the space between
  one column of numbers and the next, and both leave the plot more of the
  figure.
* The row labels move into a column of their own as soon as there is a panel
  beside the plot to hold them, where they can be aligned and indented. A
  subgroup is named on a row above the rows it covers rather than in a column
  to their left, which is what `group_position = "column"` restores.
* `xlim` trims an interval that runs past the limits of the plot and marks it
  with an arrow, rather than letting one wide interval flatten the figure, and
  `arrows` labels the two directions under the axis.
* The interaction p-value is written once against each subgroup rather than
  repeated on every row of it.
* Estimates are drawn as filled squares on white, with the plot's furniture
  drawn rather than themed, so that a theme added afterwards cannot take the
  layout with it.
* `tidy()` returns broom's columns in broom's order, and a tibble when `tibble`
  is installed. The statistic is a signed z, or t, rather than the chi-square
  underneath it. `as.data.frame()` still returns everything the figure carries.
* Every figure says what it is of. `foresty_main()` writes
  `Adjusted odds ratio for NO2, from one model without an interaction term`,
  and `foresty_interaction()` writes what it used to write as a subtitle,
  `Adjusted odds ratio for NO2 within each level of Sex, from one model
  containing their interaction term`, rather than the modifier's name alone.
  Neither writes a subtitle any more, `title = NA` turns the title off, and the
  journal styles still leave it to the caption.
* The column of row labels carries a heading, as the columns of numbers beside
  the plot do: `Exposure` in `foresty_main()`, the modifier's name in
  `foresty_interaction()` and `Subgroup` in `foresty_combine()`. It is renamed
  through the layout, as `headings = c(label = "Pollutant")`. The labels move
  into that column even when nothing else is drawn beside the plot, which is
  what gives them a heading to sit under.
* `foresty_combine()` draws the overall estimate as the figure's summary rather
  than as another subgroup: a filled diamond half again the size of the other
  marks, the label in bold, and a rule between it and the subgroups under it,
  drawn whether or not the style rules between subgroups. `emphasize` says which blocks are drawn that way -- the
  overall ones by default, none of them under `emphasize = NULL` -- and
  `emphasis_shape`, `emphasis_size`, `emphasis_face` and `emphasis_gap` in the
  layout say how.
* A label can be written where the variable is named, as
  `interaction = c(Sex = "sex")` or `exposure = c(NO2 = "no2")`, which is the
  same convenience `foresty_combine(Sex = by_sex)` has for naming a block. It
  saves repeating the variable in `labels`, and wins over `labels` where both
  name the same variable.
* `foresty_interaction(test = )` chooses how the interaction is tested:
  `"wald"`, the joint Wald test, as before; `"lrt"`, the likelihood ratio test
  against the same model without the interaction; or `"both"`, which reports
  each in a column of its own. The likelihood ratio test is the more
  trustworthy of the two where the Wald approximation is poor -- a small study,
  a rare outcome, a sparse subgroup -- and has no robust form, so a figure
  asking for it alongside robust standard errors is told as much. `summary()`,
  `glance()`, `tidy()` and the HTML report carry whichever tests were taken.
* The likelihood ratio test is now the default, being the more trustworthy of
  the two where they disagree. It cannot always be taken -- a quasi-likelihood
  family and a GEE have no likelihood, and robust standard errors are no part
  of one -- so where the default cannot be honoured the Wald test is reported
  in its place and the reason is given; a test named by hand is still either
  given or refused. A mixed model fitted by REML is refitted by maximum
  likelihood before the test is taken, since a REML likelihood belongs to the
  fixed effects it was computed under.
* The table of numbers beside the plot is drawn by default. A forest plot is
  read from its numbers as much as from its marks, and `table = FALSE` still
  leaves a plain figure.
* A figure reporting a test of an interaction no longer draws the p-value of
  each row beside it. Two columns of p-values are read for each other however
  they are headed, and the one a reader reaches for is the test of the
  interaction; `columns = c(..., "p")` brings the other back.
* The column of interaction p-values is headed `p for interaction` rather than
  `Interaction p-value`, and the test is written once against the rows it was
  taken across rather than repeated on every row of a figure of one subgroup
  analysis.
* What follows the measure in a title is the outcome, which is what the measure
  is a measure of, and the exposure comes after it: `Adjusted odds ratio for
  asthma associated with NO2, from one model without an interaction term`. The
  axis under the plot names the outcome on every figure, a combined one
  included, and the column of estimates beside the plot is headed with the
  measure alone rather than naming the outcome a second time.
* `foresty_combine()` leaves the column of row labels unheaded when the figure
  carries an overall estimate. `Subgroup` sat directly above `Overall`, which
  is not a subgroup but the row the subgroups are read against; a figure of
  subgroups alone is headed as it was.
* `exponentiate = FALSE` leaves a ratio on the scale the model was fitted on,
  so that a figure reports a log odds ratio read against zero rather than an
  odds ratio read against one. `tidy()` and `summary()` follow it, and figures
  drawn on the two scales cannot be combined onto one axis.
* `lme4::lmer()` and `lme4::glmer()` are supported. Neither worked before: an
  S4 fit cannot be subsetted, and the package asked every fit for elements it
  keeps in a slot, which was an error rather than a missing value. What such a
  fit does not carry is now taken from its model frame and design matrix.
