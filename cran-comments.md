# cran-comments

This is the first submission of **foresty** (version 0.1.0).

## Test environments

* Local: Windows 11 x64 (build 26200), R 4.6.0 (2026-04-24 ucrt),
  platform `x86_64-w64-mingw32`, built with GCC 14.3.0 --
  `R CMD build` followed by `R CMD check --as-cran`.

* win-builder, R Under development (unstable), Windows Server 2022 x64
  (build 20348).

* win-builder, R release, Windows Server 2022 x64 (build 20348).

* GitHub Actions, `R CMD check --as-cran` on each of:

  * Ubuntu 24.04, R-devel
  * Ubuntu 24.04, R release
  * Ubuntu 24.04, R oldrel-1
  * macOS, R release
  * Windows Server, R release

## R CMD check results

0 errors | 0 warnings | 1 note.

The note is the expected one for a package not yet on CRAN:

```
* checking CRAN incoming feasibility ... NOTE
Maintainer: 'Akihiro Shiroshita <akihirokun8@gmail.com>'

New submission
```

Every other check reports OK, including the examples (15 seconds for the
timed run, 48 seconds with `--run-donttest`), the re-building of the vignette
and the test suite.

## Notes on the package

`'MASS'` and `'nnet'` in the Description are the names of the two packages
whose fits are supported for ordinal and nominal outcomes; both are quoted as
package names should be.

The test suite runs under `testthat` edition 3: 241 tests across 14 files.
The 52 tests of the Shiny interface in `test-app.R` are marked
`skip_on_cran()`, since they drive the app's server function and re-run the R
code it writes and are by a wide margin the slowest file in the suite. That
leaves 189 tests and 807 expectations on CRAN, none failing, in 228 seconds
locally. With `NOT_CRAN=true` -- which is how they run on all five GitHub
Actions platforms above -- all 241 tests run, giving 1119 expectations, again
none failing and none skipped.
