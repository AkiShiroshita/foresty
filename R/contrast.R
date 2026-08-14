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
  where <- fy_reference_index(info)
  where$frame[where$index, , drop = FALSE]
}

# Which row that is, and which frame it came from, so that the code the app
# writes out can name the row foresty actually used rather than a row of its
# own choosing.
fy_reference_index <- function(info) {
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
  list(
    frame = frame,
    index = if (length(complete)) complete[1L] else 1L,
    from_data = !is.null(info$data)
  )
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

# The increment an effect is reported per, as a number.
#
# A number is taken as it stands. `"iqr"` is taken from the data: the
# interquartile range of the exposure as the model saw it, which is what a
# reader wants for an exposure whose units mean nothing on their own -- a
# pollutant, a biomarker, a score. The range it came to is carried back as a
# label, because an effect per interquartile range is not readable without the
# range: two cohorts have two of them, and a figure that does not say which was
# used cannot be compared with anything.
fy_resolve_contrast <- function(contrast, x, exposure) {
  if (is.numeric(contrast)) {
    checkmate::assert_number(contrast)
    return(contrast)
  }
  if (!is.character(contrast) || length(contrast) != 1L ||
      !identical(tolower(contrast), "iqr")) {
    stop(
      "`contrast` must be a number, as `contrast = 10`, or \"iqr\" for the ",
      "interquartile range of \"", exposure, "\" in the data the model was ",
      "fitted to",
      call. = FALSE
    )
  }
  if (!is.numeric(x)) {
    stop(
      "`contrast = \"iqr\"` is the interquartile range of \"", exposure,
      "\", which a categorical exposure does not have: its comparisons are ",
      "its levels. Use `at` to compare two of them.",
      call. = FALSE
    )
  }

  iqr <- stats::IQR(x, na.rm = TRUE)
  if (!is.finite(iqr) || iqr <= 0) {
    stop(
      "the interquartile range of \"", exposure, "\" is ", fy_trim_number(iqr),
      ", so there is no difference to report an effect per. Name the increment ",
      "yourself, as `contrast = 10`.",
      call. = FALSE
    )
  }
  # The range itself is used as it is; the label carries it to three figures,
  # which is how a paper writes it and is enough to know which range was meant.
  structure(iqr, label = paste0(
    "per IQR, ", format(iqr, digits = 3, trim = TRUE, drop0trailing = TRUE)
  ))
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
# value plus `contrast`. An increment that was asked for is written beside the
# exposure -- "NO2 (per 10)" -- because a figure whose numbers change with
# `contrast` and whose labels do not cannot be read. No unit is invented for
# it, since the package has no way of knowing what the numbers in a column
# mean; give one through `labels`.
#
# An increment is written wherever it was named, one included: `contrast = 1`
# draws "NO2 (per 1)", since a figure saying what its rows are per is read the
# same way whatever the number is. `NULL`, the default, is one unit and says
# nothing, which is what leaves a plain "NO2" on a figure nobody asked the
# question of.
#
# `contrast = "iqr"` is the increment taken from the data rather than named:
# an exposure whose units mean nothing to a reader -- a pollutant, a biomarker,
# a score -- is reported per interquartile range, and the range that was used
# is written beside the exposure so that the figure still says what a row is
# the effect of.
fy_exposure_values <- function(info, exposure, contrast = NULL, at = NULL) {
  # Whether the increment was named or left to the default, which is what
  # decides whether the figure says it. The number itself is one either way.
  named <- !is.null(contrast)
  if (!named) {
    contrast <- 1
  }
  x <- fy_variable(info, exposure)
  if (is.null(x)) {
    stop(
      "\"", exposure, "\" is not a variable in this model. Its terms are ",
      paste0("\"", names(info$term_map), "\"", collapse = ", "), ".",
      fy_transformed_hint(exposure),
      call. = FALSE
    )
  }
  # A basis built before the model was fitted and entered as columns of its own
  # is not a variable this package can contrast two values of. The columns
  # record nothing that ties them to the variable they were built from -- not
  # the knots, not the variable's name -- so there is no way to ask what the
  # design matrix looks like at two values of it. A basis built inside the
  # formula does record all of that, in the `predvars` of the terms object, and
  # is rebuilt from them with the knots it was fitted with.
  if (is.matrix(x) && ncol(x) > 1L) {
    stop(
      "\"", exposure, "\" is a matrix of ", ncol(x), " columns in the data ",
      "this model was fitted to -- a spline basis built before fitting, by ",
      "the look of it. Its columns record nothing that ties them to the ",
      "variable they were built from, so foresty cannot say what the design ",
      "matrix looks like at two values of that variable. Build the basis in ",
      "the formula instead, as `ns(x, 3)` or `rcs(x, 4)` with the same knots, ",
      "refit, and pass the variable itself as the exposure with ",
      "`at = c(from, to)`: the knots are then taken from the fitted terms ",
      "and the two values are contrasted on the curve the model actually has.",
      call. = FALSE
    )
  }
  contrast <- fy_resolve_contrast(contrast, x, exposure)
  named_contrast <- attr(contrast, "label")
  contrast <- as.numeric(contrast)

  if (!is.null(at)) {
    if (length(at) != 2L) {
      stop("`at` must give exactly two values of \"", exposure,
           "\": the baseline and the value compared with it", call. = FALSE)
    }
    # Both say which two values are being compared, and one of them would have
    # to be ignored.
    if (!isTRUE(all.equal(contrast, 1))) {
      said <- if (is.null(named_contrast)) {
        fy_trim_number(contrast)
      } else {
        "\"iqr\""
      }
      stop(
        "`at` and `contrast` both say which two values of \"", exposure,
        "\" are compared, so only one of them can be given: `at = c(",
        at[[1L]], ", ", at[[2L]], ")` names the values, `contrast = ", said,
        "` asks for the effect per ", fy_trim_number(contrast), " of them.",
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
  if (!is.null(named_contrast)) {
    return(list(list(
      from = base, to = base + contrast, level = NA_character_,
      contrast_label = named_contrast, reference = FALSE
    )))
  }
  list(list(
    from = base, to = base + contrast, level = NA_character_,
    contrast_label = if (!named) {
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
