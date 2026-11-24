#' @title Create interactive colorsteps guide
#' @description
#' The guide is based on [ggplot2::guide_coloursteps()].
#' See the documentation for that function for more details.
#'
#' @param ... arguments passed to base function.
#' @return An interactive guide object.
#' @inheritSection interactive_parameters Details for interactive scale and interactive guide functions
#' @examples
#' # add interactive coloursteps guide to a ggplot -------
#' @examples
#' library(ggplot2)
#' library(ggiraph)
#'
#' set.seed(4393)
#' dsmall <- diamonds[sample(nrow(diamonds), 1000), ]
#' p <- ggplot(dsmall, aes(x, y)) +
#'   stat_density_2d(
#'     aes(
#'       fill = after_stat(nlevel),
#'       tooltip = paste("nlevel:", after_stat(nlevel))
#'     ),
#'     geom = "interactive_polygon"
#'   ) +
#'   facet_grid(. ~ cut)
#'
#' # add interactive binned scale, by default the guide is colorsteps
#' p1 <- p +
#'   scale_fill_viridis_b_interactive(data_id = "nlevel", tooltip = "nlevel")
#' x <- girafe(ggobj = p1)
#' @examplesIf identical(Sys.getenv("IN_PKGDOWN"), "true")
#' x
#'
#'
#' # make the title and labels interactive
#' p2 <- p +
#'   scale_fill_viridis_b_interactive(
#'     data_id = "nlevel",
#'     tooltip = "nlevel",
#'     name = label_interactive("nlevel", data_id = "nlevel", tooltip = "nlevel"),
#'     labels = function(breaks) {
#'       l <- lapply(breaks, function(br) {
#'         label_interactive(
#'           as.character(br),
#'           data_id = as.character(br),
#'           onclick = paste0("alert(\"", as.character(br), "\")"),
#'           tooltip = as.character(br)
#'         )
#'       })
#'       l
#'     }
#'   )
#' x <- girafe(ggobj = p2)
#' x <- girafe_options(
#'   x,
#'   opts_hover_key(girafe_css("stroke:red", text = "stroke:none;fill:red"))
#' )
#' x
#' @seealso [interactive_parameters], [girafe()]
#' @export
guide_coloursteps_interactive <- function(...) {
  guide_interactive(
    guide_coloursteps,
    ...,
    interactive_guide = GuideInteractiveColoursteps
  )
}

#' @export
#' @rdname guide_coloursteps_interactive
guide_colorsteps_interactive <- guide_coloursteps_interactive

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GuideInteractiveColoursteps <- ggproto(
  "GuideInteractiveColoursteps",
  GuideColoursteps,
  train = function(self, params = self$params, scale, aesthetic = NULL, ...) {
    parent <- ggproto_parent(GuideColoursteps, self)
    params <- parent$train(
      params = params,
      scale = scale,
      aesthetic = aesthetic,
      ...
    )
    if (!is.null(params) && is.data.frame(params$key) && nrow(params$key)) {
      parsed <- interactive_guide_parse_binned_breaks(scale, params)
      label_breaks <- parsed$breaks
      if (params$even.steps || !is.numeric(parsed$scale_breaks)) {
        show.limits <- params$show.limits %||% scale$show.limits %||% FALSE
        if (
          show.limits &&
            !(is.character(scale$labels) || is.numeric(scale$labels))
        ) {
          label_breaks <- parsed$all_breaks
        }
      }
      # the steps are drawn as a single raster grob: one value for the bar
      params <- interactive_guide_train(
        params,
        scale,
        breaks = 1,
        label_breaks = label_breaks
      )
    }
    params
  },
  override_elements = function(params, elements, theme) {
    elements <- GuideColoursteps$override_elements(params, elements, theme)
    interactive_guide_override_elements(elements)
  },
  build_decor = function(decor, grobs, elements, params) {
    GuideInteractiveColourbar$build_decor(decor, grobs, elements, params)
  }
)
