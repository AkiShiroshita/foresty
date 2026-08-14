# Building the contrast vector for an exposure effect.
#
# The contrast is not assembled by picking coefficients out by name. It is the
# difference between two rows of the model's own design matrix, one with the
# exposure at its baseline and one with the exposure at the value being
# compared, everything else held equal. Every column that does not involve the
# exposure cancels, so the difference is exactly the exposure effect, and the
# result is correct whatever contrast coding, spline basis or naming convention
# the fitting function used. This is what allows an rms fit, whose coefficients
# are named `x * g=Male`, to be handled by the same code as a glm.

# Terms involving the exposure, split into its own effect and its interactions.
fy_exposure_terms <- function(info, exposure) {
  vars <- info$term_vars
  # How many variables the term is of, not how many coefficients it produced:
  # a spline is one variable spread over several columns, and an interaction is
  # several variables whether or not either of them is splined.
  order <- info$term_order %||% lengths(vars)
  is_exposure <- vapply(vars, function(v) exposure %in% v, logical(1))
  list(
    main = names(vars)[is_exposure & order == 1L],
    interaction = names(vars)[is_exposure & order > 1L]
  )
}

# The coefficients produced by a set of term labels.
fy_term_columns <- function(info, labels) {
  unique(unlist(info$term_map[labels], use.names = FALSE))
}

# The variables an exposure is interacted with in this model.
fy_interacting_vars <- function(info, exposure) {
  terms <- fy_exposure_terms(info, exposure)
  setdiff(unique(unlist(info$term_vars[terms$interaction], use.names = FALSE)), exposure)
}

# The design matrix rows for `newdata`, aligned to info$coef by position.
#
# rms fits have to be asked through predict(type = "x"), which returns the
# design matrix without its intercept column; base R fits are rebuilt from the
# terms object. Either way the result is matched to the coefficient vector by
# position after the intercept column is reconciled, because the column names
# agree with the coefficient names for base R fits but not for rms fits.
fy_design_matrix <- function(info, newdata) {
  fit <- info$fit
  if (inherits(fit, "rms")) {
    mm <- stats::predict(fit, newdata = newdata, type = "x")
    mm <- as.matrix(mm)
  } else {
    tt <- stats::delete.response(stats::terms(fit))
    # The terms object carries `predvars`, which records the knots and centring
    # chosen when the model was fitted. Going back through model.frame() makes
    # model.matrix() use them, so a basis such as ns(no2, 3) is reproduced as
    # it was fitted rather than recomputed from these two rows.
    frame <- stats::model.frame(tt, data = newdata, xlev = fy_xlevels(fit),
                                na.action = stats::na.pass)
    mm <- stats::model.matrix(tt, data = frame,
                              contrasts.arg = fy_contrasts(fit))
  }

  if (ncol(mm) == info$n_full + 1L && fy_is_intercept_column(colnames(mm)[1L])) {
    # The fit carries no intercept, as survival fits do not.
    mm <- mm[, -1L, drop = FALSE]
  } else if (ncol(mm) == info$n_full - 1L && info$has_intercept) {
    # rms omits the intercept from its design matrix but keeps it in coef().
    mm <- cbind(0, mm)
  }

  if (ncol(mm) != info$n_full) {
    stop(
      "the design matrix of this fit has ", ncol(mm), " columns but the model ",
      "has ", info$n_full, " coefficients, so an exposure contrast cannot be ",
      "built for a fit of class ", paste(class(fit), collapse = "/"),
      call. = FALSE
    )
  }

  # Drop the same positions that were dropped from the coefficient vector,
  # so aliased coefficients do not shift the alignment.
  mm[, info$kept, drop = FALSE]
}

fy_is_intercept_column <- function(x) {
  isTRUE(x %in% c("(Intercept)", "Intercept"))
}

# A reference row holding every covariate at a fixed value. The value itself is
# irrelevant, because the covariate columns cancel in the difference, but it
# has to be one the design can be evaluated at, so an observed row is reused.
#
# The source data is preferred over the model frame, because a model frame
# holds terms as they were evaluated: a variable entered as ns(no2, 3) or
# rcs(no2, 4) is stored there as its basis matrix, and setting `no2` on such a
# row would change nothing. The model frame is used only when the source data
# cannot be found, which is workable as long as every term is a plain variable.
fy_reference_row <- function(info) {
  frame <- if (!is.null(info$data)) info$data else info$mf
  if (is.null(frame)) {
    stop(
      "the data this model was fitted from could not be found, so a contrast ",
      "cannot be built. Keep the data frame in scope under the name used in ",
      "the call, or refit with the data still available.",
      call. = FALSE
    )
  }
  # Completeness is judged on the variables the model uses, so that an unrelated
  # column full of missing values does not rule every row out.
  used <- intersect(all.vars(stats::formula(info$fit)), names(frame))
  complete <- which(stats::complete.cases(frame[, used, drop = FALSE]))
  index <- if (length(complete)) complete[1L] else 1L
  frame[index, , drop = FALSE]
}

# The values a model variable takes. The model frame is asked first, so that
# the values seen are the ones actually analysed, but a variable transformed on
# its way into the model is stored there as its basis matrix and is only
# recoverable from the source data.
fy_variable <- function(info, name) {
  from_frame <- info$mf[[name]]
  if (!is.null(from_frame) && !inherits(from_frame, "rms") && !is.matrix(from_frame)) {
    return(from_frame)
  }
  if (!is.null(info$data)) {
    return(info$data[[name]])
  }
  from_frame
}

fy_is_categorical <- function(x) {
  is.factor(x) || is.character(x) || is.logical(x)
}

# The comparisons to make for an exposure.
#
# A categorical exposure yields one comparison per level, the reference level
# included: it carries no estimate of its own but is shown, because a row
# labelled only "Urban" cannot be read without seeing what it is being
# compared with. `contrast` says nothing about such an exposure, whose
# comparisons are its levels, and `at` names two of those levels.
#
# A continuous exposure yields a single comparison, of a value against that
# value plus `contrast`. An increment that is not one is written beside the
# exposure -- "NO2 (per 10)" -- because a figure whose numbers change with
# `contrast` and whose labels do not cannot be read. No unit is invented for
# it, since the package has no way of knowing what the numbers in a column
# mean; give one through `labels`.
fy_exposure_values <- function(info, exposure, contrast = 1, at = NULL) {
  x <- fy_variable(info, exposure)
  if (is.null(x)) {
    stop(
      "\"", exposure, "\" is not a variable in this model. Its terms are ",
      paste0("\"", names(info$term_map), "\"", collapse = ", "), ".",
      fy_transformed_hint(exposure),
      call. = FALSE
    )
  }
  checkmate::assert_number(contrast)

  if (!is.null(at)) {
    if (length(at) != 2L) {
      stop("`at` must give exactly two values of \"", exposure,
           "\": the baseline and the value compared with it", call. = FALSE)
    }
    # Both say which two values are being compared, and one of them would have
    # to be ignored.
    if (!isTRUE(all.equal(contrast, 1))) {
      stop(
        "`at` and `contrast` both say which two values of \"", exposure,
        "\" are compared, so only one of them can be given: `at = c(",
        at[[1L]], ", ", at[[2L]], ")` names the values, `contrast = ", contrast,
        "` asks for the effect per ", contrast, " of them.",
        call. = FALSE
      )
    }
    # Which two values were compared is a fact about the whole figure rather
    # than about one row of it -- every row is that same comparison, taken
    # within another subgroup -- so it is written beside the exposure wherever
    # the exposure is named, and not as a level of it.
    return(structure(
      list(list(
        from = at[[1L]], to = at[[2L]],
        level = NA_character_,
        contrast_label = paste0(at[[2L]], " vs ", at[[1L]]),
        reference = FALSE
      )),
      explicit = TRUE
    ))
  }

  if (fy_is_categorical(x)) {
    if (!isTRUE(all.equal(contrast, 1))) {
      warning(
        "\"", exposure, "\" is categorical, so `contrast` says nothing about ",
        "it: its comparisons are its levels. Use `at` to compare two of them.",
        call. = FALSE
      )
    }
    x <- as.factor(x)
    levs <- levels(droplevels(x))
    if (length(levs) < 2L) {
      stop("\"", exposure, "\" has only one level in the fitted data",
           call. = FALSE)
    }
    return(lapply(seq_along(levs), function(i) {
      list(
        from = factor(levs[1L], levels = levels(x)),
        to = factor(levs[i], levels = levels(x)),
        level = levs[i],
        contrast_label = NA_character_,
        reference = i == 1L
      )
    }))
  }

  if (!is.numeric(x)) {
    stop("\"", exposure, "\" is neither numeric nor categorical, so its effect ",
         "is not defined; use `at` to name the two values to contrast",
         call. = FALSE)
  }

  base <- stats::median(x, na.rm = TRUE)
  list(list(
    from = base, to = base + contrast, level = NA_character_,
    contrast_label = if (isTRUE(all.equal(contrast, 1))) {
      NA_character_
    } else {
      paste0("per ", fy_trim_number(contrast))
    },
    reference = FALSE
  ))
}

# Builds the contrast matrix for one exposure, optionally within one level of
# an effect modifier. One row per non-reference comparison.
fy_contrast_matrix <- function(info, exposure, values, modifier = NULL,
                               modifier_level = NULL) {
  reference <- fy_reference_row(info)

  # A splined exposure has no single effect to report, because the difference
  # depends on where along the spline it is taken, so the two values have to be
  # named rather than guessed at.
  if (fy_is_splined(info, exposure) && is.null(attr(values, "explicit"))) {
    stop(
      "\"", exposure, "\" is continuous and enters this model through more ",
      "than one coefficient, a spline for instance, so its effect is not a ",
      "single number. Pass `at = c(from, to)` to name the two values to ",
      "contrast, for example `at = c(10, 20)`.",
      call. = FALSE
    )
  }

  wanted <- values[!vapply(values, function(v) isTRUE(v$reference), logical(1))]
  if (!length(wanted)) {
    return(NULL)
  }

  rows <- lapply(wanted, function(v) {
    baseline <- reference
    compared <- reference
    baseline[[exposure]] <- fy_coerce_like(v$from, fy_variable(info, exposure))
    compared[[exposure]] <- fy_coerce_like(v$to, fy_variable(info, exposure))
    if (!is.null(modifier)) {
      lvl <- fy_coerce_like(modifier_level, fy_variable(info, modifier))
      baseline[[modifier]] <- lvl
      compared[[modifier]] <- lvl
    }
    nd <- rbind(baseline, compared)
    mm <- fy_design_matrix(info, nd)
    mm[2L, ] - mm[1L, ]
  })

  L <- do.call(rbind, rows)
  rownames(L) <- vapply(wanted, function(v) {
    if (is.na(v$level)) exposure else as.character(v$level)
  }, character(1))
  colnames(L) <- names(info$coef)
  L
}

# Keeps a replacement value the same type as the column it replaces, so that a
# factor keeps every one of its levels and the design matrix keeps its shape.
fy_coerce_like <- function(value, template) {
  if (is.factor(template)) {
    return(factor(as.character(value), levels = levels(template)))
  }
  if (is.logical(template)) {
    return(as.logical(value))
  }
  if (is.numeric(template)) {
    return(as.numeric(value))
  }
  value
}

# A factor exposure also produces more than one coefficient, but each of those
# is a comparison with the reference level and is reported on its own row. Only
# a numeric exposure spread over several columns, as a spline is, has no single
# effect to report.
fy_is_splined <- function(info, exposure) {
  x <- fy_variable(info, exposure)
  if (fy_is_categorical(x)) {
    return(FALSE)
  }
  terms <- fy_exposure_terms(info, exposure)
  length(fy_term_columns(info, terms$main)) > 1L
}

# The rows of the model frame an estimate was taken over, so that the counts
# beside it describe the same people. A categorical exposure is counted level
# by level; a continuous one over everybody in the subgroup.
fy_estimate_rows <- function(info, exposure, value, modifier = NULL,
                             modifier_level = NULL) {
  keep <- rep(TRUE, info$n)
  x <- info$mf[[exposure]]
  # The level counted is the one the comparison is of, which is the value the
  # contrast was taken to -- named by `at` where it was given, and the level of
  # the row otherwise.
  if (!is.null(x) && fy_is_categorical(x)) {
    keep <- keep & !is.na(x) & as.character(x) == as.character(value$to)
  }
  if (!is.null(modifier)) {
    m <- info$mf[[modifier]]
    keep <- keep & !is.na(m) & as.character(m) == modifier_level
  }
  which(keep)
}
