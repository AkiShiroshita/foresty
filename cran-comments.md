# cran-comments

This is a resubmission of **foresty** (version 0.1.0), the package's first
submission. Thank you for the review. Each of the four points is answered
below, and the changes are in the tarball rather than only described here.

## Resubmission: the points raised

### References in the `Description` field

Four references are now cited in `Description`, in the requested form
`authors (year) <doi:...>`, with no space after `doi:`:

* Altman and Bland (2003) <doi:10.1136/bmj.326.7382.219> and VanderWeele and
  Knol (2014) <doi:10.1515/em-2013-0005>, for estimating an exposure effect
  within a level of a modifier and testing the difference between two such
  estimates, which is what the package computes.
* Wang et al. (2007) <doi:10.1056/NEJMsr077003>, for reporting subgroup
  effects beside the interaction test rather than on their own, which is the
  layout the figure draws.
* Lewis and Clarke (2001) <doi:10.1136/bmj.322.7300.1479>, for the forest
  plot itself.

Each DOI was checked against Crossref and resolves.

### `\dontrun{}`

The one `\dontrun{}` block in the package, in `?foresty_report`, is gone. It
was there because `html = TRUE` writes the report into the working directory
under a name taken from the variables, and an example should not write there.
The two calls are now inside the `\donttest{}` block above them and pass a
path under `tempdir()` instead, so they run under `--run-donttest` and write
nothing outside the session's temporary directory. What `html = TRUE` does on
its own is said in the comment beside them.

No `\dontrun{}` remains anywhere in the package. The `\donttest{}` blocks in
`?foresty_main`, `?foresty_interaction` and `?foresty_combine` are the ones
described under "The examples and the test suite" below: each call in them is
quick, and they are set aside only because there are many of them.

### Messages written to the console

`R/app.R` no longer writes to the console. The two panels of the Shiny
interface that are text -- "Models", which writes out the analysis as the R it
amounts to, and "summary(fit)", which shows the models the app fitted -- were
built with `cat()` inside `shiny::renderPrint()`. The functions behind them
now add their lines to a buffer and hand back one string, which
`shiny::renderText()` gives to the panel; `fy_app_collect()`, `fy_app_say()`
and `fy_app_say_printed()` in `R/app.R` are the whole of that. Nothing in the
file writes to `stdout` any more.

The two remaining `print()` calls in `R/app.R` drew a figure rather than wrote
text, and are now `plot()`, which says so.

A grep of `R/app.R` for `cat(` still matches three lines, none of them a call
the package makes. Line 3113 is inside a string: the app writes out the R code
behind a figure for the user to copy and run in their own session, and that
code prints the interaction p-value when it is run. The other two, lines 3368
and 3383, are in the comment describing the buffer that replaced `cat()`.

Elsewhere the package already works the way the comment asks. `foresty_main()`
and `foresty_interaction()` return an object carrying the estimates and the
tests; `summary()` returns a `summary.foresty` object; the estimates come out
as a data frame through `foresty_data()`, `as.data.frame()` or
`broom::tidy()`. The only other `cat()` calls in `R/` are inside the
`print.foresty_layout()` and `print.summary.foresty()` methods, which is the
exception the comment names. Notes about a fit that a caller should know about
-- a modifier with an empty level, a rank-deficient interaction -- are raised
with `message()` or `warning()`, so `suppressMessages()` silences them.

### Options, graphical parameters and the working directory

The package sets no options and no graphical parameters. Across `R/`, `grep`
for `par(`, `Sys.setenv(` and `Sys.setlocale(` returns nothing. The one line
matching `options(` is `gt::tab_options()` in `R/report.R`, which sets the font
size of a table the report draws; it is not an R option and it leaves nothing
behind.

There is one `setwd()`, in `fy_app_zip()` in `R/app.R`: `utils::zip()` names
the files it archives relative to the working directory, so the directory has
to be the one holding them for the length of that call. It is now written in
the form the comment asks for -- `getwd()`, then `on.exit(setwd(oldwd))`, then
`setwd()` -- so the directory is restored however the call returns, including
on an error inside it. The graphics device opened to write a figure is closed
the same way, by an `on.exit()` registered as it is opened.


## Test environments

* Local: Windows 11 x64 (build 26200), R 4.6.0 (2026-04-24 ucrt),
  platform `x86_64-w64-mingw32`, built with GCC 14.3.0 --
  `R CMD build` followed by `R CMD check --as-cran`.

* win-builder, R Under development (unstable) (2026-08-31 r90457 ucrt),
  Windows Server 2022 x64 (build 20348).

* win-builder, R 4.6.1 (2026-06-24 ucrt), Windows Server 2022 x64
  (build 20348).

* GitHub Actions, `R CMD check --as-cran` on each of:

  * Ubuntu 24.04, R-devel
  * Ubuntu 24.04, R release
  * Ubuntu 24.04, R oldrel-1
  * macOS, R release
  * Windows Server, R release

## R CMD check results

Locally and on both win-builder runs: 0 errors | 0 warnings | 1 note. The
note is the incoming-feasibility one, which both win-builder runs report in
this form:

```
* checking CRAN incoming feasibility ... NOTE
Maintainer: 'Akihiro Shiroshita <akihirokun8@gmail.com>'

New submission

Possibly misspelled words in DESCRIPTION:
  Knol (37:63)
  VanderWeele (37:47)
  al (39:38)
  et (39:35)
```

The first part is expected of a package not yet on CRAN. The words in the
second are the surnames VanderWeele and Knol, cited in the references added to
`Description` at the reviewer's request, and the `et al.` of a third citation.
All four are spelled as they are printed, so nothing is corrected.

Each of the five GitHub Actions platforms reports `Status: OK` -- 0 errors,
0 warnings, 0 notes -- since the incoming-feasibility check does not run
there.

Every other check reports OK, including the examples, the re-building of the
vignette outputs, the PDF and HTML manuals and the test suite.

## The examples and the test suite

The examples that show a function's every variation one after another are in
`\donttest{}`, since there are several of them rather than because any one is
slow. `R CMD check --as-cran` runs them: locally the timed pass takes 16
seconds and the `--run-donttest` pass 49 seconds; win-builder runs the
examples in 11 seconds under R-devel and 10 seconds under R release.

The tests run under `testthat` edition 3: 252 tests across 14 files. The 53
tests of the Shiny interface in `test-app.R` are marked `skip_on_cran()`.
They drive the app's server function and re-run the R code it writes, which
makes that one file much the slowest of the suite, and skipping it keeps the
check comfortably inside the time CRAN allows. That leaves 199 tests and 841
expectations, none failing, in 237 seconds locally, 112 on win-builder
R-devel and 117 on win-builder R release. With `NOT_CRAN=true`, which is how
they run on all five GitHub Actions platforms above, all 252 tests run,
giving 1159 expectations, again none failing and none skipped.
