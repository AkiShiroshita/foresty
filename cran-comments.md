# cran-comments

This is the first submission of **foresty** (version 0.0.1).

## Test environments

* Local: Windows 11 x64 (build 26200), R 4.6.0 (2026-04-24 ucrt),
  platform `x86_64-w64-mingw32`, built with GCC 14.3.0 --
  `R CMD build` followed by `R CMD check --as-cran`.

* Posit Cloud / Linux (R 4.6.1 on Ubuntu 24.04.4 LTS (x86_64))

* Windows Server (Windows Server 2022 Standard (Version 21H2), x86_64)

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
