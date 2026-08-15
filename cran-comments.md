# cran-comments

This is the first submission of **foresty** (version 0.0.1).

## Test environments

* Local: Windows 11 x64 (build 26200), R 4.6.0 (2026-04-24 ucrt),
  platform `x86_64-w64-mingw32`, built with GCC 14.3.0 --
  `R CMD build` followed by `R CMD check --as-cran`.

## R CMD check results

0 errors | 0 warnings | 1 note

```
* checking CRAN incoming feasibility ... NOTE
Maintainer: 'Akihiro Shiroshita <akihirokun8@gmail.com>'

New submission
```

The note is the expected one for a package not yet on CRAN.

`R CMD check` reports OK for every other check, including the examples
(17 seconds) and the test suite (141 seconds; `testthat` edition 3, 183 tests
and 765 expectations across 12 files, none failing and none skipped on this
machine).

## Notes for the reviewer

* **The package fits no models of its own.** It is given a model the user has
  already fitted and reports the exposure effect from its coefficients and
  covariance matrix, so nothing in the examples or the tests is long-running:
  every fit in them is a small `glm()`, `lm()` or `coxph()` on the 4,000-row
  `foresty_cohort` data set shipped with the package.

* **Nothing is written outside the session.** `foresty_report()` writes an HTML
  page only where a file is named; its example writes into `tempdir()`, and the
  `html = TRUE` form, which names the file for the variables it is about and so
  writes into the working directory, is wrapped in `\dontrun{}`.

* **`foresty_app()` opens a Shiny app**, so its example is guarded by
  `if (interactive())`. The app itself is exercised by the tests through
  `shiny::testServer()`, and `shiny` is in Suggests, not Imports.

* **Linear combinations and their tests are delegated to `car`** rather than
  reimplemented, which is why `car` is imported rather than suggested.

* Package, software and API names are quoted in the `Description` field
  (`'foresty'`, `'car'`, `'survival'`, `'lme4'`, `'geepack'`, `'rms'`).

* Every suggested package a function reaches for -- `base64enc`, `broom`,
  `gt`, `lme4`, `ragg`, `sandwich`, `shiny`, `svglite`, `tibble`, `zip` -- is
  behind `requireNamespace()`, either directly or through the package's own
  `fy_require()` helper, which is what turns a missing package into a sentence
  naming it and what it was wanted for. Every test needing a suggested package
  is behind `skip_if_not_installed()`.

## Downstream dependencies

None; this is a new package.
