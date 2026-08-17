# cran-comments

This is the first submission of **foresty** (version 0.0.1).

## Test environments

* Local: Windows 11 x64 (build 26200), R 4.6.0 (2026-04-24 ucrt),
  platform `x86_64-w64-mingw32`, built with GCC 14.3.0 --
  `R CMD build` followed by `R CMD check --as-cran`.

* win-builder, R Under development (unstable) (2026-08-15 r90413 ucrt),
  Windows Server 2022 x64 (build 20348) -- `Status: 1 NOTE`.

* win-builder, R 4.6.1 (2026-06-24 ucrt), Windows Server 2022 x64
  (build 20348) -- `Status: 1 NOTE`.

* GitHub Actions, `R CMD check --as-cran` on each of:

  * Ubuntu 24.04, R-devel
  * Ubuntu 24.04, R release
  * Ubuntu 24.04, R oldrel-1
  * macOS, R release
  * Windows Server, R release

## R CMD check results

Every GitHub Actions platform above reports `Status: OK` -- 0 errors, 0
warnings, 0 notes.

Both win-builder runs report 0 errors | 0 warnings | 1 note, and locally the
result is 0 errors | 0 warnings | 2 notes.

The note shared by all three is the expected one for a package not yet on
CRAN:

```
* checking CRAN incoming feasibility ... NOTE
Maintainer: 'Akihiro Shiroshita <akihirokun8@gmail.com>'

New submission
```

Under that same note the win-builder R release run also lists
`reimplemented` as a possibly misspelled word in DESCRIPTION. That run was
made on an earlier Description text; the word does not appear in the
Description submitted here, and the win-builder R-devel run above, made on
the current text, reports the new-submission note alone.

The second note is raised only on the local machine, and is a timing one:

```
* checking examples ... NOTE
Examples with CPU (user + system) or elapsed time > 5s
             user system elapsed
foresty_main 4.98   0.36    5.41
```

`foresty_main()` fits the models its figure is drawn from, and the example
sits just over the five-second line on this machine. The examples check
reports OK on win-builder, which runs all of them in 23 seconds under R-devel
and 21 seconds under R release, and on all five platforms above.

`R CMD check` reports OK for every other check, including the test suite
(181 seconds on win-builder R-devel, 175 seconds on win-builder R release,
248 seconds locally; `testthat` edition 3, 223 tests and 992 expectations
across 13 files, none failing and none skipped).
