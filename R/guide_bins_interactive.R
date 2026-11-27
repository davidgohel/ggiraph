#' @title Create interactive bins guide
#' @description
#' The guide is based on [ggplot2::guide_bins()].
#' See the documentation for that function for more details.
#'
#' @param ... arguments passed to base function.
#' @return An interactive guide object.
#' @inheritSection interactive_parameters Details for interactive scale and interactive guide functions
#' @examples
#' # add interactive bins guide to a ggplot -------
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
#' # add interactive binned scale and guide
#' p1 <- p +
#'   scale_fill_viridis_b_interactive(
#'     data_id = "nlevel",
#'     tooltip = "nlevel",
#'     guide = "bins"
#'   )
#' x <- girafe(ggobj = p1)
#'
#' @examplesIf identical(Sys.getenv("IN_PKGDOWN"), "true")
#' x
#'
#' # set the keys separately
#' p2 <- p +
#'   scale_fill_viridis_b_interactive(
#'     data_id = function(breaks) {
#'       sapply(seq_along(breaks), function(i) {
#'         if (i < length(breaks)) {
#'           paste(
#'             min(breaks[i], breaks[i + 1], na.rm = TRUE),
#'             max(breaks[i], breaks[i + 1], na.rm = TRUE),
#'             sep = "-"
#'           )
#'         } else {
#'           NA_character_
#'         }
#'       })
#'     },
#'     tooltip = function(breaks) {
#'       sapply(seq_along(breaks), function(i) {
#'         if (i < length(breaks)) {
#'           paste(
#'             min(breaks[i], breaks[i + 1], na.rm = TRUE),
#'             max(breaks[i], breaks[i + 1], na.rm = TRUE),
#'             sep = "-"
#'           )
#'         } else {
#'           NA_character_
#'         }
#'       })
#'     },
#'     guide = "bins"
#'   )
#' x <- girafe(ggobj = p2)
#' x
#'
#' # make the title and labels interactive
#' p3 <- p +
#'   scale_fill_viridis_c_interactive(
#'     data_id = function(breaks) {
#'       sapply(seq_along(breaks), function(i) {
#'         if (i < length(breaks)) {
#'           paste(
#'             min(breaks[i], breaks[i + 1], na.rm = TRUE),
#'             max(breaks[i], breaks[i + 1], na.rm = TRUE),
#'             sep = "-"
#'           )
#'         } else {
#'           NA_character_
#'         }
#'       })
#'     },
#'     tooltip = function(breaks) {
#'       sapply(seq_along(breaks), function(i) {
#'         if (i < length(breaks)) {
#'           paste(
#'             min(breaks[i], breaks[i + 1], na.rm = TRUE),
#'             max(breaks[i], breaks[i + 1], na.rm = TRUE),
#'             sep = "-"
#'           )
#'         } else {
#'           NA_character_
#'         }
#'       })
#'     },
#'     guide = "bins",
#'     name = label_interactive("nlevel", data_id = "nlevel", tooltip = "nlevel"),
#'     labels = function(breaks) {
#'       label_interactive(
#'         as.character(breaks),
#'         data_id = as.character(breaks),
#'         onclick = paste0("alert(\"", as.character(breaks), "\")"),
#'         tooltip = as.character(breaks)
#'       )
#'     }
#'   )
#' x <- girafe(ggobj = p3)
#' x <- girafe_options(
#'   x,
#'   opts_hover_key(girafe_css("stroke:red", text = "stroke:none;fill:red"))
#' )
#' x
#' @seealso [interactive_parameters], [girafe()]
#' @export
guide_bins_interactive <- function(...) {
  guide_interactive(guide_bins, ...)
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GuideInteractiveBins <- ggproto(
  "GuideInteractiveBins",
  GuideBins,
  train = function(self, params = self$params, scale, aesthetic = NULL, ...) {
    parent <- ggproto_parent(GuideBins, self)
    params <- parent$train(
      params = params,
      scale = scale,
      aesthetic = aesthetic,
      ...
    )
    if (!is.null(params) && is.data.frame(params$key) && nrow(params$key)) {
      parsed <- interactive_guide_parse_binned_breaks(scale, params)
      params <- interactive_guide_train(
        params,
        scale,
        parsed$all_breaks,
        label_breaks = parsed$label_breaks
      )
    }
    params
  },
  override_elements = function(params, elements, theme) {
    elements <- GuideBins$override_elements(params, elements, theme)
    interactive_guide_override_elements(elements)
  },
  build_decor = function(decor, grobs, elements, params) {
    decor <- interactive_guide_build_decor(decor, params)
    GuideBins$build_decor(decor, grobs, elements, params)
  },
  build_labels = function(key, elements, params) {
    grobs <- GuideBins$build_labels(key, elements, params)
    if (inherits(key$.label, "interactive_label") && !all(params$show.limits)) {
      valid_ind <- setdiff(
        seq_len(nrow(key)),
        c(1, nrow(key))[!params$show.limits]
      )
      idata <- grobs$labels$children[[1]]$.interactive
      idata <- lapply(idata, function(a) {
        a[valid_ind]
      })
      grobs$labels$children[[1]]$.interactive <- idata
    }
    grobs
  }
)
