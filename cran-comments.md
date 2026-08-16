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

Possibly misspelled words in DESCRIPTION:
  reimplemented (24:47)
```

"reimplemented" is spelled as intended. It is used in its ordinary sense --
the linear combinations are computed by the 'car' package rather than written
again inside this package -- and is simply absent from the dictionary the
check consults.

The second note is raised only on the local machine, and is a timing one:

```
* checking examples ... NOTE
Examples with CPU (user + system) or elapsed time > 5s
               user system elapsed
foresty_report 1.41   0.16    7.53
```

The example writes a self-contained HTML report to `tempdir()`. Its CPU time
is 1.57 seconds; the elapsed time is the write itself on a machine whose
temporary directory sits on a synchronised drive. The examples check reports
OK on win-builder (21 seconds for all of them) and on all five platforms
above, where the same example is well inside the limit, so the note is a
property of this one machine rather than of the package.

`R CMD check` reports OK for every other check, including the test suite
(184 seconds on win-builder, 157 seconds locally; `testthat` edition 3, 204
tests and 856 expectations across 13 files, none failing and none skipped).
