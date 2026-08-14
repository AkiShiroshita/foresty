# One normalized description of a fitted model.
#
# Every place in the package that needs to know something about a fit goes
# through fy_model_info(). Model classes are special-cased here and nowhere
# else, so adding support for another class means adding a method here rather
# than editing the estimation or plotting code.

# Fixed-effect coefficients and their covariance, aligned to each other -------

# Returns a list of `coef` (named numeric) and `vcov` (matching square matrix).
# The two are intersected by name, because several classes report more rows in
# vcov() than in coef(): MASS::polr() keeps the cutpoints in vcov() only, and
# aliased coefficients are NA in coef() but absent from vcov().
fy_coefs <- function(fit, vcov_matrix = NULL) {
  UseMethod("fy_coefs")
}

#' @export
fy_coefs.default <- function(fit, vcov_matrix = NULL) {
  b <- stats::coef(fit)
  if (is.null(b) || !is.numeric(b)) {
    stop(
      "no usable coef() method for a fit of class ",
      paste(class(fit), collapse = "/"),
      call. = FALSE
    )
  }
  fy_align_coefs(b, vcov_matrix %||% stats::vcov(fit), fit)
}

#' @export
fy_coefs.merMod <- function(fit, vcov_matrix = NULL) {
  fy_align_coefs(lme4::fixef(fit), vcov_matrix %||% stats::vcov(fit), fit)
}

#' @export
fy_coefs.multinom <- function(fit, vcov_matrix = NULL) {
  b <- stats::coef(fit)
  if (is.matrix(b)) {
    b <- stats::setNames(
      as.vector(t(b)),
      paste(rep(rownames(b), each = ncol(b)), rep(colnames(b), nrow(b)), sep = ":")
    )
  }
  fy_align_coefs(b, vcov_matrix %||% stats::vcov(fit), fit)
}

fy_align_coefs <- function(b, v, fit) {
  if (is.null(names(b))) {
    stop(
      "the coefficients of a fit of class ",
      paste(class(fit), collapse = "/"), " are unnamed, so they cannot be ",
      "matched to their covariance matrix",
      call. = FALSE
    )
  }
  v <- as.matrix(v)

  # rms::psm() returns its covariance matrix without dimnames. When the matrix
  # is unnamed the coefficients are taken to be in the order they were reported
  # in, which is the convention every fitting function follows, and any extra
  # trailing parameters such as a log scale are dropped.
  if (is.null(colnames(v)) && nrow(v) >= length(b)) {
    v <- v[seq_along(b), seq_along(b), drop = FALSE]
    dimnames(v) <- list(names(b), names(b))
  }

  aliased <- is.na(b)
  keep <- intersect(names(b)[!aliased], colnames(v))
  if (!length(keep)) {
    stop(
      "the coefficient names and the covariance matrix of a fit of class ",
      paste(class(fit), collapse = "/"), " have nothing in common",
      call. = FALSE
    )
  }
  list(
    coef = b[keep],
    vcov = v[keep, keep, drop = FALSE],
    # Positions of the retained coefficients within the full coefficient
    # vector, so that a design matrix can be lined up with them by position.
    kept = match(keep, names(b)),
    n_full = length(b)
  )
}

# Robust and cluster-robust covariance ---------------------------------------

# Returns the covariance matrix to use, or NULL to keep the model's own.
#
# The sandwich estimators come from the sandwich package rather than being
# written here. Where sandwich does not apply, the fitting function's own
# mechanism is pointed at instead of returning a number that would look
# plausible and be wrong.
fy_robust_vcov <- function(fit, vcov = NULL, cluster = NULL, data = NULL) {
  if (is.null(vcov) && is.null(cluster)) {
    return(NULL)
  }
  if (is.matrix(vcov)) {
    return(vcov)
  }
  if (is.function(vcov)) {
    return(vcov(fit))
  }

  fy_check_sandwich_supported(fit, cluster)
  fy_require("sandwich", "compute robust standard errors")

  if (!is.null(cluster)) {
    cluster <- fy_cluster_vector(fit, cluster, data)
    type <- if (is.null(vcov)) "HC0" else fy_hc_type(vcov)
    return(sandwich::vcovCL(fit, cluster = cluster, type = type))
  }
  sandwich::vcovHC(fit, type = fy_hc_type(vcov))
}

fy_hc_type <- function(vcov) {
  checkmate::assert_string(vcov)
  if (identical(vcov, "robust")) {
    # HC1 is the small-sample correction that "robust" means in most other
    # software, so it is what an unqualified request gets here.
    return("HC1")
  }
  if (!grepl("^HC[0-4]?$", vcov)) {
    stop(
      "`vcov` must be \"robust\", one of \"HC0\" to \"HC4\", a function, or a ",
      "matrix, not \"", vcov, "\"",
      call. = FALSE
    )
  }
  vcov
}

# The classes sandwich cannot do this for, each with the thing to do instead.
fy_check_sandwich_supported <- function(fit, cluster) {
  if (inherits(fit, "rms")) {
    stop(
      "sandwich's estimators do not work on rms fits. Use rms's own instead: ",
      "`fit <- rms::robcov(fit", if (!is.null(cluster)) ", cluster = ...", ")`, ",
      "then pass that fit to foresty, whose standard errors are robust already.",
      call. = FALSE
    )
  }
  if (inherits(fit, c("coxph", "cph")) && is.null(cluster)) {
    stop(
      "a heteroskedasticity-consistent estimator is not the robust variance ",
      "for a Cox model. Refit with `coxph(..., robust = TRUE)`, or pass ",
      "`cluster` here for the grouped version; a fit that is already robust ",
      "is used as it stands.",
      call. = FALSE
    )
  }
  invisible(TRUE)
}

# Accepts a variable name, a one-sided formula, or the values themselves.
#
# `cluster` says which observations belong together, so it has to identify
# them. A bare TRUE is the commonest way of getting this wrong, and left to
# itself it reaches sandwich and comes back as a mismatch between the length
# of the cluster and the number of observations, which says nothing useful.
fy_cluster_vector <- function(fit, cluster, data) {
  if (inherits(cluster, "formula")) {
    return(cluster)
  }
  if (is.logical(cluster)) {
    stop(
      "`cluster` names the variable that identifies the clusters, not whether ",
      "to cluster. Pass a column name, a vector of identifiers, or a ",
      "one-sided formula: cluster = \"practice_id\", cluster = data$practice_id ",
      "or cluster = ~practice_id.",
      call. = FALSE
    )
  }
  if (is.character(cluster) && length(cluster) == 1L) {
    frame <- data %||% fy_model_frame(fit)
    if (is.null(frame[[cluster]])) {
      stop(
        "\"", cluster, "\" is not a column of the data this model was fitted ",
        "from, so it cannot identify the clusters",
        call. = FALSE
      )
    }
    return(frame[[cluster]])
  }

  used <- stats::nobs(fit)
  if (!is.null(used) && !is.na(used) && length(cluster) != used) {
    stop(
      "`cluster` has ", length(cluster), " value",
      if (length(cluster) == 1L) "" else "s", " but the model was fitted to ",
      used, " observations. Give one cluster identifier per observation, or ",
      "name a column of the data with cluster = \"variable_name\".",
      call. = FALSE
    )
  }
  cluster
}

# Model terms mapped to the coefficients they produced ------------------------

# Returns a named list: term label -> names of the coefficients it contributes.
# A term contributes more than one coefficient whenever it is a factor with
# more than two levels or a spline, so this cannot be done by name matching.
fy_term_map <- function(fit, coef_names) {
  # An S4 fit -- lme4's lmer() and glmer() among them -- cannot be subsetted at
  # all, so it is not asked for an `assign` element it could not carry; its
  # terms are read off the design matrix below like any other fit's.
  assign <- if (isS4(fit)) NULL else fit[["assign"]]

  # survival and rms fits carry `assign` as a named list of coefficient
  # positions, which already groups rcs(x, 4) into its three columns.
  if (is.list(assign) && !is.null(names(assign)) && length(assign)) {
    full <- names(stats::coef(fit))
    out <- lapply(assign, function(idx) intersect(full[idx], coef_names))
    return(out[lengths(out) > 0])
  }

  # lm and glm need the design matrix, whose `assign` attribute indexes into
  # the term labels, with 0 standing for the intercept.
  mm <- try(stats::model.matrix(fit), silent = TRUE)
  if (inherits(mm, "try-error")) {
    return(list())
  }
  positions <- attr(mm, "assign")
  labels <- attr(stats::terms(fit), "term.labels")
  if (is.null(positions) || is.null(labels)) {
    return(list())
  }
  out <- lapply(seq_along(labels), function(j) {
    intersect(colnames(mm)[positions == j], coef_names)
  })
  names(out) <- labels
  out[lengths(out) > 0]
}

# The variables behind each term label, and how many variables the term is of.
#
# A term label is one or more variable expressions joined by colons, so it is
# split on the colons at the top of the parsed expression rather than on the
# character: `no2:sex` is a term of two variables, and `splines::ns(no2, 3)`,
# which carries two colons and no interaction, is a term of one.
#
# The variables of an expression cannot simply be all.vars() of it, because an
# argument naming an object is not a variable of the model: the knots in
# `rcs(no2, knots)` or `ns(no2, knots = k)` are a vector that happens to be
# named there, and reading them as variables makes the term look like an
# interaction between the exposure and its own knots. So the symbols are
# matched against the columns the model was fitted from, and where that cannot
# settle it the term is taken to be a term in its first argument, which is the
# convention every basis function in R follows.
fy_term_structure <- function(labels, known = NULL) {
  parts <- lapply(labels, fy_term_parts)
  list(
    vars = stats::setNames(
      lapply(parts, function(p) {
        unique(unlist(lapply(p, fy_part_vars, known = known),
                      use.names = FALSE))
      }),
      labels
    ),
    order = stats::setNames(
      vapply(parts, function(p) max(1L, length(p)), integer(1)),
      labels
    )
  )
}

# The variable expressions a term label is built from.
fy_term_parts <- function(label) {
  expr <- try(str2lang(label), silent = TRUE)
  if (inherits(expr, "try-error")) {
    return(list())
  }
  split <- function(e) {
    if (is.call(e) && length(e) == 3L && identical(e[[1L]], as.name(":"))) {
      return(c(split(e[[2L]]), split(e[[3L]])))
    }
    list(e)
  }
  split(expr)
}

fy_part_vars <- function(part, known = NULL) {
  vars <- all.vars(part)
  if (length(vars) < 2L) {
    return(vars)
  }
  hit <- intersect(vars, known)
  if (length(hit)) {
    return(hit)
  }
  if (is.call(part) && length(part) >= 2L) {
    return(all.vars(part[[2L]]))
  }
  vars
}

# Effect measure --------------------------------------------------------------

fy_measure <- function(fit, outcome = fy_outcome_label(fit)) {
  fam <- try(stats::family(fit), silent = TRUE)
  fam_name <- if (inherits(fam, "try-error") || is.null(fam)) NA_character_ else fam$family
  link <- if (inherits(fam, "try-error") || is.null(fam)) NA_character_ else fam$link

  if (inherits(fit, c("coxph", "cph"))) {
    return(fy_measure_spec("HR", outcome))
  }
  if (inherits(fit, "lrm") || inherits(fit, "polr")) {
    return(fy_measure_spec("OR", outcome))
  }
  if (!is.na(fam_name)) {
    if (fam_name == "binomial" && identical(link, "logit")) {
      return(fy_measure_spec("OR", outcome))
    }
    if (fam_name %in% c("poisson", "quasipoisson") && identical(link, "log")) {
      # A Poisson model carrying person-time is a rate model, and its ratio is
      # a rate ratio rather than a risk ratio.
      measure <- if (fy_has_offset(fit)) "IRR" else "RR"
      return(fy_measure_spec(measure, outcome))
    }
    if (fam_name %in% c("binomial", "quasibinomial") && identical(link, "log")) {
      return(fy_measure_spec("RR", outcome))
    }
    if (fam_name == "gaussian" && identical(link, "identity")) {
      return(fy_measure_spec("MD", outcome))
    }
  }
  if (inherits(fit, "ols") || (inherits(fit, "lm") && !inherits(fit, "glm"))) {
    return(fy_measure_spec("MD", outcome))
  }
  fy_measure_spec("Coefficient", outcome)
}

# The outcome a measure is a measure of, taken from the left of the formula, so
# that an axis reads "Adjusted odds ratio for asthma" rather than leaving the
# reader to remember which model produced it.
fy_outcome_label <- function(fit) {
  formula <- try(stats::formula(fit), silent = TRUE)
  if (inherits(formula, "try-error") || length(formula) < 3L) {
    return(NA_character_)
  }
  lhs <- formula[[2L]]
  if (is.name(lhs)) {
    return(deparse(lhs))
  }
  variables <- all.vars(lhs)
  if (!length(variables)) {
    return(NA_character_)
  }
  # A survival outcome is written Surv(time, status); the event is what the
  # hazard ratio is about, and it is named last. Anything else built from a
  # call, cbind(events, non_events) for instance, leads with its outcome.
  if (is.call(lhs) && identical(fy_call_name(lhs), "Surv")) {
    return(variables[length(variables)])
  }
  variables[1L]
}

# The function a call names, with any namespace stripped, so that Surv() and
# survival::Surv() are recognised as the same thing.
fy_call_name <- function(x) {
  sub("^.*::", "", paste(deparse(x[[1L]]), collapse = ""))
}

fy_measure_spec <- function(measure, outcome = NA_character_) {
  spec <- switch(
    measure,
    OR = list(label = "Odds ratio", exponentiate = TRUE),
    RR = list(label = "Risk ratio", exponentiate = TRUE),
    HR = list(label = "Hazard ratio", exponentiate = TRUE),
    IRR = list(label = "Incidence rate ratio", exponentiate = TRUE),
    MD = list(label = "Mean difference", exponentiate = FALSE),
    Coefficient = list(label = "Coefficient", exponentiate = FALSE),
    stop(
      "`measure` must be one of \"OR\", \"RR\", \"HR\", \"IRR\", \"MD\" or ",
      "\"Coefficient\", not \"", measure, "\"",
      call. = FALSE
    )
  )
  # `name` is the measure on its own, for the places that build a phrase out of
  # it; `label` names the outcome too, for the places that stand alone.
  spec$name <- spec$label
  spec$label <- fy_measure_label(spec$name, outcome)
  # Whether the measure is a ratio, which stays true however it is drawn. The
  # display scale can be turned off by `exponentiate = FALSE`, but a ratio is
  # still a ratio for the purpose of choosing between a z and a t.
  spec$ratio <- spec$exponentiate
  c(list(measure = measure, outcome = outcome), spec)
}

fy_measure_label <- function(name, outcome) {
  if (is.na(outcome) || !nzchar(outcome)) {
    return(name)
  }
  paste0(name, " for ", outcome)
}

# The same measure left on the scale the model was fitted on: a log odds ratio
# rather than an odds ratio, drawn about zero rather than about one.
#
# `TRUE`, which is the default, is what the measure asks for: a ratio is drawn
# as a ratio. Only a ratio has anything to leave, so it says nothing about a
# mean difference or a coefficient, which are on that scale already and are not
# exponentiated on request -- exp(a mean difference) is not a measure of
# anything.
fy_apply_exponentiate <- function(spec, exponentiate) {
  if (is.null(exponentiate) || isTRUE(exponentiate)) {
    return(spec)
  }
  checkmate::assert_flag(exponentiate)
  if (!isTRUE(spec$ratio)) {
    return(spec)
  }
  spec$exponentiate <- FALSE
  spec$name <- paste0("Log ", tolower(substring(spec$name, 1, 1)),
                      substring(spec$name, 2))
  spec$label <- fy_measure_label(spec$name, spec$outcome)
  spec
}

# Model frame, counts and residual degrees of freedom -------------------------

fy_model_frame <- function(fit) {
  mf <- try(stats::model.frame(fit), silent = TRUE)
  if (inherits(mf, "try-error")) {
    stop(
      "the model frame of this fit could not be recovered, so subgroup sizes ",
      "and contrasts cannot be built; refit with the data still in scope",
      call. = FALSE
    )
  }
  mf
}

# The data frame the model was fitted from, or NULL if it cannot be found.
#
# The model frame is not a substitute for it. A model frame holds terms as they
# were evaluated, so `rcs(maternal_age, 4)` is stored as its three-column basis
# under that name, and the original `maternal_age` is not in there at all. That
# is fine for base R fits, whose design matrix is rebuilt from the same
# evaluated columns, but rms fits are asked for their design through
# predict(), which needs the untransformed variables back.
fy_source_data <- function(fit) {
  call <- stats::getCall(fit)
  if (is.null(call) || is.null(call$data)) {
    return(NULL)
  }
  env <- environment(stats::formula(fit))
  if (is.null(env)) {
    env <- parent.frame()
  }
  data <- try(eval(call$data, envir = env), silent = TRUE)
  if (inherits(data, "try-error") || !is.data.frame(data)) {
    return(NULL)
  }
  data
}

# Number of events behind a fit, or NA when the outcome is not an event.
# model.response() gives a Surv matrix for survival fits, a factor for a
# logistic regression on a factor, and a 0/1 numeric otherwise.
fy_events <- function(mf, rows = NULL) {
  y <- try(stats::model.response(mf), silent = TRUE)
  if (inherits(y, "try-error") || is.null(y)) {
    return(NA_integer_)
  }
  if (!is.null(rows)) {
    y <- if (is.matrix(y)) y[rows, , drop = FALSE] else y[rows]
  }
  if (inherits(y, "Surv")) {
    status <- y[, ncol(y)]
    return(as.integer(sum(status == max(status), na.rm = TRUE)))
  }
  if (is.matrix(y)) {
    # A two-column binomial response: successes and failures.
    return(as.integer(sum(y[, 1], na.rm = TRUE)))
  }
  if (is.factor(y)) {
    if (nlevels(y) != 2L) return(NA_integer_)
    return(as.integer(sum(y == levels(y)[2L], na.rm = TRUE)))
  }
  if (is.logical(y)) {
    return(as.integer(sum(y, na.rm = TRUE)))
  }
  if (is.numeric(y) && all(y %in% c(0, 1, NA))) {
    return(as.integer(sum(y == 1, na.rm = TRUE)))
  }
  NA_integer_
}

# Person-time behind a fit, or NA when the model carries no time.
#
# A rate is only interpretable against the time it was accumulated over, so a
# model that has that time reports it. It comes from the survival outcome for
# a Cox model, and from the offset for a Poisson rate model, where the offset
# is the log of the time.
fy_person_time <- function(mf, rows = NULL) {
  y <- try(stats::model.response(mf), silent = TRUE)
  if (!inherits(y, "try-error") && inherits(y, "Surv")) {
    time <- if (identical(attr(y, "type"), "counting")) {
      y[, "stop"] - y[, "start"]
    } else if ("time" %in% colnames(y)) {
      y[, "time"]
    } else {
      NULL
    }
    if (!is.null(time)) {
      if (!is.null(rows)) time <- time[rows]
      return(sum(time, na.rm = TRUE))
    }
  }

  offset <- try(stats::model.offset(mf), silent = TRUE)
  if (!inherits(offset, "try-error") && !is.null(offset)) {
    if (!is.null(rows)) offset <- offset[rows]
    return(sum(exp(offset), na.rm = TRUE))
  }
  NA_real_
}

fy_has_offset <- function(fit) {
  mf <- try(stats::model.frame(fit), silent = TRUE)
  if (inherits(mf, "try-error")) {
    return(FALSE)
  }
  !is.null(stats::model.offset(mf))
}

# Gaussian models are reported with t and F, everything else with the normal
# approximation and a Wald chi-square, so the two need different error degrees
# of freedom when the linear combination is tested.
fy_error_df <- function(fit, ratio) {
  if (ratio) {
    return(Inf)
  }
  df <- try(stats::df.residual(fit), silent = TRUE)
  if (inherits(df, "try-error") || is.null(df) || is.na(df) || df <= 0) {
    return(Inf)
  }
  as.numeric(df)
}

# Assembly --------------------------------------------------------------------

fy_model_info <- function(fit, measure = NULL, exponentiate = NULL, vcov = NULL,
                          cluster = NULL) {
  data <- fy_source_data(fit)
  robust <- fy_robust_vcov(fit, vcov = vcov, cluster = cluster, data = data)
  cv <- fy_coefs(fit, vcov_matrix = robust)
  outcome <- fy_outcome_label(fit)
  spec <- if (is.null(measure)) {
    fy_measure(fit, outcome)
  } else {
    fy_measure_spec(measure, outcome)
  }
  spec <- fy_apply_exponentiate(spec, exponentiate)
  term_map <- fy_term_map(fit, names(cv$coef))
  mf <- fy_model_frame(fit)
  # The names a symbol in a term has to be one of to be a variable of the
  # model rather than something named in the call, such as a knot vector.
  terms <- fy_term_structure(names(term_map),
                             known = unique(c(names(data), names(mf))))

  structure(
    list(
      fit = fit,
      coef = cv$coef,
      vcov = cv$vcov,
      kept = cv$kept,
      n_full = cv$n_full,
      robust = !is.null(robust) || fy_fit_is_robust(fit),
      term_map = term_map,
      term_vars = terms$vars,
      # How many variables each term is of, which is what tells an interaction
      # from a basis expanded over several coefficients.
      term_order = terms$order,
      mf = mf,
      data = data,
      n = nrow(mf),
      events = fy_events(mf),
      person_time = fy_person_time(mf),
      measure = spec$measure,
      measure_label = spec$label,
      measure_name = spec$name,
      outcome = spec$outcome,
      exponentiate = spec$exponentiate,
      # Which distribution the estimates are referred to follows from the model,
      # not from the scale it is drawn on, so a logistic regression reported as
      # a log odds ratio is still a z rather than a t.
      error_df = fy_error_df(fit, spec$ratio),
      has_intercept = fy_has_intercept(cv$coef)
    ),
    class = "foresty_model_info"
  )
}

# Whether the fit's own vcov() is already a robust one, so that a model fitted
# with coxph(robust = TRUE) or passed through rms::robcov() is reported as
# robust even though foresty did nothing to it.
fy_fit_is_robust <- function(fit) {
  if (inherits(fit, c("coxph", "cph")) && !is.null(fit[["naive.var"]])) {
    return(TRUE)
  }
  if (inherits(fit, "rms") && !is.null(fit[["orig.var"]])) {
    return(TRUE)
  }
  # A GEE is fitted to give the sandwich estimator in the first place.
  inherits(fit, c("geeglm", "gee"))
}

# Pieces of a fit that most fitting functions store in the object itself.
#
# An S4 fit cannot be subsetted at all -- `fit[["xlevels"]]` on an lme4 fit is
# an error rather than a NULL -- so it is never asked, and what it does not
# carry is recovered from its model frame and design matrix instead. That is
# where a base R fit's own copies came from in the first place, so the two
# agree.
fy_fit_element <- function(fit, name) {
  if (isS4(fit)) NULL else fit[[name]]
}

# The levels every factor was fitted with, so that a contrast built from two
# rows of data keeps the whole factor and the design matrix keeps its shape.
fy_xlevels <- function(fit) {
  out <- fy_fit_element(fit, "xlevels")
  if (!is.null(out)) {
    return(out)
  }
  mf <- try(stats::model.frame(fit), silent = TRUE)
  if (inherits(mf, "try-error")) {
    return(NULL)
  }
  factors <- vapply(mf, is.factor, logical(1))
  # Only the variables the fixed effects are built from. A model frame carries
  # more than they do -- the grouping factor of a mixed model among them -- and
  # naming a variable the design does not use makes model.frame() complain that
  # it cannot find it.
  terms <- try(stats::terms(fit), silent = TRUE)
  if (!inherits(terms, "try-error")) {
    factors <- factors & names(mf) %in% all.vars(terms)
  }
  lapply(mf[factors], levels)
}

# The contrast coding each factor was fitted under.
fy_contrasts <- function(fit) {
  out <- fy_fit_element(fit, "contrasts")
  if (!is.null(out)) {
    return(out)
  }
  mm <- try(stats::model.matrix(fit), silent = TRUE)
  if (inherits(mm, "try-error")) {
    return(NULL)
  }
  attr(mm, "contrasts")
}

fy_has_intercept <- function(b) {
  length(b) > 0 && names(b)[1] %in% c("(Intercept)", "Intercept")
}

# Counts behind one set of rows of the model frame.
fy_counts <- function(info, rows = NULL) {
  list(
    n = if (is.null(rows)) info$n else length(rows),
    events = fy_events(info$mf, rows = rows),
    person_time = fy_person_time(info$mf, rows = rows)
  )
}

`%||%` <- function(x, y) if (is.null(x)) y else x
