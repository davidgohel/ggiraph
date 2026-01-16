#' @title Create interactive quasirandom geom
#'
#' @description
#' The geometry is based on [ggbeeswarm::geom_quasirandom()].
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters].
#' @inheritSection interactive_parameters Details for interactive geom functions
#' @examples
#' # add interactive repulsive texts to a ggplot -------
#' @example examples/geom_quasirandom_interactive.R
#' @seealso [girafe()]
#' @export
geom_quasirandom_interactive <- function(...) {
  if (!requireNamespace("ggbeeswarm", quietly = TRUE)) {
    cli::cli_abort(c(
      "Package 'ggbeeswarm' is required to use geom_quasirandom_interactive.",
      "i" = "You can install it with command {.code install.packages('ggbeeswarm')}?"
    ))
  }
  layerfunc <- getExportedValue("ggbeeswarm", "geom_quasirandom")
  layer_interactive(
    layerfunc,
    ...,
    interactive_geom = GeomInteractivePoint
  )
}
