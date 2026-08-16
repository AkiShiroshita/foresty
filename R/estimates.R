# Assembling the rows that a forest plot is drawn from.
#
# Shared by foresty_main() and foresty_interaction() so that a row means the
# same thing in both, and so that the reference level of a categorical exposure
# is handled once.

fy_exposure_estimates <- function(info, exposure, values, ci_level = 0.95,
                                  modifier = NULL, modifier_level = NULL,
                                  reference_cell = NULL) {
  L <- fy_contrast_matrix(info, exposure, values, modifier = modifier,
                          modifier_level = modifier_level,
                          reference_cell = reference_cell)
  estimated <- if (is.null(L)) NULL else fy_lincom(info, L, ci_level = ci_level)

  null_value <- if (info$exponentiate) 1 else 0
  position <- 0L

  rows <- lapply(values, function(v) {
    counts <- fy_counts(info, fy_estimate_rows(
      info, exposure, v, modifier = modifier, modifier_level = modifier_level
    ))

    if (isTRUE(v$reference)) {
      # The reference level of a categorical exposure is drawn so that the
      # other levels can be read, but it is a definition rather than an
      # estimate and carries no interval.
      out <- data.frame(
        estimate = null_value, se = NA_real_,
        conf.low = NA_real_, conf.high = NA_real_,
        statistic = NA_real_, p.value = NA_real_,
        stringsAsFactors = FALSE
      )
    } else {
      position <<- position + 1L
      out <- estimated[position, c("estimate", "se", "conf.low", "conf.high",
                                   "statistic", "p.value"), drop = FALSE]
    }

    data.frame(
      variable = exposure,
      level = v$level,
      # What the comparison was, where it is not the plain one unit: "per 10",
      # or "10 -> 20" from `at`. Carried on the estimates so that the figure
      # can say it and so that it survives into tidy().
      contrast_label = v$contrast_label %||% NA_character_,
      reference = isTRUE(v$reference),
      out,
      n = counts$n,
      events = counts$events,
      person_time = counts$person_time,
      stringsAsFactors = FALSE
    )
  })

  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

# The label each row is drawn against.
#
# A categorical exposure is labelled by its level alone, with the variable it
# belongs to shown once at the left of the figure rather than repeated on every
# row. A continuous exposure has no level, so it takes the variable's label.
#
# A comparison that is not the plain one unit says so beside the variable --
# "NO2 (per 10)", "NO2 (20 -> 10)" -- and says it wherever the variable is
# named, the title included, since the estimate means nothing without it. It
# belongs to the exposure rather than to the row because every row of the
# figure is that same comparison, taken within another subgroup. It is written
# whatever the variable is called, a label being where the unit goes rather
# than where the comparison does.
fy_row_labels <- function(estimates, labels = NULL) {
  variable_label <- fy_apply_labels(estimates$variable, labels)
  said <- as.character(estimates$contrast_label %||%
                         rep(NA_character_, nrow(estimates)))
  says <- !is.na(said)
  variable_label[says] <- paste0(variable_label[says], " (", said[says], ")")
  row_label <- ifelse(is.na(estimates$level), variable_label, estimates$level)
  list(variable_label = variable_label, row_label = row_label)
}

# The exposure as a figure of it names it: the variable, and the comparison
# where that is not the plain one unit -- "no2 (per 10)", "no2 (per IQR, 8.44)",
# "no2 (10 -> 20)".
#
# It is the label the rows are drawn against, taken before anything is drawn,
# so that a caller wanting to say which exposure a figure is of says it the
# same way the figure does rather than writing its own version.
fy_exposure_display <- function(info, exposure, contrast = NULL, at = NULL,
                                labels = NULL) {
  values <- fy_exposure_values(info, exposure, contrast = contrast, at = at)
  estimates <- data.frame(
    variable = exposure,
    level = NA_character_,
    contrast_label = values[[1L]]$contrast_label %||% NA_character_,
    stringsAsFactors = FALSE
  )
  fy_row_labels(estimates, labels)$variable_label[[1L]]
}

# The one combination every row of the figure is compared with, said in the two
# variables it is a combination of, so that it can be read without the figure
# beside it: "urbanicity = Rural and sex = Female".
fy_reference_phrase <- function(result) {
  cell <- result$reference_cell
  if (is.null(cell)) {
    return(NULL)
  }
  paste0(result$exposure, " = ", cell$exposure_level, " and ",
         result$modifier, " = ", cell$modifier_level)
}

# 10 rather than 10.0, 0.5 rather than 0.500.
fy_trim_number <- function(x) {
  format(x, trim = TRUE, drop0trailing = TRUE)
}

# A label written where the variable is named: `interaction = c(Sex = "sex")`
# says both which variable is meant and what to call it, which saves naming it
# twice. The name written beside the variable is the more specific of the two,
# so it wins over one given in `labels`.
fy_absorb_labels <- function(x, labels) {
  named <- names(x)
  if (is.null(named) || !any(nzchar(named))) {
    return(labels)
  }
  given <- nzchar(named)
  here <- stats::setNames(named[given], as.character(x)[given])
  if (is.null(labels)) {
    return(here)
  }
  checkmate::assert_character(labels, names = "named")
  c(labels[setdiff(names(labels), names(here))], here)
}

fy_apply_labels <- function(x, labels) {
  out <- as.character(x)
  if (is.null(labels)) {
    return(out)
  }
  checkmate::assert_character(labels, names = "named")
  hit <- match(out, names(labels))
  out[!is.na(hit)] <- unname(labels[hit[!is.na(hit)]])
  out
}

# Whether anything beyond the exposure and the modifier is in the model, which
# is what makes an estimate an adjusted one.
fy_is_adjusted <- function(info, exposure, modifier = NULL) {
  variables <- unique(unlist(info$term_vars, use.names = FALSE))
  length(setdiff(variables, c(exposure, modifier))) > 0L
}

# How the estimate column is headed: "Adjusted odds ratio (95% CI)" and the
# like, naming the measure the model actually produced.
#
# `with_outcome = FALSE` leaves the outcome out, which is what the column
# beside the plot does: the axis under the plot names it, and a column of a
# table is as narrow as it can be made.
fy_estimate_header <- function(info, adjusted, ci_level, with_ci = TRUE,
                               with_outcome = TRUE) {
  label <- if (with_outcome) info$measure_label else info$measure_name
  if (adjusted) {
    label <- paste0("Adjusted ", tolower(substring(label, 1, 1)),
                    substring(label, 2))
  }
  if (!with_ci) {
    return(label)
  }
  paste0(label, " (", round(ci_level * 100), "% CI)")
}

# What is written under the plot: "Adjusted odds ratio for asthma". The axis is
# the one place every figure has, so it is where the outcome is named, and a
# reader who sees only the plot still knows what the ratio is a ratio of.
fy_axis_label <- function(info, adjusted) {
  fy_estimate_header(info, adjusted, ci_level = NULL, with_ci = FALSE,
                     with_outcome = TRUE)
}

# "Adjusted odds ratio for asthma associated with NO2", the phrase every title
# is built out of. The outcome follows the measure, since that is what the
# measure is a measure of; the exposure follows the outcome.
fy_effect_phrase <- function(info, adjusted, exposures) {
  paste0(fy_axis_label(info, adjusted), " associated with ", exposures)
}

# The label under the plot, where the caller has named one.
#
# `NULL` is the one the model wrote for itself, which names the measure and the
# outcome. A string is drawn as it was given, and `NA` draws none, for a figure
# whose caption carries that instead.
fy_resolve_xlab <- function(xlab, default) {
  if (is.null(xlab)) {
    return(default)
  }
  if (length(xlab) == 1L && is.na(xlab)) {
    return(NULL)
  }
  checkmate::assert_string(xlab)
  xlab
}

# The outcome renamed on a model description that has already been built, which
# is what foresty_combine() needs: its figures were drawn one at a time and it
# is relabelling what they came back with rather than fitting anything.
fy_relabel_outcome <- function(info, outcome) {
  if (is.null(outcome)) {
    return(info)
  }
  spec <- fy_apply_outcome(
    list(name = info$measure_name, outcome = info$outcome), outcome
  )
  info$outcome <- spec$outcome
  info$measure_label <- spec$label
  info
}

# Person-time -----------------------------------------------------------------

# The unit person-time is reported in.
#
# `NULL` is the total the model carries, which is what a figure of a few hundred
# person-years wants. A number is a unit to divide by -- `person_time = 1000`
# for a column counting thousands of person-years -- and the column says which,
# since a count of person-time that does not say what it counts cannot be read
# against another study's. Naming the number names the column outright:
# `person_time = c("Person-years (per 1,000)" = 1000)`.
fy_person_time_spec <- function(person_time) {
  if (is.null(person_time)) {
    return(NULL)
  }
  # Already resolved: foresty_combine() takes the unit its figures were drawn
  # with rather than being told it again.
  if (is.list(person_time) && !is.null(person_time$unit)) {
    return(person_time)
  }
  if (!is.numeric(person_time) || length(person_time) != 1L ||
      is.na(person_time) || !is.finite(person_time) || person_time <= 0) {
    stop(
      "`person_time` is the unit person-time is reported in, as ",
      "`person_time = 1000` for a column counting thousands of person-years. ",
      "It must be one positive number, optionally named to head the column: ",
      "`person_time = c(\"Person-years (per 1,000)\" = 1000)`.",
      call. = FALSE
    )
  }
  heading <- names(person_time)
  list(
    unit = as.numeric(person_time),
    heading = if (!is.null(heading) && nzchar(heading[[1L]])) heading[[1L]]
  )
}

# "Person-time" becomes "Person-time (per 1,000)", on a line of its own so that
# the column stays as narrow as the numbers in it.
fy_person_time_heading <- function(base, spec, sep = "\n") {
  if (is.null(spec)) {
    return(base)
  }
  if (!is.null(spec$heading)) {
    return(spec$heading)
  }
  if (isTRUE(all.equal(spec$unit, 1))) {
    return(base)
  }
  paste0(base, sep, "(per ", fy_plain_number(spec$unit), ")")
}

# 1000 written as 1,000, and never as 1e+03.
fy_plain_number <- function(x) {
  format(x, big.mark = ",", trim = TRUE, scientific = FALSE,
         drop0trailing = TRUE)
}
