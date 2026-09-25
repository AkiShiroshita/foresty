# cran-comments

This is an update of **foresty** from 0.1.0, published on CRAN on
2026-09-12, to 0.2.0.

## Why this update comes soon after 0.1.0

I am aware that it follows 0.1.0 by only a couple of weeks. It carries one
correction to the output of 0.1.0: a model fitted with a `quasibinomial`
family and a logit link was reported as a raw coefficient, drawn about zero,
while the report beside it already called the model a logistic regression. It
is now read as an odds ratio, as a `binomial` fit is. Users fitting such models
get a figure on the wrong scale from 0.1.0, and I would rather not leave that
in place for a further month or two.

The update also adds:

* support for fits from `survey::svyglm()`, with design-based variances and
  the Rao-Scott test of the interaction that `survey` itself reports
  (`survey` is in `Suggests`; the package calls it only when handed a
  `svyglm` fit, and the tests that need it use `skip_if_not_installed()`);
* a `color` argument to `foresty_data()`;
* F tests written with both of their degrees of freedom.

## Test environments

* Local: Windows 11 x64 (build 26200), R 4.6.0 (2026-04-24 ucrt) --
  `R CMD build` followed by `R CMD check --as-cran`.
* win-builder, R 4.6.1 (2026-06-24 ucrt), Windows Server 2022 x64
  (build 20348).
* GitHub Actions, `R CMD check --as-cran` on each of:
  * Ubuntu 24.04, R-devel
  * Ubuntu 24.04, R release
  * Ubuntu 24.04, R oldrel-1
  * macOS, R release
  * Windows Server, R release

## R CMD check results

Locally: 0 errors | 0 warnings | 0 notes.

On win-builder: 0 errors | 0 warnings | 1 note, the incoming-feasibility one:

```
* checking CRAN incoming feasibility ... NOTE
Maintainer: 'Akihiro Shiroshita <akihirokun8@gmail.com>'

Possibly misspelled words in DESCRIPTION:
  Knol (37:63)
  VanderWeele (37:47)
  al (39:38)
  et (39:35)
```

These are the surnames VanderWeele and Knol and the `et al.` of the
references cited in `Description`, unchanged since 0.1.0. They are spelled as
they are printed.

## Reverse dependencies

There are no reverse dependencies on CRAN.

## Current CRAN checks

All twelve flavors report OK for 0.1.0.
