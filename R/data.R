#' Sputnik 1 nested example data
#'
#' A nested list containing structured information about Sputnik 1, the first
#' artificial Earth satellite.
#'
#' The object includes historical metadata, spacecraft specifications, launch
#' information, orbital parameters, radio system details, mission objectives,
#' chronology, Cold War context, related spacecraft, source notes, and additional
#' branches designed for testing recursive list traversal.
#'
#' This dataset is useful for testing functions such as `list_map()`,
#' `list_map2()`, `list_pmap()`, and `list_imap()` because it contains:
#'
#' \itemize{
#'   \item deeply nested lists;
#'   \item named and unnamed branches;
#'   \item `NULL` leaves;
#'   \item empty lists;
#'   \item `Date` and `POSIXct` objects;
#'   \item numeric and character vectors;
#'   \item data frames that should be treated as leaf values.
#' }
#'
#' @format A nested list.
#'
#' @source
#' NASA History, Sputnik and the Dawn of the Space Age:
#' <https://www.nasa.gov/wp-content/uploads/static/history/sputnik.html>
#'
#' NASA History, Korolev, Sputnik, and the International Geophysical Year:
#' <https://www.nasa.gov/history/sputnik/siddiqi.html>
#'
#' National Museum of the United States Air Force, Sputnik I:
#' <https://www.nationalmuseum.af.mil/Visit/Museum-Exhibits/Fact-Sheets/Display/Article/197681/sputnik-i/>
#'
#' U.S. Department of State, Sputnik, 1957:
#' <https://history.state.gov/milestones/1953-1960/sputnik>
#'
#' Wikipedia, Sputnik 1:
#' <https://en.wikipedia.org/wiki/Sputnik_1>
#'
#' @examples
#' data(sputnik_1)
#'
#' names(sputnik_1)
#'
#' sputnik_1$identity$names$common
#' sputnik_1$spacecraft$physical$mass_kg
#' sputnik_1$orbit$canonical_values$period_min
#'
#' # Useful with recursive mapping:
#' # list_nleaf(sputnik_1)
#' # list_imap(sputnik_1, \(x, path) paste(path, collapse = "."), .name = "path")
#'
#' @keywords datasets
"sputnik_1"
