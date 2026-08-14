#' Exposure effect within each level of an effect modifier
#'
#' Takes a model that does not yet interact the exposure with the modifier,
#' updates it with the interaction term, and estimates the exposure effect
#' separately within every level of the modifier. The estimates are drawn one
#' level above the other, a row to a level, and can be written to a
#' self-contained HTML page carrying the joint test of the interaction.
#'
#' The point is to make an interaction readable. The p-value of an interaction
#' term reports only that the subgroups depart from a common effect; it does
#' not say which subgroup carries the effect, in which direction, or how far
#' apart they are, and a small p-value from a large study can accompany
#' subgroup estimates that are practically identical. Seeing the
#' subgroup-specific estimates and the test together is what settles whether an
#' interaction is worth reporting.
#'
#' Each subgroup effect is a linear combination of the coefficients of the
#' single interaction model, not a separate model fitted in each subgroup: in
#' the reference level of the modifier it is the exposure term alone, and in
#' the other levels it is the exposure term plus the relevant interaction
#' terms. Every subgroup therefore shares one estimate of the covariate
#' effects, and the interaction can be tested. The combinations and their
#' tests are computed by [car::linearHypothesis()].
#'
#' @section Testing the interaction:
#'
#' The p-value beside the subgroups is the joint test that every exposure by
#' modifier coefficient is zero. It is the likelihood ratio test by default,
#' comparing the likelihood of the model carrying the interaction with that of
#' the same model without it.
#'
#' `test = "wald"` takes the joint Wald test over the coefficients and their
#' covariance instead, which is what a model summary reports and what a robust
#' or cluster-robust variance changes. The two tests answer the same question
#' and usually agree; they part company where the Wald approximation is poor --
#' a small study, a rare outcome, a sparse subgroup, an estimate far from the
#' null -- and the likelihood ratio test is the more trustworthy of the two
#' there, which is why it is the default. `test = "both"` reports each in a
#' column of its own, which is a way of showing that the reported p-value does
#' not turn on which test was chosen.
#'
#' The likelihood ratio test is computed from the likelihood, so it has no
#' robust form: it takes no account of a variance passed through `vcov` or
#' `cluster`. A quasi-likelihood family and a GEE have no likelihood to take it
#' over at all. Where it cannot be taken, or where it would not match the
#' intervals drawn beside it, the Wald test is reported in its place and
#' `foresty` says so; ask for one by name and you are given that one or an
#' error. For a linear model it is the chi-square form rather than the exact F
#' test, which is what the Wald test gives there.
#'
#' @inheritSection foresty_main Adjusting the figure
#'
#' @inheritParams foresty_main
#' @param fit A fitted model. If it already contains the exposure by modifier
#'   interaction it is used as it stands; otherwise it is updated to add it.
#' @param exposure Name of the exposure variable, as a character string.
#'   Naming it, as `exposure = c(NO2 = "no2")`, gives it that label on the
#'   figure, which saves repeating it in `labels`.
#' @param interaction Name of the effect modifier, as a character string, and
#'   named as `interaction = c(Sex = "sex")` where the figure is to call it
#'   something other than what the column is called. It must be a factor with
#'   at least two levels. A continuous modifier is rejected: categorize it with
#'   [cut()] first, so that the subgroups being compared are the ones you
#'   intend.
#' @param level_labels Named character vector giving the label to draw for a
#'   level of the modifier, as `c(F = "Female", M = "Male")`.
#' @param test How the interaction is tested: `"lrt"`, the default, is the
#'   likelihood ratio test against the same model without the interaction
#'   terms; `"wald"` is the joint Wald test of those terms; `"both"` reports
#'   the two of them in columns of their own. See *Testing the interaction*.
#' @param title Plot title. The default names the measure, the outcome it is a
#'   measure of, the exposure, the modifier and the fact that every subgroup
#'   estimate comes out of one model carrying their interaction term, as
#'   `"Adjusted odds ratio for asthma associated with NO2 within each level of
#'   Sex, from one model containing their interaction term"`. `NA` draws none,
#'   and the journal styles draw none, a caption being where a journal puts
#'   that.
#' @param subtitle Plot subtitle. `NULL`, the default, draws none.
#' @param html Whether to write the HTML report. `FALSE`, the default, writes
#'   nothing, so nothing leaves the session unless it is asked for. `TRUE`
#'   writes it to a file named for the variables it is about, the exposure and
#'   the modifier joined by an underscore, so that NO2 by sex is written to
#'   `no2_sex.html` in the working directory. A path writes it there instead,
#'   as `html = "reports/no2_sex.html"`. The report can also be written at any
#'   time afterwards with [foresty_report()].
#'
#' @return A `ggplot2` object, of class `foresty`, carrying the estimates and
#'   the interaction test. Print it to draw it. [summary()] reports the
#'   coefficients and the test, and [tidy()] returns the estimates as a data
#'   frame.
#'
#' @seealso [foresty_main()], [foresty_layout()], [foresty_report()].
#'
#' @examples
#' fit <- glm(asthma ~ no2 + sex + maternal_smoking + maternal_age,
#'            family = binomial, data = foresty_cohort)
#'
#' # Sex, where the interaction is real.
#' by_sex <- foresty_interaction(fit, exposure = "no2", interaction = "sex")
#' by_sex
#' summary(by_sex)
#'
#' # Maternal smoking, where it is not.
#' foresty_interaction(fit, exposure = "no2", interaction = "maternal_smoking")
#'
#' # Naming the modifier labels it, and both tests of the interaction can be
#' # reported side by side.
#' foresty_interaction(fit, exposure = c(NO2 = "no2"),
#'                     interaction = c(Sex = "sex"), test = "both")
#'
#' # The subgroup estimates, the numbers behind them and the test of the
#' # interaction, in the layout of a journal.
#' foresty_interaction(fit, exposure = "no2", interaction = "sex",
#'                     layout = "jama")
#'
#' @export
foresty_interaction <- function(fit,
                                exposure,
                                interaction,
                                measure = NULL,
                                exponentiate = TRUE,
                                labels = NULL,
                                level_labels = NULL,
                                ci_level = 0.95,
                                contrast = 1,
                                at = NULL,
                                vcov = NULL,
                                cluster = NULL,
                                test = c("lrt", "wald", "both"),
                                table = TRUE,
                                columns = NULL,
                                layout = NULL,
                                title = NULL,
                                subtitle = NULL,
                                html = FALSE) {
  # A label written where the variable is named -- `interaction = c(Sex =
  # "sex")` -- says what to call it as well as which one is meant.
  labels <- fy_absorb_labels(interaction, fy_absorb_labels(exposure, labels))
  exposure <- unname(exposure)
  interaction <- unname(interaction)

  checkmate::assert_string(exposure)
  checkmate::assert_string(interaction)
  checkmate::assert_number(ci_level, lower = 0.5, upper = 0.9999)
  checkmate::assert_flag(table)
  # A test chosen by hand is the one that is reported, or an error saying why it
  # could not be; the default one falls back to the Wald test where the
  # likelihood ratio test cannot be taken or would not match the intervals.
  chosen <- !missing(test)
  test <- match.arg(test)
  layout <- fy_as_layout(layout)
  if (identical(exposure, interaction)) {
    stop("`exposure` and `interaction` name the same variable, \"",
         exposure, "\"", call. = FALSE)
  }

  base_info <- fy_model_info(fit, measure = measure)
  fy_check_modifier(base_info, interaction)

  already <- fy_has_interaction(base_info, exposure, interaction)
  fit_int <- fy_add_interaction(fit, base_info, exposure, interaction,
                                already = already)
  info <- fy_model_info(fit_int, measure = measure,
                        exponentiate = exponentiate, vcov = vcov,
                        cluster = cluster)

  interaction_columns <- fy_modifier_interaction_columns(info, exposure, interaction)
  if (!length(interaction_columns)) {
    stop(
      "the updated model has no coefficient for the \"", exposure, "\" by \"",
      interaction, "\" interaction, so there is nothing to explore; check that ",
      "both variables vary in the data the model was fitted to",
      call. = FALSE
    )
  }

  modifier_levels <- levels(droplevels(as.factor(info$mf[[interaction]])))
  values <- fy_exposure_values(info, exposure, contrast = contrast, at = at)

  estimates <- do.call(rbind, lapply(modifier_levels, function(lv) {
    out <- fy_exposure_estimates(info, exposure, values, ci_level = ci_level,
                                 modifier = interaction, modifier_level = lv)
    out$modifier_level <- lv
    out
  }))

  tests <- fy_interaction_tests(
    info, interaction_columns, test = test, fit = fit, base_info = base_info,
    exposure = exposure, interaction = interaction, already = already,
    chosen = chosen
  )
  # The first test is the one the figure reports; a figure asked for both
  # carries the Wald test in the column it always had and the likelihood ratio
  # test in one of its own beside it.
  estimates$interaction_p <- tests[[1L]]$p.value
  if (length(tests) > 1L) {
    estimates$interaction_p_lrt <- tests$lrt$p.value
  }
  estimates$modifier <- interaction
  estimates <- fy_finish_estimates(estimates, labels)
  estimates$modifier_label <- factor(
    fy_apply_labels(estimates$modifier_level, level_labels),
    levels = fy_apply_labels(modifier_levels, level_labels)
  )

  adjusted <- fy_is_adjusted(info, exposure, interaction)
  modifier_label <- fy_apply_labels(interaction, labels)

  # The modifier names the column of its own levels, and the title says which
  # effect is being shown and that it came out of one model carrying the
  # interaction rather than out of a model fitted in each subgroup. A journal
  # prints that in the caption instead, so its styles write no title of their
  # own.
  label_header <- layout$headings$label %||% modifier_label
  # The exposure is named as the rows name it, which is with the comparison
  # behind it -- "no2 (per 10)", "no2 (20 vs 10)" -- since every row of the
  # figure is that comparison taken within another subgroup.
  title <- fy_resolve_title(title, layout, paste0(
    fy_effect_phrase(info, adjusted,
                     fy_and(unique(as.character(estimates$variable_label)))),
    " within each level of ", modifier_label,
    ", from one model containing their interaction term"
  ))

  plot <- fy_forest_plot(
    estimates,
    exponentiate = info$exponentiate,
    measure_label = fy_axis_label(info, adjusted),
    estimate_header = fy_estimate_header(info, adjusted, ci_level,
                                         with_outcome = FALSE),
    table = table,
    columns = columns,
    group = "modifier_label",
    title = title,
    subtitle = subtitle,
    layout = layout,
    label_header = label_header
  )

  out <- fy_new_result(
    plot,
    estimates = estimates,
    infos = list(info),
    exposure = exposure,
    modifier = interaction,
    modifier_display = modifier_label,
    interaction_test = tests[[1L]],
    interaction_tests = tests,
    measure = info$measure,
    measure_label = info$measure_label,
    exponentiate = info$exponentiate,
    ci_level = ci_level,
    adjusted = adjusted,
    robust = info$robust
  )

  file <- fy_report_file(html, exposure, interaction)
  if (!is.null(file)) {
    foresty_report(out, file = file)
  }
  out
}

# The modifier has to be categorical. A continuous one would silently be
# contrasted at a single arbitrary value, which is worse than refusing.
fy_check_modifier <- function(info, interaction) {
  if (!interaction %in% names(info$mf)) {
    stop(
      "\"", interaction, "\" is not a variable in this model. Its variables are ",
      paste0("\"", names(info$mf), "\"", collapse = ", "), ".",
      call. = FALSE
    )
  }
  x <- info$mf[[interaction]]
  if (inherits(x, "rms") || (is.matrix(x) && ncol(x) > 1L)) {
    stop(
      "\"", interaction, "\" enters this model through an rms transformation ",
      "rather than as a plain factor, so its levels are not available. Pass ",
      "the variable itself as the modifier and let it enter the formula ",
      "unmodified.",
      call. = FALSE
    )
  }
  if (is.numeric(x)) {
    stop(
      "\"", interaction, "\" is continuous, and foresty does not split a ",
      "continuous modifier for you. Categorize it first, for example ",
      "`data$", interaction, "_grp <- cut(data$", interaction,
      ", breaks = quantile(data$", interaction,
      ", 0:3/3), include.lowest = TRUE)`, refit, and pass the new variable.",
      call. = FALSE
    )
  }
  if (nlevels(droplevels(as.factor(x))) < 2L) {
    stop(
      "\"", interaction, "\" takes only one value in the data this model was ",
      "fitted to, so there are no subgroups to compare",
      call. = FALSE
    )
  }
  invisible(TRUE)
}

# The tests of the interaction the caller asked for, in the order they are
# reported. The Wald test comes out of the fitted model on its own; the
# likelihood ratio test needs the model without the interaction as well, which
# is the model that was passed in unless it already carried the interaction, in
# which case it has to be taken out again.
#
# `chosen` says whether the caller named the test. The likelihood ratio test is
# the default, and it cannot always be taken -- a GEE and a quasi-likelihood
# family have no likelihood, and a robust variance is no part of one -- so a
# default falls back to the Wald test and says that it did, while a test asked
# for by name is either given or refused.
fy_interaction_tests <- function(info, columns, test, fit, base_info, exposure,
                                 interaction, already, chosen = TRUE) {
  out <- list()
  if (test %in% c("wald", "both")) {
    out$wald <- fy_joint_test(info, columns)
  }
  if (test %in% c("lrt", "both")) {
    if (isTRUE(info$robust)) {
      if (!chosen) {
        message(
          "The standard errors are robust, and the likelihood ratio test takes ",
          "no account of them, so the joint Wald test is reported instead. Ask ",
          "for it with `test = \"lrt\"` to have it anyway."
        )
        return(list(wald = out$wald %||% fy_joint_test(info, columns)))
      }
      warning(
        "the likelihood ratio test is computed from the model's likelihood ",
        "and takes no account of the robust standard errors, so it does not ",
        "match the intervals drawn beside it. The Wald test, `test = ",
        "\"wald\"`, is the one that does.",
        call. = FALSE
      )
    }
    reduced <- if (already) {
      fy_drop_interaction(fit, base_info, exposure, interaction)
    } else {
      fit
    }
    lrt <- if (chosen) {
      fy_lrt_test(info, reduced, columns)
    } else {
      try(fy_lrt_test(info, reduced, columns), silent = TRUE)
    }
    if (inherits(lrt, "try-error")) {
      message(
        "The likelihood ratio test could not be taken over this model, so the ",
        "joint Wald test is reported instead: ",
        # The reason ends by suggesting the Wald test, which is what has just
        # been done, so that sentence is left off.
        sub("\\s*[Uu]se `test = \"wald\"`\\.\\s*$", "",
            conditionMessage(attr(lrt, "condition")))
      )
      return(list(wald = out$wald %||% fy_joint_test(info, columns)))
    }
    out$lrt <- lrt
  }
  out
}

# Whether the fit already interacts the two variables.
fy_has_interaction <- function(info, exposure, interaction) {
  any(fy_interaction_terms(info, exposure, interaction))
}

fy_interaction_terms <- function(info, exposure, interaction) {
  vapply(info$term_vars, function(v) {
    all(c(exposure, interaction) %in% v)
  }, logical(1))
}

# The fit without its exposure by modifier terms, which is what the likelihood
# ratio test compares the interaction model against when the model handed to
# foresty already carried the interaction.
fy_drop_interaction <- function(fit, info, exposure, interaction) {
  terms <- names(info$term_vars)[fy_interaction_terms(info, exposure,
                                                      interaction)]
  dropped <- try(
    fy_refit(fit, info, stats::as.formula(
      paste("~ . -", paste(terms, collapse = " - "))
    )),
    silent = TRUE
  )
  if (inherits(dropped, "try-error")) {
    stop(
      "the model could not be refitted without the term",
      if (length(terms) > 1L) "s " else " ", paste(terms, collapse = " and "),
      ", so a likelihood ratio test of the interaction cannot be taken: ",
      conditionMessage(attr(dropped, "condition")),
      "\nUse `test = \"wald\"`, or fit the model without the interaction and ",
      "let foresty add it.",
      call. = FALSE
    )
  }
  dropped
}

# Adds the interaction unless the fit already carries it. update() handles glm,
# lm, survival and rms fits alike, and rms does not need datadist set for it.
fy_add_interaction <- function(fit, info, exposure, interaction,
                               already = fy_has_interaction(info, exposure,
                                                            interaction)) {
  if (already) {
    message(
      "The model already contains the ", exposure, " by ", interaction,
      " interaction; using it as it stands rather than updating it."
    )
    return(fit)
  }

  other <- setdiff(fy_interacting_vars(info, exposure), interaction)
  if (length(other)) {
    warning(
      "\"", exposure, "\" is also interacted with ",
      paste0("\"", other, "\"", collapse = " and "),
      " in this model. The subgroup estimates are reported at the first ",
      "complete observation's values of those variables.",
      call. = FALSE
    )
  }

  # The interaction is written with the model's own term labels rather than the
  # bare variable names, so that a variable entered as `rcs(no2, 4)` is
  # interacted as `rcs(no2, 4):sex`. Writing `no2:sex` would add a second,
  # linear copy of the exposure and the fit would fail or mean something else.
  new_term <- paste0(
    fy_main_term_label(info, exposure), ":",
    fy_main_term_label(info, interaction)
  )
  updated <- try(
    fy_refit(fit, info, stats::as.formula(paste("~ . +", new_term))),
    silent = TRUE
  )
  if (inherits(updated, "try-error")) {
    stop(
      "the model could not be updated to add the term ", new_term, ": ",
      conditionMessage(attr(updated, "condition")),
      "\nRefit the model with the interaction included and pass that fit instead.",
      call. = FALSE
    )
  }
  updated
}

# Refits the model with an extra term.
#
# stats::update() cannot be used directly, because it evaluates the call in its
# own caller, which here is inside this package. A model fitted with
# `data = d`, where `d` is a variable local to the user's function or to a
# loop, would then fail to find its own data. The call is instead evaluated
# where the model's formula came from, with the data bound under the name the
# call used, so a model fitted anywhere can be updated.
fy_refit <- function(fit, info, added) {
  call <- stats::update(fit, added, evaluate = FALSE)
  env <- environment(stats::formula(fit))
  if (is.null(env)) {
    env <- parent.frame()
  }
  if (!is.null(info$data) && !is.null(call$data) && is.name(call$data)) {
    env <- list2env(
      stats::setNames(list(info$data), as.character(call$data)),
      parent = env
    )
  }
  eval(call, envir = env)
}

# How a variable is written in this model's formula: "rcs(no2, 4)" rather than
# "no2" when it was entered as a spline. Falls back to the variable name when
# it has no main effect of its own.
fy_main_term_label <- function(info, variable) {
  main <- fy_exposure_terms(info, variable)$main
  if (length(main) == 1L) main[[1L]] else variable
}

# Coefficients belonging to terms that involve both the exposure and the
# modifier; these are the ones the joint test is taken over.
fy_modifier_interaction_columns <- function(info, exposure, interaction) {
  wanted <- vapply(info$term_vars, function(v) {
    all(c(exposure, interaction) %in% v)
  }, logical(1))
  fy_term_columns(info, names(info$term_vars)[wanted])
}
