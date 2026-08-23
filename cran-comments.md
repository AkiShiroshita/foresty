# cran-comments

This is the first submission of **foresty** (version 0.1.0).

## Test environments

* Local: Windows 11 x64 (build 26200), R 4.6.0 (2026-04-24 ucrt),
  platform `x86_64-w64-mingw32`, built with GCC 14.3.0 --
  `R CMD build` followed by `R CMD check --as-cran`.

* win-builder, R Under development (unstable) (2026-08-22 r90443 ucrt),
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
note is the expected one for a package not yet on CRAN:

```
* checking CRAN incoming feasibility ... NOTE
Maintainer: 'Akihiro Shiroshita <akihirokun8@gmail.com>'

New submission
```

Each of the five GitHub Actions platforms reports `Status: OK` -- 0 errors,
0 warnings, 0 notes -- since the incoming-feasibility check does not run
there.

Every other check reports OK, including the examples, the re-building of the
vignette outputs, the PDF and HTML manuals and the test suite.

## The examples and the test suite

The examples that show a function's every variation one after another are in
`\donttest{}`, since there are several of them rather than because any one is
slow. `R CMD check --as-cran` runs them: locally the timed pass takes 15
seconds and the `--run-donttest` pass 48 seconds, and win-builder runs the
examples in 17 seconds under R-devel and 15 seconds under R release.

The tests run under `testthat` edition 3: 241 tests across 14 files. The 52
tests of the Shiny interface in `test-app.R` are marked `skip_on_cran()`.
They drive the app's server function and re-run the R code it writes, which
made that one file 197 of the suite's 329 seconds, and skipping it keeps the
check comfortably inside the time CRAN allows. That leaves 189 tests and 807
expectations, none failing, in 229 seconds locally, 268 on win-builder
R-devel and 160 on win-builder R release. With `NOT_CRAN=true`, which is how
they run on all five GitHub Actions platforms above, all 241 tests run,
giving 1119 expectations, again none failing and none skipped.
