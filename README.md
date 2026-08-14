

(Under construction)

# foresty

Visualize interaction effects with publication-ready forest plots.

An interaction p-value tells you whether the effect differs between
subgroups, but not **which subgroup shows the effect, in which
direction, or by how much**. `foresty` puts the interaction test and the
subgroup estimates side by side, making interaction effects easier to
interpret and report.

It also makes **publication-ready** forest plots easy to produce, with a
Shiny app for exploring the results interactively and an **HTML report**
that documents the model behind them.

## Try it first

Installation:

``` r
# install.packages("devtools")
remotes::install_github("AkiShiroshita/foresty")
```

Start with a model **without an interaction term** and let `foresty`
explore possible exposure–modifier interactions:

``` r
library(foresty)

fit <- glm(
  asthma ~ no2 + sex + maternal_smoking + maternal_age,
  family = binomial,
  data = foresty_cohort
)

foresty_app(fit)
```

The app lets you select exposures and effect modifiers, choose how big a
difference in the exposure each estimate is for — an interquartile
range, two quantiles of it, an increment of your own — adjust the figure
style, and produce forest plots and reports without having to remember
the plotting code.

It also writes out the **R code that drew the figures**, so interactive
exploration becomes a reproducible script.

## Use it in R

`foresty` has three main functions (see the vignettes for details):

1.  **`foresty_main()`** — draws the effect of one or more exposures
    from models you have already fitted.
2.  **`foresty_interaction()`** — the core of the package: it adds the
    exposure × modifier interaction to a fitted model, estimates the
    exposure effect within each level of the modifier, and tests the
    interaction.
3.  **`foresty_combine()`** — puts an overall estimate and several
    subgroup analyses into one publication-ready figure.

## Publication-ready styles

`foresty` provides several predefined styles:

| Style       | Description                         |
|-------------|-------------------------------------|
| `"classic"` | Simple forest plot with a null line |
| `"jama"`    | JAMA-inspired layout                |
| `"nejm"`    | NEJM-inspired layout                |
| `"lancet"`  | Lancet-inspired layout              |
| `"bmj"`     | BMJ-inspired layout                 |
| `"revman"`  | Cochrane RevMan-inspired layout     |

Styles are approximations of journal layouts rather than official
journal templates.

The output can be customized further with ordinary `ggplot2` layers, and
it can be passed to `summary()`, `predct()`, `broom::tidy()`, and
`broom::glance()`, etc.

## Supported models

`foresty` works with fitted models that provide coefficients, a
covariance matrix, and a model frame. Tested model classes include:

| Package    | Models                                                  |
|------------|---------------------------------------------------------|
| base R     | `glm()`, `lm()`                                         |
| `survival` | `coxph()`, `survreg()`                                  |
| `rms`      | `lrm()`, `cph()`, `ols()`, `Glm()`, `psm()`             |
| `lme4`     | `lmer()`, `glmer()`                                     |
| other      | `MASS::polr()`, `nnet::multinom()`, `geepack::geeglm()` |

The effect measure is inferred from the model where possible, including
odds ratios, hazard ratios, risk ratios, incidence rate ratios, and mean
differences.

Robust and cluster-robust standard errors are also supported where
applicable.

## What foresty does not do

`foresty` is intentionally focused on **two-way exposure × modifier
interactions**.

- **No three-way interactions.** One call handles one exposure and one
  modifier. Multiple modifiers can be shown as separate blocks with
  `foresty_combine()`, but they are not crossed with each other.
- **No automatic categorization of continuous modifiers.** If a
  continuous modifier should be categorized, choose the cut points
  yourself and refit the model.
- **No separate subgroup refitting.** `foresty` estimates subgroup
  effects from one model containing the interaction rather than fitting
  separate models within each subgroup.

## Acknowledgements

- Claude Code (Anthropic’s Claude Opus 5) assisted with adding notes,
  testing and English-language proofreading. The design, decisions and
  final responsibility remain the author’s.

- Subgroup-specific effect sizes are computed through
  [car](https://github.com/bprice2652/car_repo).

- The forest plot designs took their cues from
  [meta](https://github.com/guido-s/meta).

## License

GPL-3.
