#' Build a forest plot by clicking
#'
#' Opens a Shiny app on a model you have already fitted, so that the exposures,
#' the modifiers and the layout can be chosen from menus rather than typed,
#' retyped and re-run. Every figure the app draws is drawn by
#' [foresty_interaction()], [foresty_main()] or [foresty_combine()], and the
#' code that drew it is shown in a tab of its own for copying back into your
#' script.
#'
#' @section What the app does not do:
#'
#' It does not fit your model. The estimates a forest plot reports come out of
#' the coefficients and the covariance matrix of a fit, so the model has to
#' exist before there is anything to draw, and which model to fit is the part of
#' the analysis that should be written down in a script rather than clicked
#' together and forgotten. The app is for the part that is fiddling --
#' [foresty_layout()] alone has some thirty arguments, and finding the figure a
#' journal wants by editing a call and re-running it is slow.
#'
#' It does not change the type of your variables either. A modifier stored as a
#' number but taking only two values is drawn as the two subgroups it is,
#' needing no change; one taking three or more is refused, and the refusal is
#' shown where the figure would have been, because turning it into a factor
#' means fitting a different model and that is a decision to make in the script,
#' not a checkbox. See the `interaction` argument of [foresty_interaction()].
#'
#' @section More than one pair:
#'
#' The exposure and the modifier menus both take as many variables as you
#' select, and what is drawn is every pair of them: three exposures and two
#' modifiers are six figures. The overall effect, which comes from the model
#' with no interaction term in it, is a checkbox of its own, so it can be drawn
#' beside the subgroups rather than instead of them. Where more than one figure
#' is drawn the app offers to combine them, which is [foresty_combine()] and
#' follows its rules: figures of one exposure become the blocks of one figure,
#' and figures of different exposures stay apart, since rows reporting the
#' effects of different exposures are not read against each other.
#'
#' How big a difference in the exposure each estimate is for -- one unit, an
#' interquartile range, an increment you name, its two ends either way round,
#' the first to the third quantile, two values you name -- is asked once for each
#' continuous exposure rather than once for all of them, since two exposures
#' rarely want the same answer. The lowest and highest values it takes are
#' written under the choice, and are where naming two values starts from.
#' Whichever was chosen is written on the figure wherever the exposure is
#' named, one unit included -- `"no2 (per 1)"`, `"no2 (per 10)"`,
#' `"no2 (per IQR, 8.44)"` -- since a reader comparing two figures across a
#' screen should not have to know that a row saying nothing means one.
#'
#' Which way round the comparison runs is written with an arrow rather than as
#' "from ... to ...", since that is the part a reader gets wrong: `Lowest value
#' -> Highest value` is the effect of being at the top of the exposure rather
#' than the bottom, and **Reverse the direction** turns it into the same
#' estimate the other way up, which is how a protective effect is drawn as one.
#' The two boxes that name two values are headed the same way, and so is the
#' figure: two values compared are written beside the exposure as
#' `"no2 (4.102 -> 38.72)"` rather than as "38.72 vs 4.102", which says which
#' two values were compared without saying which of them the estimate is the
#' effect of moving to.
#'
#' From one quantile to another is not the interquartile range, though it
#' begins at the quartiles: the range is a width, and an effect per one of it
#' is a step along a slope, whereas the quantiles are two values of the
#' exposure and are compared as `at = c(from, to)`. So it can be asked of a
#' splined exposure, which has no single slope to report a width per, and the
#' two probabilities can be set to anything -- the 10th against the 90th, the
#' median against the top decile -- rather than only 0.25 and 0.75.
#'
#' @section Figure style names:
#'
#' The rows, the axis and the columns of a figure are named after columns of a
#' data set, and a column is called what the data set calls it. **Figure style**
#' renames the outcome -- which is otherwise taken from the left of your
#' formula, `asthma_ever_dx` and all -- replaces the label under the plot
#' outright, and names each selected exposure. A model carrying person-time is
#' also asked what unit to count it in, 1,000 or 100,000 being how a paper
#' reports a rate and six figures beside the plot being width the plot could
#' have had.
#'
#' @section A model too slow to redraw:
#'
#' Every change to a control refits the model once per pair of menus, and while
#' that is happening the app looks exactly as it did before, so a line saying
#' that it is working is shown above the tabs and the figure on the screen is
#' the previous one until it goes.
#'
#' On a model where that wait is not seconds but minutes, **Write the R code
#' only** stops it: nothing is fitted and nothing is drawn, the menus and the
#' style controls go on working, and the **R code** tab goes on writing the call
#' they come to, which is what to paste into the script and run once. The other
#' tabs report on models the app fitted and say so instead.
#'
#' @section Colours and the panel:
#'
#' A figure is drawn in one colour, which is asked for per exposure and can be
#' named as a place in a ColorBrewer palette -- the third colour of Dark2 --
#' or typed as a hex code, which is how a figure is drawn in the colour a
#' journal or a slide deck already uses. **What the colours change with** draws
#' it in more than one instead: a colour per category of the rows, which is the
#' levels of a categorical exposure or the subgroups of the modifier, or a
#' colour per row. Those come from a palette, or from hex codes typed beside it
#' -- `#1B9E77, #D95F02` -- which is the same list `colours` takes. See
#' `colour_by` in [foresty_layout()].
#'
#' @section The tabs:
#'
#' **Plot** draws them, each figure carrying the exposure it is of under its
#' title, which is a line that can be turned off on its own where the title
#' says it already. **Models** writes out, in R, how each figure was arrived at: the term
#' added to your model, the linear combination each subgroup estimate is, and
#' the test reported beside them. That code is meant to be run: it is the call
#' `foresty` made, with the same design matrix, the same coefficients and
#' covariance, the same degrees of freedom and the same test, so pasting it
#' beside the model reproduces the numbers on the figure rather than
#' approximating them. **summary(fit)** is the summary of the model you fitted
#' and of every model the app fitted from it by adding an interaction term.
#' Both tabs head each block with the outcome, the exposure and the effect
#' modifier the figure under it is of, since a coefficient table says none of
#' them. **R code** is the code that drew what is beside it, deparsed rather
#' than reconstructed, so it cannot drift from what you are looking at; several
#' pairs are written as a loop over the pairs rather than as one call apiece. It
#' names the model with the name you passed to `foresty_app()`, so pasting it
#' into a script next to that model works as it stands.
#'
#' @section What comes out:
#'
#' The figure downloads as PNG and as SVG, at the size and resolution set beside
#' the buttons; where the pairs are not being combined, one file per figure
#' comes down in a zip. The reports do the same, one HTML page per model. The
#' objects themselves download as an `.rds` file holding a named list -- one
#' element per pair, plus the combined figure where there is one -- so that a
#' session that ended in the app can go on in a script: `figures <-
#' readRDS("...")` and then `summary(figures[[1]])`,
#' `as.data.frame(figures[[1]])` or `foresty_report(figures[[1]], "x.html")`.
#'
#' @param fit A fitted model, as passed to [foresty_main()] or
#'   [foresty_interaction()]. Its variables become the menus of exposures and
#'   modifiers.
#' @param measure The effect measure, as in [foresty_main()]. `NULL`, the
#'   default, takes the one the model implies.
#' @param launch Whether to start the app. `TRUE` in an interactive session.
#'   `FALSE` returns the Shiny app object without running it, which is what
#'   tests and `shiny::runApp()` want.
#' @param ... Passed to [shiny::runApp()], so that `port` and `launch.browser`
#'   can be set.
#'
#' @return The Shiny app object, invisibly when the app was run.
#'
#' @seealso [foresty_interaction()], [foresty_main()], [foresty_combine()],
#'   [foresty_layout()].
#'
#' @examples
#' fit <- glm(asthma ~ no2 + sex + maternal_smoking + maternal_age,
#'            family = binomial, data = foresty_cohort)
#'
#' # Opens the app in an interactive session.
#' if (interactive()) {
#'   foresty_app(fit)
#' }
#'
#' @export
foresty_app <- function(fit, measure = NULL, launch = interactive(), ...) {
  fy_require("shiny", "run the app")

  # The name the caller knows the model by, so that the code the app writes is
  # code that runs in the caller's session rather than code mentioning a `fit`
  # that only existed inside this function.
  expr <- substitute(fit)
  fit_name <- if (is.name(expr)) as.character(expr) else "fit"

  info <- fy_model_info(fit, measure = measure)
  variables <- fy_app_variables(info)
  if (!length(variables$exposure)) {
    stop(
      "no variable of this model can be an exposure: none of them enters it as ",
      "a term of its own. Its terms are ",
      paste0("\"", names(info$term_map), "\"", collapse = ", "), ".",
      call. = FALSE
    )
  }

  app <- shiny::shinyApp(
    ui = fy_app_ui(info, variables, fit_name),
    server = fy_app_server(fit, info, variables, fit_name, measure)
  )
  if (!isTRUE(launch)) {
    return(app)
  }
  invisible(shiny::runApp(app, ...))
}

# What each variable of the model can be asked to do.
#
# A variable can be the exposure when it enters the model as a term of its own,
# and the modifier when it has levels to split on. Which variables have levels
# is fy_check_modifier()'s decision, not a second copy of it made here, and the
# sentence it refuses with is the sentence the app shows in place of a figure:
# the guards already say what is wrong and what to do about it, so the app puts
# them in front of the choice instead of behind it.
#
# Which of them are continuous is asked as well, because the controls saying
# how big a difference in the exposure to report -- `contrast`, `at` -- mean
# nothing for a categorical one, whose comparisons are its levels. Each of
# those carries an identifier of its own, since it has controls of its own and
# two variables must not end up sharing them.
fy_app_variables <- function(info) {
  vars <- sort(setdiff(unique(unlist(info$term_vars, use.names = FALSE)),
                       info$outcome))

  exposure <- vars[vapply(vars, function(v) {
    length(fy_exposure_terms(info, v)$main) > 0L
  }, logical(1))]

  refusal <- vapply(vars, function(v) {
    out <- tryCatch({
      fy_check_modifier(info, v)
      NA_character_
    }, error = function(e) conditionMessage(e))
    out
  }, character(1))

  continuous <- vars[vapply(vars, function(v) {
    x <- tryCatch(fy_variable(info, v), error = function(e) NULL)
    !is.null(x) && is.numeric(x) && !fy_is_categorical(x)
  }, logical(1))]

  ids <- stats::setNames(
    make.unique(gsub("[^A-Za-z0-9]+", "_", vars), sep = "_"),
    vars
  )

  list(
    all = vars,
    exposure = exposure,
    modifier = vars[is.na(refusal)],
    continuous = continuous,
    range = fy_app_ranges(info, continuous),
    ids = ids,
    refusal = refusal
  )
}

# The lowest and the highest value each continuous variable takes in the data
# the model was fitted to, which is what "from the lowest to the highest" is a
# comparison between and what the two values a reader names start at.
#
# They are rounded to four figures, so that the code the app writes says
# `at = c(4.102, 38.72)` rather than carrying fifteen decimals of a number that
# is only there to say where the range is. Four figures is closer to the
# observed value than any two people would fit a model to.
fy_app_ranges <- function(info, continuous) {
  stats::setNames(lapply(continuous, function(v) {
    x <- tryCatch(fy_variable(info, v), error = function(e) NULL)
    x <- suppressWarnings(as.numeric(x))
    x <- x[is.finite(x)]
    if (length(x) < 2L || min(x) == max(x)) {
      return(NULL)
    }
    signif(range(x), 4)
  }), continuous)
}

# The menu of modifiers, in two groups. A variable that cannot be one is still
# offered, because a reader who wanted maternal age wants to be told why it is
# not there rather than to wonder where it went. The overall effect is not one
# of them: it is a checkbox, since it is not a modifier but the absence of one.
fy_app_modifier_choices <- function(variables) {
  usable <- variables$modifier
  refused <- setdiff(variables$all, usable)
  out <- list()
  if (length(usable)) {
    out[["Can be a modifier"]] <- stats::setNames(usable, usable)
  }
  if (length(refused)) {
    out[["Cannot be a modifier"]] <- stats::setNames(refused, refused)
  }
  out
}

# The columns of the table beside the plot, each said in words rather than by
# the name of its argument: a menu offering "interaction_p" tells a reader who
# already knows what it means, and nobody else.
#
# The p-value of each row is not among them. Two columns of p-values side by
# side, one testing each subgroup effect against the null and the other testing
# the interaction, are read for each other however they are headed, and the one
# a reader reaches for is the test of the interaction.
fy_app_column_choices <- function(info) {
  out <- c(
    "Effect and confidence interval" = "estimate",
    "Observations (N)" = "n"
  )
  if (!is.na(info$events)) {
    out <- c(out, "Events" = "events")
  }
  if (!is.na(info$person_time)) {
    out <- c(out, "Person-time" = "person_time")
  }
  c(out, "p for the interaction" = "interaction_p")
}

# The interface ---------------------------------------------------------------

# The arrow the controls say a direction with, by its code point so that the
# file stays plain ASCII.
fy_arrow <- "\u2192"

# A section of the sidebar that opens and shuts. There are some forty controls
# behind these panels and no more than a handful of them is wanted at once, so
# the ones that are not being used are folded away rather than scrolled past.
# `details` is the browser's own, needing neither a package nor a callback.
fy_app_panel <- function(title, ..., open = FALSE) {
  shiny::tags$details(
    class = "fy-panel",
    open = if (isTRUE(open)) NA else NULL,
    shiny::tags$summary(title),
    shiny::div(class = "fy-panel-body", ...)
  )
}

fy_app_css <- function() {
  paste0(
    ".fy-panel{border:1px solid #dfe3e8;border-radius:6px;margin-bottom:10px;",
    "background:#fff}",
    ".fy-panel>summary{cursor:pointer;padding:8px 10px;font-weight:600;",
    "list-style:revert}",
    ".fy-panel[open]>summary{border-bottom:1px solid #eceff2}",
    ".fy-panel-body{padding:10px 10px 2px 10px}",
    ".fy-panel-body .form-group{margin-bottom:10px}",
    ".fy-figure{margin-bottom:24px}",
    ".fy-figure h4{font-weight:600;margin:4px 0 6px 0}",
    ".fy-buttons .btn{margin:0 6px 6px 0}",
    ".fy-note{color:#5b6570;font-size:90%;margin:-4px 0 10px 0}",
    ".fy-exposure{border-left:3px solid #dfe3e8;padding-left:10px;",
    "margin-bottom:12px}",
    ".fy-exposure>strong{display:block;margin-bottom:4px}",
    # What the app says while it is working. It sits above the figures rather
    # than over them, so that the figure being replaced stays readable while
    # the next one is being fitted.
    ".fy-waiting{display:flex;align-items:center;gap:10px;",
    "border:1px solid #cfd8e3;border-radius:6px;background:#eef3f9;",
    "color:#33475b;padding:10px 14px;margin-bottom:14px;font-weight:600}",
    ".fy-spinner{width:14px;height:14px;border-radius:50%;",
    "border:2px solid #b6c6d8;border-top-color:#33475b;flex:none;",
    "animation:fy-spin 0.9s linear infinite}",
    ".fy-slow-advice{display:none;margin-top:8px;font-weight:400}",
    "@keyframes fy-spin{to{transform:rotate(360deg)}}",
    # A device that would rather not see it move.
    "@media (prefers-reduced-motion:reduce){.fy-spinner{animation:none}}"
  )
}

# What the app says while it is fitting a model and drawing a figure.
#
# A model with an interaction term added is refitted for every pair of menus,
# and on a large one that is seconds rather than milliseconds, during which the
# app looks exactly as it did before: the old figure is still on the screen and
# nothing says that it is the old one. So Shiny's own busy flag is shown as a
# line saying so. It needs no package and no callback -- the class is on <html>
# whenever the server has work outstanding.
fy_app_waiting <- function() {
  shiny::tagList(
    shiny::tags$script(shiny::HTML("(function() {
      var timer;
      $(document).on('shiny:busy', function() {
        clearTimeout(timer); $('#fy-slow-advice').hide();
        timer = setTimeout(function() { $('#fy-slow-advice').show(); }, 10000);
      });
      $(document).on('shiny:idle', function() {
        clearTimeout(timer); $('#fy-slow-advice').hide();
      });
    })();")),
    shiny::conditionalPanel(
      condition = "$('html').hasClass('shiny-busy')",
      shiny::div(
        class = "fy-waiting",
        shiny::div(class = "fy-spinner"),
        shiny::div(
          "Fitting the model and drawing the figure -- waiting... Anything ",
          "already on the screen is the previous one.",
          shiny::div(
            id = "fy-slow-advice", class = "fy-slow-advice",
            "This model is taking a while. For a large data set, consider ",
            "copying the R code and running it outside Shiny."
          )
        )
      )
    )
  )
}

fy_app_ui <- function(info, variables, fit_name) {
  shiny::fluidPage(
    shiny::tags$head(shiny::tags$style(shiny::HTML(fy_app_css()))),
    shiny::titlePanel("foresty"),
    shiny::sidebarLayout(
      shiny::sidebarPanel(
        width = 3,

        # The two choices the figure is of. Both keep every variable picked, so
        # that a second exposure is added to the first rather than replacing it.
        shiny::selectInput(
          "exposure", "Exposures (as many as you want)",
          choices = variables$exposure, selected = variables$exposure[1L],
          multiple = TRUE
        ),
        shiny::selectInput(
          "modifier", "Effect modifiers (as many as you want)",
          choices = fy_app_modifier_choices(variables), multiple = TRUE
        ),
        shiny::checkboxInput(
          "overall",
          "Also draw the overall effect, from the model with no interaction term",
          value = TRUE
        ),
        shiny::checkboxInput(
          "combine", "Combine the pairs into one figure", value = TRUE
        ),
        shiny::div(class = "fy-note", paste0(
          "Every exposure is drawn against every modifier. Combining follows ",
          "foresty_combine(): one figure per exposure, its modifiers as ",
          "blocks. Uncombined, each figure is exported as a file of its own."
        )),

        fy_app_panel(
          "Figure style",
          shiny::selectInput("style", "Journal style",
                             choices = c("classic", "jama", "nejm", "lancet",
                                         "bmj", "revman")),
          shiny::sliderInput("base_size", "Text size (pt)", min = 8, max = 36,
                             value = 16, step = 1),
          shiny::radioButtons(
            "colour_by", "What the colours change with",
            choices = c("One colour for the whole figure" = "none",
                        "One per category of the rows" = "category",
                        "One per row" = "row"),
            selected = "none"
          ),
          shiny::conditionalPanel(
            "input.colour_by != 'none'",
            shiny::selectInput("palette", "Palette",
                               choices = c("Dark2", "Set1", "Set2")),
            shiny::textInput(
              "colours_hex", "Or hex codes of your own, separated by commas",
              placeholder = "#1B9E77, #D95F02, #7570B3"
            ),
            shiny::div(class = "fy-note", paste0(
              "The colours are taken in the order they are written and reused ",
              "from the start where the rows outrun them. A category keeps ",
              "its colour wherever it appears. No legend is drawn: the rows ",
              "are labelled already."
            ))
          ),
          shiny::checkboxInput("table", "Table of numbers beside the plot",
                               value = TRUE),
          shiny::selectInput(
            "columns", "Columns of that table (empty for the style's default)",
            choices = fy_app_column_choices(info), multiple = TRUE
          ),
          shiny::numericInput(
            "digits",
            paste0("Decimal places for the ", tolower(info$measure_name),
                   " and its interval"),
            value = 2, min = 0, max = 4, step = 1
          ),
          shiny::checkboxInput("use_xlim", "Fix the limits of the plot",
                               value = FALSE),
          shiny::conditionalPanel(
            "input.use_xlim == true",
            shiny::numericInput("xlim_low", "Lower limit", value = 0.5),
            shiny::numericInput("xlim_high", "Upper limit", value = 2)
          ),
          shiny::textInput("title", "Title (empty for the default)"),
          shiny::checkboxInput("no_title", "Draw no title", value = FALSE),
          shiny::checkboxInput(
            "no_subtitle",
            "Draw no subtitle (the \"Exposure: ...\" line under the title)",
            value = FALSE
          ),
          # Names are part of how the finished figure looks, so keep them with
          # the other figure-wide styling choices rather than with estimation.
          # The exposure is renamed where it is chosen -- foresty_main() takes
          # `exposure = c(NO2 = "no2")` -- so there is a box per exposure, in
          # this Figure style panel. The outcome and the axis belong to the
          # whole figure and are asked once.
          shiny::div(class = "fy-note", paste0(
            "The outcome is taken from the left of your formula, which is the ",
            "name of a column and rarely what a figure should say the effect ",
            "is an effect on. Each selected exposure can be renamed here."
          )),
          shiny::fluidRow(
            shiny::column(6, shiny::textInput(
              "outcome",
              if (is.na(info$outcome %||% NA)) {
                "What to call the outcome"
              } else {
                paste0("What to call the outcome (empty for \"", info$outcome,
                       "\")")
              }
            )),
            shiny::column(6, shiny::uiOutput("exposure_labels"))
          ),
          shiny::uiOutput("modifier_labels"),
          shiny::textInput("xlab", "Label under the plot (empty for the default)",
                           placeholder = fy_axis_label(info, TRUE)),
          fy_app_person_time_control(info)
        ),

        fy_app_panel(
          "Each exposure",
          shiny::div(class = "fy-note", paste0(
            "Two exposures rarely want the same answers, so the colour they ",
            "are drawn in and the difference each estimate is for are asked ",
            "once apiece."
          )),
          shiny::conditionalPanel(
            "input.colour_by != 'none'",
            shiny::div(class = "fy-note", paste0(
              "The rows are being drawn in colours of their own, so the ",
              "colour chosen here is not used."
            ))
          ),
          shiny::uiOutput("exposure_controls")
        ),

        fy_app_panel(
          "Model",
          shiny::radioButtons(
            "test", "Test of the interaction",
            choices = c("Likelihood ratio" = "lrt", "Wald" = "wald"),
            selected = "lrt"
          ),
          fy_app_scale_control(info),
          shiny::numericInput("ci_level", "Confidence level", value = 0.95,
                              min = 0.5, max = 0.9999, step = 0.01)
        ),

        fy_app_panel(
          "Export", open = TRUE,
          shiny::fluidRow(
            shiny::column(6, shiny::numericInput("width", "Width (in)",
                                                 value = 10, min = 2, step = 1)),
            shiny::column(6, shiny::numericInput("height", "Height (in)",
                                                 value = 6, min = 2, step = 1))
          ),
          shiny::numericInput("dpi", "Resolution of the PNG (dpi)", value = 300,
                              min = 72, max = 900, step = 50),
          shiny::div(
            class = "fy-buttons",
            shiny::downloadButton("save_png", "PNG"),
            shiny::downloadButton("save_svg", "SVG"),
            shiny::downloadButton("save_objects", "Objects (.rds)"),
            shiny::downloadButton("save_report", "Reports (HTML)")
          )
        )
      ),
      shiny::mainPanel(
        width = 9,
        fy_app_waiting(),
        shiny::tabsetPanel(
          shiny::tabPanel(
            "Plot",
            shiny::br(),
            shiny::uiOutput("message"),
            shiny::uiOutput("plots")
          ),
          shiny::tabPanel(
            "Models",
            shiny::br(),
            shiny::p(shiny::em(paste0(
              "How each figure was arrived at, written out in R. The code is ",
              "what foresty does, not a description of it."
            ))),
            shiny::verbatimTextOutput("models")
          ),
          shiny::tabPanel(
            "summary(fit)",
            shiny::br(),
            shiny::p(shiny::em(paste0(
              "The model you fitted, and every model the app fitted from it ",
              "by adding an interaction term."
            ))),
            shiny::verbatimTextOutput("model")
          ),
          shiny::tabPanel(
            "R code",
            shiny::br(),
            shiny::p(shiny::em(paste0(
              "The code that drew the figures. Paste it into the script that ",
              "fits ", fit_name, "."
            ))),
            shiny::verbatimTextOutput("code")
          )
        )
      )
    )
  )
}

# Which scale the estimates are reported on, said as the two things it is a
# choice between rather than as a box to tick.
#
# A mean difference and a bare coefficient are on that scale already and have
# no ratio to be drawn as, so there is nothing to choose and no control.

fy_app_scale_control <- function(info) {
  if (!isTRUE(info$exponentiate)) {
    return(shiny::div(class = "fy-note", paste0(
      "This model reports a ", tolower(info$measure_name),
      ", which is on the scale it was fitted on; there is no ratio scale to ",
      "choose between."
    )))
  }
  ratio <- info$measure_name
  shiny::radioButtons(
    "scale", "Scale the estimates are reported on",
    choices = stats::setNames(
      c("ratio", "log"),
      c(paste0(ratio, " -- the regression coefficient exponentiated, drawn ",
               "about 1"),
        paste0("Regression coefficient -- the scale the model was fitted on, ",
               "drawn about 0"))
    ),
    selected = "ratio"
  )
}

# The unit person-time is counted in, for a model that carries any.
#
# A cohort of a few hundred thousand person-years puts six figures in a column
# beside the plot and takes that width from it, and a rate is reported per
# 1,000 or per 100,000 in a paper anyway. A model with no time behind it -- a
# logistic regression -- has no such column and is asked nothing.
fy_app_person_time_control <- function(info) {
  if (is.na(info$person_time)) {
    return(NULL)
  }
  shiny::tagList(
    shiny::numericInput(
      "person_time", "Count person-time in units of", value = 1, min = 0,
      step = 1000
    ),
    shiny::div(class = "fy-note", paste0(
      "1 is the total, which is ", fy_format_count(info$person_time),
      " here. 1000 draws thousands of person-time and heads the column ",
      "\"Person-time (per 1,000)\"."
    ))
  )
}

# The colours an exposure can be drawn in. A figure is drawn in one colour --
# the point, its border and its interval -- so this is that colour rather than
# a palette, and "the style's own" leaves the journal style to say.
#
# The eight of Dark2 are offered by their number as well as by their name, since
# that is how a figure drawn to match another one is asked for: the third colour
# of Dark2, not "purple". They are foresty_colours()'s own, so the code the app
# writes and the swatch beside the menu cannot come apart.
#
# The last of them is a hex code typed rather than picked, which is what a
# figure drawn to match a journal's own colours or the rest of a slide deck
# needs, since no menu can hold those.
fy_app_colour_choices <- function() {
  dark2 <- foresty_colours("Dark2")
  names(dark2) <- paste0("Dark2 ", seq_along(dark2), " -- ",
                         c("green", "orange", "purple", "pink", "light green",
                           "yellow", "brown", "grey"))
  c("The style's own" = "",
    "Black" = "#000000",
    dark2,
    "Blue" = "#1A476F",
    "Red" = "#B24745",
    "A hex code I type" = "hex")
}

# A hex colour as it has to be written to be one: `#RGB`, `#RRGGBB` or
# `#RRGGBBAA`, with the `#` supplied where it was left out, since that is how a
# colour is copied out of a style guide. Anything else is not a colour and is
# treated as though nothing had been typed, so that a half-typed code draws the
# figure in the style's own rather than refusing to draw it.
fy_app_hex <- function(x) {
  if (is.null(x)) {
    return(character(0))
  }
  out <- trimws(unlist(strsplit(as.character(x), "[,;[:space:]]+")))
  out <- out[nzchar(out)]
  out <- ifelse(startsWith(out, "#"), out, paste0("#", out))
  out[grepl("^#([0-9A-Fa-f]{3}|[0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$", out)]
}

# The controls for one exposure. Two exposures are two sets of questions -- one
# pollutant reported per interquartile range in red, an age per decade in blue
# -- so each of them is asked separately and keeps its own answers.
fy_app_exposure_ui <- function(exposure, id, continuous, input, range = NULL) {
  kind <- paste0("contrast_kind_", id)
  colour <- paste0("colour_", id)
  # Whatever was chosen last time is what these come back as: the controls are
  # rebuilt whenever the menu of exposures changes, and an exposure that is
  # still there has not changed its mind.
  kept <- function(name, default) shiny::isolate(input[[name]]) %||% default

  # The lowest and highest values the exposure takes are what "from the lowest
  # to the highest" compares, and they are also where naming two values starts
  # from, since a reader naming them is usually moving one of the ends.
  lowest <- if (is.null(range)) 0 else range[[1L]]
  highest <- if (is.null(range)) 1 else range[[2L]]
  ends <- if (is.null(range)) {
    NULL
  } else {
    list(shiny::div(class = "fy-note", paste0(
      "In the data this model was fitted to, ", exposure, " runs from ",
      fy_trim_number(lowest), " to ", fy_trim_number(highest), "."
    )))
  }

  difference <- if (!continuous) {
    list(shiny::div(class = "fy-note", paste0(
      "Categorical, so its comparisons are its levels and there is no ",
      "difference to name."
    )))
  } else {
    # Which way round the comparison runs is the thing a reader gets wrong, and
    # "from ... to ..." spread over a line of prose is where they get it wrong,
    # so the two ends are written with an arrow between them and read at a
    # glance: lowest -> highest is the effect of being at the top rather than
    # the bottom, and the other way round is that same estimate inverted.
    choices <- c("One unit increase" = "unit",
                 "One interquartile range increase" = "iqr",
                 "An increment increase I name" = "number")
    if (!is.null(range)) {
      choices <- c(
        choices,
        # Written by its code point so that the file stays plain ASCII.
        stats::setNames(
          c("range", "quantile"),
          c(paste0("Lowest value ", fy_arrow, " Highest value"),
            paste0("First quartile ", fy_arrow, " Third quartile"))
        )
      )
    }
    choices <- c(choices, "Two values I name" = "at")
    c(
      list(
        shiny::selectInput(
          kind, "The difference each estimate is for",
          choices = choices, selected = kept(kind, "unit")
        ),
        shiny::conditionalPanel(
          paste0("input.", kind, " == 'number'"),
          shiny::numericInput(paste0("contrast_", id), "Effect per",
                              value = kept(paste0("contrast_", id), 10))
        ),
        shiny::conditionalPanel(
          paste0("input.", kind, " != 'at'"),
          shiny::checkboxInput(
            paste0("contrast_reverse_", id),
            "Reverse the direction", value = kept(paste0("contrast_reverse_", id), FALSE)
          )
        ),
        # The two probabilities rather than the two values: 0.25 and 0.75 are
        # the quartiles, and any other pair -- 0.1 and 0.9, 0.5 and 0.9 -- is
        # the same question asked further out.
        shiny::conditionalPanel(
          paste0("input.", kind, " == 'quantile'"),
          shiny::fluidRow(
            shiny::column(6, shiny::numericInput(
              paste0("quantile_low_", id), "First quartile",
              value = kept(paste0("quantile_low_", id), 0.25),
              min = 0, max = 1, step = 0.05
            )),
            shiny::column(6, shiny::numericInput(
              paste0("quantile_high_", id),
              paste0(fy_arrow, " Third quartile"),
              value = kept(paste0("quantile_high_", id), 0.75),
              min = 0, max = 1, step = 0.05
            ))
          )
        ),
        # Two boxes headed "From" and "To" are read as two numbers, and which
        # of them the estimate is the effect of moving to is what a reader has
        # to know. The arrow is on the second so that the pair reads as one
        # thing: 4.102 -> 38.72.
        shiny::conditionalPanel(
          paste0("input.", kind, " == 'at'"),
          shiny::fluidRow(
            shiny::column(6, shiny::numericInput(
              paste0("at_from_", id), "Value",
              value = kept(paste0("at_from_", id), lowest)
            )),
            shiny::column(6, shiny::numericInput(
              paste0("at_to_", id), paste0(fy_arrow, " To value"),
              value = kept(paste0("at_to_", id), highest)
            ))
          ),
          shiny::div(class = "fy-note", paste0(
            "The estimate is the effect of ", exposure, " being the second ",
            "rather than the first."
          ))
        )
      ),
      ends
    )
  }

  colour_hex <- paste0("colour_hex_", id)
  label <- paste0("label_", id)
  shiny::div(
    class = "fy-exposure",
    shiny::tags$strong(exposure),
    shiny::selectInput(colour, "Colour", choices = fy_app_colour_choices(),
                       selected = kept(colour, "")),
    shiny::conditionalPanel(
      paste0("input.", colour, " == 'hex'"),
      shiny::textInput(colour_hex, "Hex code",
                       value = kept(colour_hex, ""),
                       placeholder = "#B24745")
    ),
    difference
  )
}

# Names shown on the finished figure are Figure style controls.  They keep the
# same input IDs as before, so a name remains in place if exposure controls are
# rebuilt after the selection changes.
fy_app_exposure_labels_ui <- function(exposure, id, input) {
  label <- paste0("label_", id)
  kept <- function(name, default) shiny::isolate(input[[name]]) %||% default
  shiny::div(
    shiny::textInput(label, paste0("What to call ", exposure, " on the figure"),
                     value = kept(label, ""), placeholder = exposure)
  )
}

# The groups of rows in an interaction figure are its modifier's levels.  They
# are names on the finished figure just like the outcome and exposure are.
fy_app_modifier_labels_ui <- function(modifier, id, info, input) {
  x <- tryCatch(fy_variable(info, modifier), error = function(e) NULL)
  levels <- levels(droplevels(as.factor(x)))
  kept <- function(name, default) shiny::isolate(input[[name]]) %||% default
  shiny::div(
    class = "fy-exposure",
    shiny::tags$strong(paste0("Subgroup names: ", modifier)),
    shiny::textInput(
      paste0("modifier_label_", id),
      paste0("What to call ", modifier, " on the figure"),
      value = kept(paste0("modifier_label_", id), ""),
      placeholder = modifier
    ),
    lapply(seq_along(levels), function(i) {
      shiny::textInput(
        paste0("level_label_", id, "_", i),
        paste0("What to call ", levels[i], " on the figure"),
        value = kept(paste0("level_label_", id, "_", i), ""),
        placeholder = levels[i]
      )
    })
  )
}

# The server ------------------------------------------------------------------

fy_app_server <- function(fit, info, variables, fit_name, measure) {
  function(input, output, session) {
    ctx <- list(info = info, variables = variables, fit_name = fit_name,
                measure = measure)

    # Every pair the menus come to, and the call that draws each of them. The
    # calls are built once and then both evaluated and printed, so the code
    # shown in the R code tab is the code that drew the figures rather than a
    # description of them written separately and left to drift.
    pairs <- shiny::reactive(fy_app_pairs(input))

    output$exposure_controls <- shiny::renderUI({
      vars <- fy_app_chosen(input$exposure)
      if (!length(vars)) {
        return(shiny::div(class = "fy-note", "Choose an exposure."))
      }
      shiny::tagList(lapply(vars, function(v) {
        fy_app_exposure_ui(v, variables$ids[[v]], v %in% variables$continuous,
                           input, range = variables$range[[v]])
      }))
    })
    output$exposure_labels <- shiny::renderUI({
      vars <- fy_app_chosen(input$exposure)
      if (!length(vars)) {
        return(shiny::div(class = "fy-note", "Choose an exposure."))
      }
      shiny::tagList(lapply(vars, function(v) {
        fy_app_exposure_labels_ui(v, variables$ids[[v]], input)
      }))
    })
    output$modifier_labels <- shiny::renderUI({
      vars <- fy_app_chosen(input$modifier)
      if (!length(vars)) return(NULL)
      shiny::tagList(lapply(vars, function(v) {
        fy_app_modifier_labels_ui(v, variables$ids[[v]], info, input)
      }))
    })
    # The panel these live in is shut until it is wanted, and an output inside
    # something shut is suspended, so it is told not to be: the controls have
    # to exist for the figure to know what they say.
    shiny::outputOptions(output, "exposure_controls", suspendWhenHidden = FALSE)
    shiny::outputOptions(output, "exposure_labels", suspendWhenHidden = FALSE)
    shiny::outputOptions(output, "modifier_labels", suspendWhenHidden = FALSE)

    figures <- shiny::reactive({
      chosen <- pairs()
      object_names <- fy_app_object_names(chosen)
      many <- length(chosen) > 1L
      out <- lapply(seq_along(chosen), function(i) {
        pair <- chosen[[i]]
        state <- fy_app_evaluate(
          fy_app_call(pair, input, ctx, many = many),
          stats::setNames(list(fit), fit_name)
        )
        c(state, list(name = object_names[i],
                      label = fy_app_pair_label(pair),
                      pair = pair))
      })
      stats::setNames(out, vapply(out, function(s) s$label, character(1)))
    })

    # The combined figure, drawn from the figures themselves rather than from
    # the model again, which is what foresty_combine() takes. A pair the guards
    # refused has no figure to combine, so it is left out and its refusal is
    # shown beside the ones that worked.
    combined <- shiny::reactive({
      drawn <- Filter(function(s) !is.null(s$value), figures())
      if (!isTRUE(input$combine) || length(drawn) < 2L) {
        return(NULL)
      }
      objects <- stats::setNames(lapply(drawn, function(s) s$value),
                                 vapply(drawn, function(s) s$name, character(1)))
      call <- fy_app_combine_call(names(objects), input, ctx,
                                  lapply(drawn, function(s) s$pair))
      fy_app_evaluate(call, objects)
    })

    # What the Plot tab draws and the buttons write: the combined figure where
    # there is one, and otherwise every figure that could be drawn.
    #
    # Each figure says which exposure it is of under its own title, so there is
    # nothing to head it with here. The exception is a combination of several
    # exposures, which foresty_combine() returns as one figure apiece and which
    # could not be given a subtitle of its own, and a figure drawn with no
    # title at all, where there is nowhere inside it for the exposure to go.
    display <- shiny::reactive({
      state <- combined()
      out <- if (!is.null(state) && !is.null(state$value)) {
        fy_app_as_list(state$value, "Combined")
      } else {
        drawn <- Filter(function(s) !is.null(s$value), figures())
        stats::setNames(lapply(drawn, function(s) s$value), names(drawn))
      }
      # Each figure says which exposure it is of under its own title, so there
      # is nothing to head it with here -- unless the titles were turned off,
      # when there is nowhere inside a figure for that to go.
      attr(out, "headings") <- if (isTRUE(input$no_title) && length(out) > 1L) {
        names(out)
      } else {
        NULL
      }
      out
    })

    # The state the single-figure outputs read: the combined figure where the
    # app is showing one, and otherwise the first pair.
    figure <- shiny::reactive({
      states <- figures()
      if (!length(states)) {
        return(list(value = NULL, notes = character(0),
                    error = "choose an exposure"))
      }
      combination <- combined()
      if (!is.null(combination) && is.null(combination$error)) {
        return(combination)
      }
      states[[1L]]
    })

    output$message <- shiny::renderUI({
      states <- figures()
      named <- length(states) > 1L
      items <- list()

      if (!length(states)) {
        items <- c(items, list(shiny::div(
          class = "alert alert-warning",
          "Choose at least one exposure."
        )))
      }

      # What foresty says while it works is worth as much as what it draws --
      # that the model already carried the interaction, that the Wald test was
      # reported because the likelihood ratio test could not be -- so its
      # messages are shown rather than swallowed. A guard that refuses outright
      # carries the remedy in the error, and that is shown in place of the
      # figure rather than crashing the session.
      for (state in states) {
        prefix <- if (named) paste0(state$label, ": ") else ""
        if (!is.null(state$error)) {
          items <- c(items, list(shiny::div(
            class = "alert alert-warning",
            shiny::strong(paste0(prefix, "this figure cannot be drawn. ")),
            state$error
          )))
        }
        for (note in state$notes) {
          items <- c(items, list(shiny::div(class = "alert alert-info",
                                            paste0(prefix, note))))
        }
      }

      combination <- combined()
      if (!is.null(combination) && !is.null(combination$error)) {
        items <- c(items, list(shiny::div(
          class = "alert alert-warning",
          shiny::strong("These figures cannot be combined. "),
          combination$error
        )))
      }

      if (!length(items)) NULL else shiny::tagList(items)
    })

    # One plot output per figure, each as tall as the export is, so that what is
    # on the screen is the shape of what comes out of the buttons.
    output$plots <- shiny::renderUI({
      figs <- display()
      shiny::req(length(figs) > 0L)
      height <- paste0(round(fy_app_number(input$height, 6) * 96), "px")
      headings <- attr(figs, "headings")
      # A screenful is a dozen; the rest are still drawn, and still go into the
      # downloads, but a page of them nobody scrolls to is not worth the wait.
      hidden <- length(figs) - fy_app_max_plots
      shown <- min(length(figs), fy_app_max_plots)

      items <- lapply(seq_len(shown), function(i) {
        shiny::div(
          class = "fy-figure",
          if (!is.null(headings)) shiny::h4(headings[i]) else NULL,
          shiny::plotOutput(paste0("plot_", i), height = height)
        )
      })
      if (hidden > 0L) {
        items <- c(items, list(shiny::div(
          class = "alert alert-info",
          paste0(hidden, " more ",
                 if (hidden == 1L) "figure is" else "figures are",
                 " drawn but not shown. They are in the downloads; choose ",
                 "fewer exposures or modifiers to see them here.")
        )))
      }
      shiny::tagList(items)
    })

    # The renderers are made once and read the figure they are for when they
    # draw, so that changing a control redraws rather than piling up outputs.
    for (i in seq_len(fy_app_max_plots)) {
      local({
        index <- i
        output[[paste0("plot_", index)]] <- shiny::renderPlot(res = 96, {
          figs <- display()
          shiny::req(length(figs) >= index)
          print(figs[[index]])
        })
      })
    }

    output$models <- shiny::renderPrint({
      fy_app_model_report(fit, fit_name, figures(), input, ctx)
    })

    output$model <- shiny::renderPrint({
      fy_app_summaries(fit, fit_name, figures(), input, ctx)
    })

    output$code <- shiny::renderText({
      fy_app_script(pairs(), input, ctx)
    })

    output$save_png <- shiny::downloadHandler(
      filename = function() fy_app_file_name(pairs(), display(), "png"),
      content = function(file) {
        shiny::req(length(display()) > 0L)
        fy_app_save_all(display(), file, "png", input)
      }
    )

    output$save_svg <- shiny::downloadHandler(
      filename = function() fy_app_file_name(pairs(), display(), "svg"),
      content = function(file) {
        shiny::req(length(display()) > 0L)
        fy_app_save_all(display(), file, "svg", input)
      }
    )

    # The figures themselves, named for the pairs they are of, so that what was
    # clicked together can be gone on with in a script.
    output$save_objects <- shiny::downloadHandler(
      filename = function() paste0(fy_app_slug(pairs()), ".rds"),
      content = function(file) {
        drawn <- Filter(function(s) !is.null(s$value), figures())
        shiny::req(length(drawn) > 0L)
        objects <- stats::setNames(lapply(drawn, function(s) s$value),
                                   names(drawn))
        combination <- combined()
        if (!is.null(combination) && !is.null(combination$value)) {
          made <- fy_app_as_list(combination$value, "Combined")
          names(made) <- if (length(made) == 1L) {
            "Combined"
          } else {
            paste0("Combined: ", names(made))
          }
          objects <- c(objects, made)
        }
        saveRDS(objects, file)
      }
    )

    # One page per figure, since a report is of one model: what a page holds --
    # the coefficient table, the joint test -- belongs to the model it came
    # from and cannot be stacked.
    output$save_report <- shiny::downloadHandler(
      filename = function() fy_app_file_name(pairs(), display(), "html"),
      content = function(file) {
        figs <- display()
        shiny::req(length(figs) > 0L)
        fy_app_write_reports(figs, file, input)
      }
    )
  }
}

# How many plot outputs the app keeps ready. Every pair of a menu of exposures
# and a menu of modifiers is a figure, and past a dozen a screen of them is not
# read anyway.
fy_app_max_plots <- 12L

# The pairs ------------------------------------------------------------------

# What was chosen, in the order it was chosen, without the blanks a menu leaves
# behind.
fy_app_chosen <- function(x) {
  if (is.null(x)) {
    return(character(0))
  }
  x <- unique(as.character(x[!is.na(x)]))
  x[nzchar(x)]
}

# Every exposure against every modifier, the overall effect first where it was
# asked for. Choosing no modifier at all is the overall effect whether or not
# the box is ticked, since otherwise nothing would be drawn.
fy_app_pairs <- function(input) {
  exposures <- fy_app_chosen(input$exposure)
  if (!length(exposures)) {
    return(list())
  }
  modifiers <- fy_app_chosen(input$modifier)
  overall <- isTRUE(input$overall) || !length(modifiers)

  out <- list()
  for (exposure in exposures) {
    if (overall) {
      out[[length(out) + 1L]] <- list(exposure = exposure, modifier = NULL)
    }
    for (modifier in modifiers) {
      out[[length(out) + 1L]] <- list(exposure = exposure, modifier = modifier)
    }
  }
  out
}

fy_app_pair_label <- function(pair) {
  if (is.null(pair$modifier)) {
    paste0(pair$exposure, ", overall")
  } else {
    paste0(pair$exposure, " by ", pair$modifier)
  }
}

# What each figure is called in the code the app writes and in the list it
# exports. A repeat cannot happen from the menus, but make.unique() costs
# nothing and a duplicated name would silently drop a figure.
fy_app_object_names <- function(pairs) {
  if (!length(pairs)) {
    return(character(0))
  }
  make.unique(vapply(pairs, function(pair) {
    paste0("fig_", fy_file_slug(c(pair$exposure, pair$modifier %||% "overall")))
  }, character(1)), sep = "_")
}

# The name a download is offered under: what the figure is of where it is one
# figure, and what the figures are of where they are several.
fy_app_slug <- function(pairs) {
  if (!length(pairs)) {
    return("foresty")
  }
  if (length(pairs) == 1L) {
    return(fy_file_slug(c(pairs[[1L]]$exposure,
                          pairs[[1L]]$modifier %||% "overall")))
  }
  exposures <- unique(vapply(pairs, function(p) p$exposure, character(1)))
  fy_file_slug(c(exposures, "figures"))
}

# Several figures come down as several files, in a zip; one comes down as
# itself.
fy_app_file_name <- function(pairs, figures, ext) {
  slug <- fy_app_slug(pairs)
  if (length(figures) > 1L) {
    paste0(slug, "_", ext, ".zip")
  } else {
    paste0(slug, ".", ext)
  }
}

# The calls ------------------------------------------------------------------

# The call one pair comes to.
#
# Only what was moved off its default is written, so that the code tab reads
# like code a person would write and not like a dump of every argument the
# function takes. `foresty_main()` takes a list of models and no modifier;
# `foresty_interaction()` takes one model and one.
fy_app_call <- function(pair, input, ctx, many = FALSE) {
  modifier <- pair$modifier
  fit_symbol <- as.name(ctx$fit_name)

  named <- fy_app_exposure_arg(input, pair$exposure, ctx)
  args <- list()
  if (is.null(modifier)) {
    args[[1L]] <- call("list", fit_symbol)
    args$exposure <- named
  } else {
    args[[1L]] <- fit_symbol
    args$exposure <- named
    args$interaction <- fy_app_modifier_arg(input, modifier, ctx)
  }

  if (!is.null(ctx$measure)) args$measure <- ctx$measure
  if (identical(input$scale, "log")) args$exponentiate <- FALSE
  if (!fy_app_same(input$ci_level, 0.95)) args$ci_level <- input$ci_level
  args <- c(args, fy_app_contrast_args(input, pair$exposure, ctx))
  if (!is.null(modifier)) {
    level_labels <- fy_app_level_labels_arg(input, modifier, ctx)
    if (!is.null(level_labels)) args$level_labels <- level_labels
  }

  # The test belongs to the interaction, and its default is the one the package
  # picks.
  if (!is.null(modifier) && !identical(input$test %||% "lrt", "lrt")) {
    args$test <- input$test
  }
  args <- c(args, fy_app_figure_args(input,
                                     fy_app_colour(input, pair$exposure, ctx)))
  if (isTRUE(many)) {
    subtitle <- fy_app_subtitle(pair$exposure, input, ctx)
    if (!is.null(subtitle)) args$subtitle <- subtitle
  }

  fn <- if (is.null(modifier)) quote(foresty_main) else quote(foresty_interaction)
  as.call(c(fn, args))
}

# What this exposure is called on the figure, as the argument that says it.
#
# The label is written where the exposure is chosen -- `exposure = c(NO2 =
# "no2")` -- rather than in a `labels` vector of its own, because that is one
# thing to paste into a script instead of two, and it is how the package's own
# examples name an exposure. Nothing is written where the box was left empty.
fy_app_exposure_arg <- function(input, exposure, ctx) {
  id <- ctx$variables$ids[[exposure]]
  if (is.null(id)) {
    return(exposure)
  }
  label <- input[[paste0("label_", id)]]
  if (is.null(label) || !nzchar(trimws(label))) {
    return(exposure)
  }
  stats::setNames(exposure, trimws(label))
}

# The modifier is named where its subgroup labels are edited.  Naming it in
# `interaction` lets foresty use the same name for the subgroup heading, title
# and HTML report.
fy_app_modifier_arg <- function(input, modifier, ctx) {
  id <- ctx$variables$ids[[modifier]]
  if (is.null(id)) return(modifier)
  label <- input[[paste0("modifier_label_", id)]]
  if (is.null(label) || !nzchar(trimws(label))) return(modifier)
  stats::setNames(modifier, trimws(label))
}

# The same thing as a `labels` vector, for the places that ask the package what
# a row will say rather than telling it.
fy_app_label_of <- function(input, exposure, ctx) {
  named <- fy_app_exposure_arg(input, exposure, ctx)
  if (is.null(names(named))) {
    return(NULL)
  }
  stats::setNames(names(named), unname(named))
}

# Which difference in the exposure the estimate is of, for this exposure.
# `at` names the two values and `contrast` says how far apart they are, so a
# call carries one of them and never both.
#
# One unit is written as `contrast = 1` rather than left out. It is the same
# estimate either way, but a figure that was asked for per one unit says so --
# "no2 (per 1)" -- and a figure asked for per ten says "per 10"; a reader
# comparing two of them across a screen should not have to know that a row
# saying nothing means one.
fy_app_contrast_args <- function(input, exposure, ctx) {
  variables <- ctx$variables
  id <- variables$ids[[exposure]]
  if (is.null(id) || !exposure %in% variables$continuous) {
    return(list())
  }
  kind <- input[[paste0("contrast_kind_", id)]] %||% "unit"
  reverse <- isTRUE(input[[paste0("contrast_reverse_", id)]])
  range <- variables$range[[exposure]]
  if (identical(kind, "at")) {
    return(list(at = call(
      "c",
      fy_app_number(input[[paste0("at_from_", id)]],
                    if (is.null(range)) 0 else range[[1L]]),
      fy_app_number(input[[paste0("at_to_", id)]],
                    if (is.null(range)) 1 else range[[2L]])
    )))
  }
  # The two ends of the exposure, which is the comparison an exposure with no
  # natural unit is often reported for -- the healthiest against the worst
  # exposed -- and which is the one comparison a splined exposure can be asked
  # for without naming two numbers. Reversed, it is the same estimate the other
  # way up, which is how a protective effect is drawn as one.
  if (identical(kind, "range")) {
    if (is.null(range)) {
      return(list())
    }
    at <- if (reverse) rev(range) else range
    return(list(at = call("c", at[[1L]], at[[2L]])))
  }
  # Two quantiles of the exposure, which is a different question from the
  # interquartile range even though it starts at the same two places: the range
  # is a width and is reported per one of it, these are two values and are
  # compared as such. A splined exposure has no width to be reported per, so
  # this is the one form of the question it can be asked.
  if (identical(kind, "quantile")) {
    at <- fy_app_quantile_values(
      ctx$info, exposure,
      c(fy_app_number(input[[paste0("quantile_low_", id)]], 0.25),
        fy_app_number(input[[paste0("quantile_high_", id)]], 0.75))
    )
    if (is.null(at)) {
      return(list())
    }
    if (reverse) at <- rev(at)
    return(list(at = call("c", at[[1L]], at[[2L]])))
  }
  if (identical(kind, "iqr")) {
    if (reverse) {
      x <- tryCatch(fy_variable(ctx$info, exposure), error = function(e) NULL)
      return(list(contrast = -stats::IQR(x, na.rm = TRUE)))
    }
    return(list(contrast = "iqr"))
  }
  value <- input[[paste0("contrast_", id)]]
  if (identical(kind, "number")) {
    value <- fy_app_number(value, 1)
    return(list(contrast = if (reverse) -value else value))
  }
  list(contrast = if (reverse) -1 else 1)
}

# The named vector supplied to `level_labels`, written only where a subgroup
# was renamed.  The level itself remains the vector name; the input is its
# display value.
fy_app_level_labels_arg <- function(input, modifier, ctx) {
  id <- ctx$variables$ids[[modifier]]
  x <- tryCatch(fy_variable(ctx$info, modifier), error = function(e) NULL)
  levels <- levels(droplevels(as.factor(x)))
  values <- vapply(seq_along(levels), function(i) {
    trimws(input[[paste0("level_label_", id, "_", i)]] %||% "")
  }, character(1))
  if (!any(nzchar(values))) return(NULL)
  values[!nzchar(values)] <- levels[!nzchar(values)]
  as.call(c(quote(c), stats::setNames(as.list(values), levels)))
}

# The two values a pair of quantiles comes to, in the data the model was fitted
# to, or NULL where there are no two of them.
#
# They are rounded to four figures for the same reason the two ends of the
# exposure are: the code the app writes says `at = c(4.102, 38.72)` rather than
# carrying fifteen decimals of a number that is only there to say where the
# quartile fell, and four figures is closer to it than any two people would fit
# a model to. The numbers themselves are written into the call rather than a
# quantile() of the data, so the code says which two values were compared
# without needing the data frame to be found again to say it.
#
# A probability outside [0, 1] is not one, and two quantiles that come to the
# same value -- as they do for a variable that is mostly one number -- are not a
# comparison; both are left to fall back on the plain one unit rather than drawn
# as an estimate of nothing.
fy_app_quantile_values <- function(info, exposure, probs) {
  probs <- suppressWarnings(as.numeric(probs))
  if (length(probs) != 2L || any(!is.finite(probs)) ||
      any(probs < 0) || any(probs > 1)) {
    return(NULL)
  }
  x <- tryCatch(fy_variable(info, exposure), error = function(e) NULL)
  x <- suppressWarnings(as.numeric(x))
  x <- x[is.finite(x)]
  if (length(x) < 2L) {
    return(NULL)
  }
  at <- signif(unname(stats::quantile(x, probs = probs, na.rm = TRUE)), 4)
  if (!all(is.finite(at)) || at[[1L]] == at[[2L]]) {
    return(NULL)
  }
  at
}

# The exposure the figure is of, said under its title.
#
# A figure carries its exposure in the title it writes for itself, but a title
# can be replaced, shortened by a journal style or left off, and a reader
# looking at a screen of figures needs to know which is which. So the app says
# it once more, as a subtitle, in the words the figure itself uses -- "no2 (per
# IQR, 8.44)" -- rather than in words of its own.
#
# It is a line a figure of one exposure does not always want, since the title
# and the rows name that exposure already, so it can be turned off on its own;
# a figure with no title at all has nowhere for it to go and never carries it.
fy_app_subtitle <- function(exposure, input, ctx) {
  if (isTRUE(input$no_title) || isTRUE(input$no_subtitle)) {
    return(NULL)
  }
  paste0("Exposure: ", fy_app_exposure_label(exposure, input, ctx))
}

# The exposure as the figure names it, the comparison behind it included --
# "no2 (per IQR, 8.44)", "no2 (4.102 -> 38.72)" -- taken from the package
# rather than written again here.
fy_app_exposure_label <- function(exposure, input, ctx) {
  args <- fy_app_contrast_args(input, exposure, ctx)
  tryCatch(
    fy_exposure_display(
      ctx$info, exposure,
      contrast = args$contrast,
      at = if (is.null(args$at)) NULL else c(args$at[[2L]], args$at[[3L]]),
      labels = fy_app_label_of(input, exposure, ctx)
    ),
    error = function(e) exposure
  )
}

# The call the combined figure comes to. The figures were drawn one at a time
# and the layout was theirs; foresty_combine() draws a new figure and so needs
# to be told the same thing again, or the style chosen in the sidebar would be
# lost the moment two figures were put together.
#
# The subtitle it can be told only where the figures are of one exposure. Where
# they are of several, foresty_combine() returns a figure apiece and one
# subtitle would be wrong on all but one of them.
fy_app_combine_call <- function(object_names, input, ctx, pairs) {
  exposures <- vapply(pairs, function(p) p$exposure, character(1))
  wanted <- unique(exposures)

  # One call per exposure rather than one call for all of them. What
  # foresty_combine() would do with several exposures is exactly this -- a
  # figure apiece, since rows of different exposures are not read against each
  # other -- and doing it here means each of them can be drawn in that
  # exposure's colour and told which exposure it is of.
  one <- function(exposure) {
    here <- object_names[exposures == exposure]
    if (length(here) == 1L) {
      return(as.name(here))
    }
    args <- c(lapply(here, as.name),
              fy_app_figure_args(input, fy_app_colour(input, exposure, ctx)))
    subtitle <- fy_app_subtitle(exposure, input, ctx)
    if (!is.null(subtitle)) args$subtitle <- subtitle
    as.call(c(quote(foresty_combine), args))
  }

  if (length(wanted) == 1L) {
    return(one(wanted))
  }
  as.call(c(quote(list), stats::setNames(lapply(wanted, one), wanted)))
}

# The colour this exposure is drawn in, or NULL for the style's own.
#
# A figure whose rows carry colours of their own has no one colour to be drawn
# in, so the choice made per exposure is left out of the call rather than
# written into it and then overridden.
fy_app_colour <- function(input, exposure, ctx) {
  id <- ctx$variables$ids[[exposure]]
  if (is.null(id) || !identical(input$colour_by %||% "none", "none")) {
    return(NULL)
  }
  colour <- input[[paste0("colour_", id)]]
  if (is.null(colour) || !nzchar(colour)) {
    return(NULL)
  }
  if (identical(colour, "hex")) {
    # A code half typed is not a colour yet, and is left as though nothing had
    # been chosen rather than drawn as an error.
    typed <- fy_app_hex(input[[paste0("colour_hex_", id)]])
    return(if (length(typed)) typed[[1L]] else NULL)
  }
  colour
}

# What the rows are coloured by, as the arguments that say it: the palette by
# name, so that the code carries the name a reader knows rather than eight hex
# codes, or the codes themselves where those were typed instead.
fy_app_colour_by_args <- function(input) {
  colour_by <- input$colour_by %||% "none"
  if (identical(colour_by, "none")) {
    return(list())
  }
  typed <- fy_app_hex(input$colours_hex)
  colours <- if (!length(typed)) {
    input$palette %||% "Dark2"
  } else if (length(typed) == 1L) {
    typed
  } else {
    as.call(c(quote(c), as.list(typed)))
  }
  list(colour_by = colour_by, colours = colours)
}

# What the sidebar says about how a figure looks, as arguments shared by the
# calls that draw one. The layout is the one part of it that can differ between
# the figures of one screen, since the colour belongs to the exposure.
fy_app_figure_args <- function(input, colour = NULL) {
  args <- c(fy_app_table_args(input), fy_app_naming_args(input))
  layout <- fy_app_layout_call(input, colour)
  if (!is.null(layout)) args$layout <- layout
  c(args, fy_app_title_args(input))
}

fy_app_table_args <- function(input) {
  args <- list()
  if (!isTRUE(input$table)) args$table <- FALSE
  if (length(input$columns)) {
    args$columns <- as.call(c(quote(c), as.list(input$columns)))
  }
  args
}

# What the figure calls the outcome and the axis, and the unit its person-time
# is counted in. All three belong to the whole figure rather than to one
# exposure, and each is left out of the call where the box beside it was left
# alone.
fy_app_naming_args <- function(input) {
  args <- list()
  if (nzchar(trimws(input$outcome %||% ""))) {
    args$outcome <- trimws(input$outcome)
  }
  if (nzchar(trimws(input$xlab %||% ""))) {
    args$xlab <- trimws(input$xlab)
  }
  if (!fy_app_same(input$person_time, 1)) {
    args$person_time <- fy_app_number(input$person_time, 1)
  }
  args
}

fy_app_title_args <- function(input) {
  if (isTRUE(input$no_title)) {
    return(list(title = NA))
  }
  if (nzchar(input$title %||% "")) {
    return(list(title = input$title))
  }
  list()
}

# The layout as the shortest thing that says it: nothing at all where every
# control is where the package left it, the name of a style where that is the
# only thing that moved, and a foresty_layout() call where more did.
fy_app_layout_call <- function(input, colour = NULL) {
  style <- input$style %||% "classic"
  args <- list()
  if (!is.null(input$base_size) && !is.na(input$base_size)) {
    args$base_size <- input$base_size
  }
  if (!is.null(colour) && nzchar(colour)) args$colour <- colour
  args <- c(args, fy_app_colour_by_args(input))
  if (!fy_app_same(input$digits, 2)) args$digits <- input$digits
  if (isTRUE(input$use_xlim)) {
    args$xlim <- call("c", input$xlim_low, input$xlim_high)
  }

  if (!length(args)) {
    return(if (identical(style, "classic")) NULL else style)
  }
  as.call(c(quote(foresty_layout), list(style), args))
}

# Two numbers are the same for the purpose of leaving an argument out of the
# call, an empty numericInput being NULL rather than its default.
fy_app_same <- function(x, default) {
  if (is.null(x) || length(x) != 1L || is.na(x)) {
    return(TRUE)
  }
  isTRUE(all.equal(as.numeric(x), default))
}

fy_app_number <- function(x, default) {
  if (is.null(x) || length(x) != 1L || is.na(x)) default else as.numeric(x)
}

# The script -----------------------------------------------------------------

# The whole of what the app is doing, as a script.
#
# One pair is one call, since a loop over one thing is a way of saying it
# twice. Several are a list of the pairs and a loop over it: what varies from
# figure to figure -- the exposure, the modifier, the difference the estimate
# is for -- is in the list, and everything they have in common is written once,
# so that a seventh figure is a line added to the list rather than a call
# copied and edited. do.call() is what lets one loop cover pairs that differ in
# which arguments they carry at all.
fy_app_script <- function(pairs, input, ctx) {
  if (!length(pairs)) {
    return("")
  }
  if (length(pairs) == 1L) {
    return(paste(deparse(fy_app_call(pairs[[1L]], input, ctx)), collapse = "\n"))
  }

  fit_symbol <- ctx$fit_name
  with_modifier <- vapply(pairs, function(p) !is.null(p$modifier), logical(1))
  # A colour belongs to an exposure, so where one has been chosen the layout is
  # part of what varies between the figures and moves into the list with them.
  coloured <- any(vapply(pairs, function(p) {
    !is.null(fy_app_colour(input, p$exposure, ctx))
  }, logical(1)))
  shared <- fy_app_shared_args(input, ctx, coloured)

  main <- paste0("do.call(foresty_main, c(list(list(", fit_symbol,
                 ")), spec", shared$main, "))")
  interaction <- paste0("do.call(foresty_interaction, c(list(", fit_symbol,
                        "), spec", shared$interaction, "))")

  body <- if (all(with_modifier)) {
    fy_app_indent(interaction, 2L)
  } else if (!any(with_modifier)) {
    fy_app_indent(main, 2L)
  } else {
    c("  if (is.null(spec$interaction)) {",
      fy_app_indent(main, 4L),
      "  } else {",
      fy_app_indent(interaction, 4L),
      "  }")
  }

  naming <- if (all(with_modifier)) {
    "  paste0(spec$exposure, \" by \", spec$interaction)"
  } else if (!any(with_modifier)) {
    "  paste0(spec$exposure, \", overall\")"
  } else {
    c("  if (is.null(spec$interaction)) {",
      "    paste0(spec$exposure, \", overall\")",
      "  } else {",
      "    paste0(spec$exposure, \" by \", spec$interaction)",
      "  }")
  }

  lines <- c(
    fy_app_specs_lines(pairs, input, ctx, coloured),
    "",
    "figures <- lapply(specs, function(spec) {",
    body,
    "})",
    "names(figures) <- vapply(specs, function(spec) {",
    naming,
    "}, character(1))"
  )

  if (isTRUE(input$combine)) {
    lines <- c(lines, "", fy_app_combine_lines(pairs, input, ctx))
  }
  paste(lines, collapse = "\n")
}

# The combining, as the calls it is: one per exposure, since figures of
# different exposures are not put together. Each of them names the figures it
# is of by their place in the list, which is where a reader can find them.
fy_app_combine_lines <- function(pairs, input, ctx) {
  exposures <- vapply(pairs, function(p) p$exposure, character(1))
  wanted <- unique(exposures)

  one <- function(exposure, indent) {
    at <- which(exposures == exposure)
    args <- fy_app_figure_args(input, fy_app_colour(input, exposure, ctx))
    subtitle <- fy_app_subtitle(exposure, input, ctx)
    if (!is.null(subtitle)) args$subtitle <- subtitle
    if (length(at) == 1L) {
      return(fy_app_indent(paste0("figures[[", at, "]]"), indent))
    }
    figures <- if (length(at) == length(exposures)) {
      "unname(figures)"
    } else {
      paste0("unname(figures[c(", paste(at, collapse = ", "), ")])")
    }
    if (!length(args)) {
      return(fy_app_indent(paste0("do.call(foresty_combine, ", figures, ")"),
                           indent))
    }
    c(fy_app_indent(paste0("do.call(foresty_combine, c(", figures, ","), indent),
      fy_app_wrapped(as.call(c(quote(list), args)), indent + 2L),
      fy_app_indent("))", indent))
  }

  if (length(wanted) == 1L) {
    out <- one(wanted, 0L)
    out[1L] <- paste0("combined <- ", out[1L])
    return(out)
  }
  parts <- lapply(wanted, function(exposure) {
    lines <- one(exposure, 2L)
    lines[1L] <- paste0("  `", exposure, "` = ", trimws(lines[1L], "left"))
    lines
  })
  # A comma after every group but the last.
  parts <- lapply(seq_along(parts), function(i) {
    if (i == length(parts)) {
      return(parts[[i]])
    }
    n <- length(parts[[i]])
    parts[[i]][n] <- paste0(parts[[i]][n], ",")
    parts[[i]]
  })
  c("combined <- list(", unlist(parts, use.names = FALSE), ")")
}

# What every figure of the loop is drawn with, as the tail of a do.call().
# foresty_main() has no `test`, so the two branches do not share quite the same
# arguments.
fy_app_shared_args <- function(input, ctx, coloured = FALSE) {
  common <- list()
  if (!is.null(ctx$measure)) common$measure <- ctx$measure
  if (identical(input$scale, "log")) common$exponentiate <- FALSE
  if (!fy_app_same(input$ci_level, 0.95)) common$ci_level <- input$ci_level
  common <- c(common, if (coloured) {
    c(fy_app_table_args(input), fy_app_naming_args(input))
  } else {
    fy_app_figure_args(input)
  })
  if (coloured) {
    common <- c(common, fy_app_title_args(input))
  }

  test <- list()
  if (!identical(input$test %||% "lrt", "lrt")) test$test <- input$test

  written <- function(args) {
    if (!length(args)) {
      return("")
    }
    paste0(", ", fy_app_deparse1(as.call(c(quote(list), args))))
  }
  list(main = written(common), interaction = written(c(test, common)))
}

# The pairs, as the list the loop runs over: what changes from figure to
# figure and nothing else.
fy_app_specs_lines <- function(pairs, input, ctx, coloured = FALSE) {
  items <- vapply(pairs, function(pair) {
    args <- list(exposure = fy_app_exposure_arg(input, pair$exposure, ctx))
    if (!is.null(pair$modifier)) {
      args$interaction <- fy_app_modifier_arg(input, pair$modifier, ctx)
    }
  args <- c(args, fy_app_contrast_args(input, pair$exposure, ctx))
  if (!is.null(pair$modifier)) {
    level_labels <- fy_app_level_labels_arg(input, pair$modifier, ctx)
    if (!is.null(level_labels)) args$level_labels <- level_labels
  }
    subtitle <- fy_app_subtitle(pair$exposure, input, ctx)
    if (!is.null(subtitle)) {
      args$subtitle <- subtitle
    }
    if (coloured) {
      layout <- fy_app_layout_call(input, fy_app_colour(input, pair$exposure, ctx))
      if (!is.null(layout)) {
        args$layout <- layout
      }
    }
    paste0("  ", fy_app_deparse1(as.call(c(quote(list), args))))
  }, character(1))
  c("specs <- list(", paste0(items, c(rep(",", length(items) - 1L), "")), ")")
}

fy_app_indent <- function(lines, spaces) {
  # A blank line is left blank rather than being padded out to a line of
  # spaces, which is what a line of code between two blocks of code is.
  ifelse(nzchar(lines), paste0(strrep(" ", spaces), lines), lines)
}

# A call written where it will sit some way in from the margin. deparse() wraps
# to a width it measures from the left of the call, so the width it is given is
# short by however far the call has been pushed across.
fy_app_wrapped <- function(x, indent) {
  fy_app_indent(deparse(x, width.cutoff = max(20L, 78L - indent)), indent)
}

fy_app_deparse1 <- function(x) {
  paste(deparse(x, width.cutoff = 500L), collapse = " ")
}

# Drawing --------------------------------------------------------------------

# Evaluate one of the app's calls, keeping what it said while it worked.
#
# The objects the call names are put in an environment of their own, so that a
# call mentioning `my_fit` or `fig_no2_by_sex` is the call a reader can paste
# into a script beside those objects.
fy_app_evaluate <- function(call, objects) {
  env <- new.env(parent = environment())
  for (nm in names(objects)) {
    assign(nm, objects[[nm]], envir = env)
  }

  notes <- character(0)
  out <- tryCatch(
    withCallingHandlers(
      list(value = eval(call, envir = env), error = NULL),
      message = function(m) {
        notes <<- c(notes, sub("\n$", "", conditionMessage(m)))
        invokeRestart("muffleMessage")
      }
    ),
    error = function(e) list(value = NULL, error = conditionMessage(e))
  )
  out$notes <- notes
  out$call <- call
  out
}

# A figure, or the several that foresty_combine() returns when the exposures
# differ, as a named list of figures to draw.
fy_app_as_list <- function(x, single_name) {
  # A figure is a ggplot and a ggplot is a list, so what it is comes first.
  if (inherits(x, "foresty")) {
    return(stats::setNames(list(x), single_name))
  }
  if (is.list(x)) {
    out <- unclass(x)
    if (is.null(names(out))) {
      names(out) <- paste(single_name, seq_along(out))
    }
    return(out)
  }
  stats::setNames(list(x), single_name)
}

# A figure as the plot it is, without the class that carries its estimates:
# patchwork is being asked to stack these, and what it hands back would carry
# the attribute of whichever figure it took it from.
fy_app_plain <- function(x) {
  class(x) <- setdiff(class(x), "foresty")
  attr(x, "foresty") <- NULL
  x
}

# What was fitted, and how the numbers were arrived at ------------------------

# The summary tab: the model you fitted, and every model the app fitted from it.
#
# The overall figure comes from the first and each subgroup figure from one of
# the others, and the difference between them is the whole of what a subgroup
# analysis is, so both are here rather than only the one you typed.
fy_app_summaries <- function(fit, fit_name, states, input = NULL, ctx = NULL) {
  cat(strrep("=", 72), "\n", sep = "")
  cat("THE MODEL YOU FITTED -- no interaction term\n")
  cat("The overall effect, where it is drawn, is drawn from this one.\n")
  cat(strrep("=", 72), "\n", sep = "")
  fy_app_say_facts(NULL, input, ctx)
  cat("\n")
  print(summary(fit))

  seen <- character(0)
  for (state in states) {
    if (is.null(state$value) || is.null(state$pair$modifier)) {
      next
    }
    formula <- fy_app_formula_text(fy_infos(state$value)[[1L]]$fit)
    if (formula %in% seen) {
      next
    }
    seen <- c(seen, formula)
    cat("\n\n", strrep("=", 72), "\n", sep = "")
    cat("WITH THE ", state$pair$exposure, " BY ", state$pair$modifier,
        " INTERACTION TERM\n", sep = "")
    cat("The subgroup effects of ", state$pair$exposure,
        " are drawn from this one.\n", sep = "")
    cat(strrep("=", 72), "\n", sep = "")
    fy_app_say_facts(state, input, ctx)
    cat("\n")
    print(summary(fy_infos(state$value)[[1L]]$fit))
  }
  invisible(NULL)
}

# What the figure under a heading is of, said in the three things a reader has
# to know to read it: what the estimate is an estimate of, what it is the
# effect of, and what it was split by. A summary of a model says none of them
# -- a coefficient table is a list of terms -- and neither does a block of code,
# so they are written above both.
fy_app_say_facts <- function(state, input, ctx, indent = "  ") {
  if (is.null(ctx)) {
    return(invisible(NULL))
  }
  exposure <- if (is.null(state)) NULL else state$pair$exposure
  said <- if (is.null(exposure)) {
    "every exposure drawn, one figure apiece"
  } else {
    fy_app_exposure_label(exposure, input, ctx)
  }
  modifier <- if (is.null(state)) {
    "none -- this model carries no interaction term"
  } else if (is.null(state$pair$modifier)) {
    "none -- the overall effect"
  } else {
    state$pair$modifier
  }
  cat(indent, "Outcome:         ", ctx$info$outcome %||% "not named", "\n",
      sep = "")
  cat(indent, "Exposure:        ", said, "\n", sep = "")
  cat(indent, "Effect modifier: ", modifier, "\n", sep = "")
  invisible(NULL)
}

# The Models tab: what foresty did, written out as the R it amounts to.
#
# A subgroup analysis is read differently depending on which model it came out
# of and how the subgroup effects were taken from it, and neither of those is
# visible in the figure. The code here is not run -- the app runs foresty --
# but it is what foresty runs, named for your variables, so that a reader can
# check the analysis rather than take it on trust.
fy_app_model_report <- function(fit, fit_name, states, input, ctx) {
  base_terms <- fy_app_term_labels(fit)

  cat(strrep("=", 72), "\n", sep = "")
  cat("THE MODEL YOU FITTED -- no interaction term\n")
  cat(strrep("=", 72), "\n\n", sep = "")
  # What the model is, in the words a methods section uses. The classes of the
  # object it is held in -- "glm, lm" -- name the function that fitted it rather
  # than the model, and a reader checking the tab against a paper is looking for
  # "logistic regression".
  cat("  ", fy_model_name(fit), "\n\n", sep = "")
  call <- tryCatch(stats::getCall(fit), error = function(e) NULL)
  if (!is.null(call)) {
    cat("  ", fit_name, " <- ",
        paste(deparse(call),
              collapse = paste0("\n", strrep(" ", nchar(fit_name) + 6L))),
        "\n\n", sep = "")
  }
  cat("  Outcome: ", ctx$info$outcome %||% "not named", "\n", sep = "")
  cat("  Formula: ", fy_app_formula_text(fit), "\n\n", sep = "")

  if (!length(states)) {
    cat("Choose an exposure to see how its figure would be arrived at.\n")
    return(invisible(NULL))
  }

  for (state in states) {
    # The model this section's figure came out of, which is the one that was
    # fitted where the section is a subgroup analysis and yours where it is not.
    # A section that could not be drawn has none, and falls back on yours.
    section_fit <- if (is.null(state$value)) {
      fit
    } else {
      fy_infos(state$value)[[1L]]$fit
    }
    cat(strrep("-", 72), "\n", sep = "")
    cat(toupper(state$label), "\n", sep = "")
    cat(strrep("-", 72), "\n", sep = "")
    cat("  ", fy_model_name(section_fit), "\n\n", sep = "")
    fy_app_say_facts(state, input, ctx)
    # The formula of that model, section by section, since it is the one thing
    # that tells a subgroup section apart from the one above it.
    cat("  Formula:         ", fy_app_formula_text(section_fit), "\n", sep = "")
    cat("\n")
    if (is.null(state$value)) {
      cat("  Not drawn: ", state$error, "\n\n", sep = "")
      next
    }
    if (is.null(state$pair$modifier)) {
      fy_app_report_overall(state, fit_name, input, ctx)
    } else {
      fy_app_report_interaction(state, fit, fit_name, base_terms, input, ctx)
    }
  }

  cat(strrep("=", 72), "\n", sep = "")
  cat("A note on the code above\n")
  cat(strrep("=", 72), "\n\n", sep = "")
  cat("  It is meant to be run. It is what foresty ran, named for your model\n")
  cat("  and your variables: the same two rows of data, the same design\n")
  cat("  matrix, the same coefficients and covariance, the same degrees of\n")
  cat("  freedom and the same test, so that pasting it beside the model\n")
  cat("  reproduces the numbers on the figure rather than something close to\n")
  cat("  them.\n\n")
  cat("  It calls car::linearHypothesis.default() rather than\n")
  cat("  car::linearHypothesis(), and passes the hypothesis as a numeric\n")
  cat("  matrix rather than as a character formula. The method a fit would\n")
  cat("  dispatch to has its own idea of which coefficients, which covariance\n")
  cat("  and how many degrees of freedom to use, and would quietly use the\n")
  cat("  model's own where a robust variance was asked for; and a coefficient\n")
  cat("  may be named anything a fitting function likes, which car's formula\n")
  cat("  parser reads only some of.\n")
  invisible(NULL)
}

# The overall effect: the code it is, and nothing about it.
#
# What the code does is what the code says -- two rows of the design matrix
# differing in the exposure alone, a linear combination of the coefficients,
# a Wald test of it -- and a paragraph saying the same thing above it is read
# once and skipped every time after.
fy_app_report_overall <- function(state, fit_name, input, ctx) {
  result <- fy_result(state$value)
  exposure <- result$exposure
  info <- fy_infos(state$value)[[1L]]
  compared <- fy_app_compared(exposure, input, ctx)

  fy_app_say_code(fy_app_lincom_code(info, fit_name, exposure, compared), 6L)
}

fy_app_report_interaction <- function(state, fit, fit_name, base_terms, input,
                                      ctx) {
  result <- fy_result(state$value)
  exposure <- result$exposure
  modifier <- result$modifier
  info <- fy_infos(state$value)[[1L]]
  added <- setdiff(fy_app_term_labels(info$fit), base_terms)
  levels <- unique(as.character(result$estimates$modifier_level))
  compared <- fy_app_compared(exposure, input, ctx)
  int_name <- paste0(fit_name, "_int")

  cat("  1. The interaction term\n\n")
  if (length(added)) {
    cat("       ", int_name, " <- update(", fit_name, ", . ~ . + ",
        paste(added, collapse = " + "), ")\n\n", sep = "")
  } else {
    cat("       ", int_name, " <- ", fit_name,
        "   # your model carries it already\n\n", sep = "")
  }

  cat("  2. One estimate per subgroup, from that one model\n\n")
  fy_app_say_code(
    fy_app_lincom_code(info, int_name, exposure, compared, modifier = modifier,
                       levels = levels),
    7L
  )

  cat("  3. The p-value for the interaction\n\n")
  columns <- tryCatch(
    fy_modifier_interaction_columns(info, exposure, modifier),
    error = function(e) character(0)
  )
  tests <- result$interaction_tests %||% list(result$interaction_test)
  taken <- vapply(tests, function(t) t$test %||% "", character(1))

  if (any(grepl("[Ll]ikelihood", taken))) {
    fy_app_say_code(fy_app_lrt_code(int_name, added, exposure, modifier), 7L)
  }
  if (any(grepl("Wald|F$", taken))) {
    fy_app_say_code(fy_app_joint_code(info, int_name, columns), 7L)
  }
  if (length(columns)) {
    cat("     Coefficients tested: ", paste(columns, collapse = ", "), "\n",
        sep = "")
  }
  for (test in tests) {
    if (is.null(test)) next
    cat("     Reported here:       ", test$test, " = ",
        fy_format_number(test$statistic), " on ", test$df, " df, p = ",
        fy_format_p(test$p.value), "\n", sep = "")
  }
  cat("\n")
}

# The code behind an estimate ------------------------------------------------

# What the Models tab writes out is meant to be run.
#
# It is not a description of what foresty does but the thing itself, named for
# this model and these variables: the same two rows of data, the same design
# matrix built the way the fitting function built its own, the same coefficient
# vector and covariance, the same error degrees of freedom and the same test.
# Pasting it into a script beside the model reproduces the number beside it
# rather than something close to it, which is what makes it worth reading.
#
# That is why it says `car::linearHypothesis.default()` and not
# `car::linearHypothesis()`: the method a fit dispatches to takes the model's
# own coefficients, covariance and degrees of freedom, which are not the ones
# the figure was drawn from where a robust variance was asked for. The
# hypothesis is a numeric matrix rather than a character formula for a related
# reason -- a coefficient may be named anything, and car's parser reads only
# some of those.
fy_app_say_code <- function(lines, indent) {
  pad <- strrep(" ", indent)
  cat(paste0(ifelse(nzchar(lines), paste0(pad, lines), ""), collapse = "\n"),
      "\n\n", sep = "")
  invisible(NULL)
}

# One estimate: the two rows, the design matrix, the contrast and the test.
# `modifier` wraps the last three of them in the function foresty runs once per
# subgroup, with the modifier held at that level in both rows.
fy_app_lincom_code <- function(info, fit_name, exposure, compared,
                               modifier = NULL, levels = NULL,
                               level_values = NULL) {
  design <- c(fy_app_design_lines(info, fit_name), "L <- X[2, ] - X[1, ]")
  test <- fy_app_test_lines(info, fit_name)
  head <- c(fy_app_rows_lines(info, fit_name, exposure, compared), "",
            fy_app_coef_lines(info, fit_name), "")

  if (is.null(modifier)) {
    return(c(head, design, "", test))
  }
  c(head,
    "within <- function(level) {",
    paste0("  rows$", modifier, " <- level"),
    fy_app_indent(c(design, "", test), 2L),
    "}",
    paste0("lapply(c(", level_values %||% fy_app_level_values(info, modifier,
                                                              levels),
           "), within)"))
}

# The levels of the modifier as the code has to write them: the numbers
# themselves for a flag coded 0 and 1, and quoted for a factor. A level put
# back into the data as a string of the wrong type is a column of the wrong
# type, and the design matrix built from it is not the model's.
fy_app_level_values <- function(info, modifier, levels) {
  x <- tryCatch(fy_variable(info, modifier), error = function(e) NULL)
  if (!is.null(x) && is.numeric(x)) {
    return(paste(levels, collapse = ", "))
  }
  paste0("\"", levels, "\"", collapse = ", ")
}

# The two rows the contrast is the difference between: one complete observation
# of the data, twice, with the exposure moved between them.
#
# The row is named as foresty named it. The source data is preferred over the
# model frame, since a model frame holds a splined variable as its basis matrix
# and setting the variable on such a row would change nothing.
fy_app_rows_lines <- function(info, fit_name, exposure, compared) {
  where <- tryCatch(fy_reference_index(info), error = function(e) NULL)
  data_name <- fy_app_data_name(info$fit)
  taken <- if (is.null(where)) {
    paste0("model.frame(", fit_name, ")[c(1, 1), ]")
  } else if (where$from_data && !is.null(data_name)) {
    paste0(data_name, "[c(", where$index, ", ", where$index, "), ]")
  } else {
    paste0("model.frame(", fit_name, ")[c(", where$index, ", ", where$index,
           "), ]")
  }
  c(paste0("rows <- ", taken,
           "   # one complete observation, twice"),
    paste0("rows$", exposure, " <- c(", compared$from, ", ", compared$to, ")",
           compared$said))
}

# The name the model's own call knows its data by, so that the code names the
# data frame the reader has rather than a copy of it.
fy_app_data_name <- function(fit) {
  call <- tryCatch(stats::getCall(fit), error = function(e) NULL)
  if (is.null(call) || is.null(call$data) || !is.name(call$data)) {
    return(NULL)
  }
  as.character(call$data)
}

# The design matrix of those two rows, built as the fitting function builds its
# own.
#
# That means going back through model.frame() with the levels and the contrast
# coding the model was fitted under, so that the `predvars` of the terms object
# are used and a basis such as ns(no2, 3) or poly(maternal_age, 2) is reproduced
# with the knots and the centring it was fitted with rather than recomputed from
# two rows.
fy_app_design_lines <- function(info, fit_name) {
  aliased <- length(info$kept) < info$n_full
  out <- c(
    paste0("tt <- delete.response(terms(", fit_name, "))"),
    paste0("mf <- model.frame(tt, data = rows, xlev = ", fit_name,
           "$xlevels,"),
    "                  na.action = na.pass)",
    paste0("X  <- model.matrix(tt, data = mf, contrasts.arg = ", fit_name,
           "$contrasts)")
  )
  if (aliased) {
    out <- c(out, "X  <- X[, names(b), drop = FALSE]")
  }
  out
}

# The coefficients and the covariance the test is taken over. An aliased
# coefficient is NA and has no column in vcov(), so it is dropped from both and
# from the design matrix with them, which is what keeps the three lined up.
fy_app_coef_lines <- function(info, fit_name) {
  if (length(info$kept) < info$n_full) {
    return(c(
      paste0("b <- coef(", fit_name, ")"),
      "b <- b[!is.na(b)]   # this model has aliased coefficients",
      paste0("V <- vcov(", fit_name, ")[names(b), names(b), drop = FALSE]")
    ))
  }
  c(paste0("b <- coef(", fit_name, ")"),
    paste0("V <- vcov(", fit_name, ")",
           if (isTRUE(info$robust)) "   # already robust" else ""))
}

# The test itself, at the degrees of freedom foresty worked out: the residual
# degrees of freedom for a gaussian model, which is reported with t and F, and
# infinite for everything else, which is reported with the normal approximation
# and a Wald chi-square.
fy_app_test_lines <- function(info, fit_name, hypothesis = "L") {
  test <- if (is.finite(info$error_df)) "F" else "Chisq"
  df <- if (is.finite(info$error_df)) fy_trim_number(info$error_df) else "Inf"
  pad <- strrep(" ", nchar("car::linearHypothesis.default("))
  c(paste0("car::linearHypothesis.default(", fit_name, ", ", hypothesis,
           ", coef. = b, vcov. = V,"),
    paste0(pad, "error.df = ", df, ", test = \"", test, "\","),
    paste0(pad, "singular.ok = TRUE)"),
    "# The estimate is attr(., \"value\") of that and its standard error the",
    "# square root of attr(., \"vcov\"); the interval is formed from the two of",
    "# them at the confidence level you chose.")
}

# The joint test of the interaction coefficients: the rows of the identity
# matrix belonging to them, which is the hypothesis that every one of them is
# zero. Built by name rather than by position, since that is the only thing
# that survives an aliased coefficient.
fy_app_joint_code <- function(info, fit_name, columns) {
  c(fy_app_coef_lines(info, fit_name),
    paste0("columns <- c(", paste0("\"", columns, "\"", collapse = ", "), ")"),
    "L <- matrix(0, length(columns), length(b),",
    "            dimnames = list(columns, names(b)))",
    "L[cbind(seq_along(columns), match(columns, names(b)))] <- 1",
    "",
    fy_app_test_lines(info, fit_name)[1:3])
}

# The likelihood ratio test, as the arithmetic foresty does rather than as the
# anova() that comes to the same thing: twice the difference in log-likelihood,
# on the parameters the interaction spent.
fy_app_lrt_code <- function(fit_name, added, exposure, modifier) {
  terms <- paste(added %||% paste0(exposure, ":", modifier), collapse = " - ")
  c(paste0("reduced <- update(", fit_name, ", . ~ . - ", terms, ")"),
    "",
    paste0("statistic <- 2 * (as.numeric(logLik(", fit_name,
           ")) - as.numeric(logLik(reduced)))"),
    paste0("df <- attr(logLik(", fit_name,
           "), \"df\") - attr(logLik(reduced), \"df\")"),
    "pchisq(statistic, df = df, lower.tail = FALSE)",
    "",
    paste0("# anova(reduced, ", fit_name,
           ", test = \"LRT\") is the same test, said"),
    "# in one line. A REML-fitted lme4 model is refitted with maximum",
    "# likelihood first, since two REML likelihoods of different fixed",
    "# effects are not comparable.")
}

# The two values of the exposure the estimates are the difference between, for
# the code the Models tab writes out. They are the package's own, taken from
# the same function the figure took them from.
fy_app_compared <- function(exposure, input, ctx) {
  args <- fy_app_contrast_args(input, exposure, ctx)
  values <- tryCatch(
    fy_exposure_values(
      ctx$info, exposure,
      contrast = args$contrast,
      at = if (is.null(args$at)) NULL else c(args$at[[2L]], args$at[[3L]])
    ),
    error = function(e) NULL
  )
  if (is.null(values)) {
    return(list(from = "from", to = "to", said = ""))
  }
  first <- values[[length(values)]]
  said <- first$contrast_label %||% NA_character_
  list(
    from = fy_app_value_text(first$from),
    to = fy_app_value_text(first$to),
    said = if (is.na(said)) "" else paste0("   # ", said)
  )
}

fy_app_value_text <- function(x) {
  if (is.factor(x) || is.character(x)) {
    paste0("\"", as.character(x), "\"")
  } else {
    fy_trim_number(round(as.numeric(x), 4))
  }
}

fy_app_term_labels <- function(fit) {
  out <- tryCatch(attr(stats::terms(fit), "term.labels"),
                  error = function(e) character(0))
  if (is.null(out)) character(0) else out
}

fy_app_formula_text <- function(fit) {
  out <- tryCatch(paste(deparse(stats::formula(fit)), collapse = " "),
                  error = function(e) "not available")
  gsub("\\s+", " ", out)
}

# Writing files --------------------------------------------------------------

# The figures on the screen, into a file.
#
# PNG through ragg where it is installed, since text at 300 dpi is what the
# journals ask for and what ragg draws is what the screen showed. SVG through
# svglite where it is installed and through the graphics device R was built
# with otherwise, so that the text stays text and the figure can be edited.
fy_app_save <- function(figures, file, format, input) {
  if (!length(figures)) {
    stop("there is no figure to save", call. = FALSE)
  }
  width <- fy_app_number(input$width, 10)
  height <- fy_app_number(input$height, 6) * length(figures)
  plot <- if (length(figures) == 1L) {
    fy_app_plain(figures[[1L]])
  } else {
    patchwork::wrap_plots(lapply(figures, fy_app_plain), ncol = 1)
  }

  if (identical(format, "png")) {
    dpi <- fy_app_number(input$dpi, 300)
    if (requireNamespace("ragg", quietly = TRUE)) {
      ragg::agg_png(file, width = width, height = height, units = "in",
                    res = dpi, background = "white")
    } else {
      grDevices::png(file, width = width, height = height, units = "in",
                     res = dpi, bg = "white")
    }
  } else if (requireNamespace("svglite", quietly = TRUE)) {
    svglite::svglite(file, width = width, height = height, bg = "white")
  } else {
    if (!isTRUE(capabilities("cairo"))) {
      stop(
        "this build of R cannot write SVG. Install the svglite package with ",
        "install.packages(\"svglite\"), or download the figure as PNG.",
        call. = FALSE
      )
    }
    grDevices::svg(file, width = width, height = height, bg = "white")
  }
  on.exit(grDevices::dev.off(), add = TRUE)
  print(plot)
  invisible(file)
}

# Several figures are several files, since figures that were not combined were
# not combined for a reason and stacking them into one image would put them
# back together. One file goes down as it is; several go down zipped.
fy_app_save_all <- function(figures, file, format, input) {
  if (length(figures) == 1L) {
    return(fy_app_save(figures, file, format, input))
  }
  fy_app_zip(fy_app_each(figures, format, function(one, path) {
    fy_app_save(one, path, format, input)
  }), file)
}

# The figure on a report page is the figure the buttons beside it write, so it
# is drawn at the size set there rather than at a size of the report's own: a
# page whose plot is squashed into three inches is not the figure that was
# being looked at.
fy_app_write_reports <- function(figures, file, input = list()) {
  width <- fy_app_number(input$width, 10)
  height <- fy_app_number(input$height, 6)

  if (length(figures) == 1L) {
    # foresty_report() names the file itself where it was handed one that is
    # not .html, and the browser is waiting for this one.
    page <- tempfile(fileext = ".html")
    foresty_report(figures[[1L]], file = page, width = width, height = height)
    file.copy(page, file, overwrite = TRUE)
    return(invisible(file))
  }
  fy_app_zip(fy_app_each(figures, "html", function(one, path) {
    foresty_report(one[[1L]], file = path, width = width, height = height)
  }), file)
}

# One file per figure, in a directory of their own, named for the pair each of
# them is of.
fy_app_each <- function(figures, ext, write) {
  dir <- tempfile("foresty-")
  dir.create(dir, showWarnings = FALSE, recursive = TRUE)
  names <- make.unique(vapply(seq_along(figures), function(i) {
    fy_file_slug(names(figures)[i] %||% paste0("figure_", i))
  }, character(1)), sep = "_")

  vapply(seq_along(figures), function(i) {
    path <- file.path(dir, paste0(names[i], ".", ext))
    write(figures[i], path)
    path
  }, character(1))
}

fy_app_zip <- function(paths, file) {
  if (requireNamespace("zip", quietly = TRUE)) {
    zip::zipr(zipfile = file, files = paths)
    return(invisible(file))
  }
  if (!nzchar(Sys.which("zip"))) {
    stop(
      "several figures come down as several files in a zip, which needs the ",
      "zip package: install.packages(\"zip\"). Or tick \"Combine the pairs ",
      "into one figure\", which is one figure and one file.",
      call. = FALSE
    )
  }
  # utils::zip() names its files relative to the working directory.
  old <- setwd(dirname(paths[1L]))
  on.exit(setwd(old), add = TRUE)
  utils::zip(zipfile = file, files = basename(paths), flags = "-q")
  invisible(file)
}
