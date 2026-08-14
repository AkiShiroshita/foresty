#' A simulated birth cohort
#'
#' Four thousand simulated children with an air pollution exposure in infancy,
#' asthma by school age, and a time to first wheeze episode. The data are made
#' up, and are here so that the examples run without a real cohort.
#'
#' The exposure effect was simulated to be about twice as large in boys as in
#' girls, and to be the same whether or not the mother smoked, although
#' maternal smoking raises the risk of asthma on its own. The two modifiers
#' therefore show what a real interaction and an absent one look like when the
#' subgroup estimates are drawn beside the joint test.
#'
#' @format A data frame with 4,000 rows and 11 columns:
#' \describe{
#'   \item{asthma}{Asthma by school age, 1 or 0.}
#'   \item{wheeze}{First wheeze episode observed before censoring, 1 or 0.}
#'   \item{followup_years}{Years to the wheeze episode or to censoring.}
#'   \item{no2}{Nitrogen dioxide during infancy, in parts per billion.}
#'   \item{black_carbon}{Black carbon during infancy, in micrograms per cubic
#'     metre.}
#'   \item{sex}{Child's sex, `Female` or `Male`.}
#'   \item{maternal_smoking}{Smoking during pregnancy, `No` or `Yes`.}
#'   \item{maternal_asthma}{Maternal history of asthma, `No` or `Yes`.}
#'   \item{maternal_age}{Maternal age at delivery, in years.}
#'   \item{birth_year}{Year of birth, 2005 to 2014, as a factor.}
#'   \item{urbanicity}{`Rural`, `Suburban` or `Urban`. Exposure rises with it,
#'     so it confounds the comparison.}
#' }
#'
#' @source Simulated by `data-raw/foresty_cohort.R`.
"foresty_cohort"
