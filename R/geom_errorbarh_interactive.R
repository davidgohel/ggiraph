#' Create interactive horizontal error bars
#'
#' @description
#' `geom_errorbarh_interactive()` is deprecated, as [ggplot2::geom_errorbarh()]
#' since 'ggplot2' 4.0.0: use `geom_errorbar_interactive(orientation = "y")`
#' instead (see [geom_crossbar_interactive()]).
#'
#' @param ... arguments passed to [geom_errorbar_interactive()],
#' plus any of the [interactive_parameters].
#' @param orientation The orientation of the layer, `"y"` for horizontal
#' error bars.
#' @inheritSection interactive_parameters Details for interactive geom functions
#' @examples
#' # add horizontal error bars -------
#' @example examples/geom_errorbarh_interactive.R
#' @seealso [girafe()]
#' @keywords internal
#' @export
geom_errorbarh_interactive <- function(..., orientation = "y") {
  cli::cli_warn(
    c(
      "!" = "{.fn geom_errorbarh_interactive} is deprecated, as {.fn ggplot2::geom_errorbarh} since 'ggplot2' 4.0.0.",
      "i" = "Use {.code geom_errorbar_interactive(orientation = \"y\")} instead."
    ),
    .frequency = "regularly",
    .frequency_id = "ggiraph_no_more_errorbarh"
  )
  geom_errorbar_interactive(..., orientation = orientation)
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveErrorbarh <- ggproto(
  "GeomInteractiveErrorbarh",
  GeomInteractiveErrorbar
)
