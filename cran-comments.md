# cran-comments

This is the first submission of **foresty** (version 0.0.1).

## Test environments

* Local: Windows 11 x64 (build 26200), R 4.6.0 (2026-04-24 ucrt),
  platform `x86_64-w64-mingw32`, built with GCC 14.3.0 --
  `R CMD build` followed by `R CMD check --as-cran`.

* win-builder, R Under development (unstable) (2026-08-15 r90413 ucrt),
  Windows Server 2022 x64 (build 20348) -- `Status: 1 NOTE`.

* GitHub Actions, `R CMD check --as-cran` on each of:

  * Ubuntu 24.04, R-devel
  * Ubuntu 24.04, R release
  * Ubuntu 24.04, R oldrel-1
  * macOS, R release
  * Windows Server, R release

## R CMD check results

Every GitHub Actions platform above reports `Status: OK` -- 0 errors, 0
warnings, 0 notes.

win-builder reports 0 errors | 0 warnings | 1 note, and locally the result is
0 errors | 0 warnings | 2 notes.

The first note is the expected one for a package not yet on CRAN:

```
* checking CRAN incoming feasibility ... NOTE
Maintainer: 'Akihiro Shiroshita <akihirokun8@gmail.com>'

New submission
```

The second note is raised only on the local machine, and is a timing one:

```
* checking examples ... NOTE
Examples with CPU (user + system) or elapsed time > 5s
             user system elapsed
foresty_main 4.98   0.36    5.41
```

`foresty_main()` fits the models its figure is drawn from, and the example
sits just over the five-second line on this machine. The examples check
reports OK on win-builder, which runs all of them in 23 seconds, and on all
five platforms above.

`R CMD check` reports OK for every other check, including the test suite
(181 seconds on win-builder, 248 seconds locally; `testthat` edition 3, 204
tests and 856 expectations across 13 files, none failing and none skipped).
