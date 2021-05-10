#' @export
#' @title Create a interactive strip label
#' @description These function is an helper function
#' to let user add interactivity on facet strip text.
#'
#' The function adds interactive attributes but does not tell
#' to use them, make sure the theme you are using is specifying the use of `element_text_interactive`
#' for strip text,
#' for example `theme(strip.text = element_text_interactive())`
#' @param custom_label_func a function that returns the result
#' of [label_interactive()].
#' @param ... optional additional arguments for function `custom_label_func`.
#' @param .default a Labeller function, see [label_value()]
#' @examples
#' library(ggplot2)
#' library(ggiraph)
#'
#' gg_jitter <- ggplot(
#'   mpg, aes(cyl, hwy, group = cyl)) +
#'   geom_boxplot() +
#'   facet_wrap(~manufacturer,
#'              labeller = labeller_interactive(id_label)) +
#'   theme(strip.text = element_text_interactive())
#'
#' x <- girafe(ggobj = gg_jitter)
#' if(interactive()) print(x)
#'
#'
#' lab_custom <- function(z, prefix = "label: ") {
#'   label_interactive(label = z, data_id = z, tooltip = paste0(prefix, z))
#' }
#'
#' gg_jitter <- ggplot(diamonds, aes(x = x)) +
#'   geom_density() +
#'   facet_grid(color ~ cut,
#'     labeller = labeller(
#'       cut = labeller_interactive(lab_custom, prefix = "cut: "),
#'       color = labeller_interactive(lab_custom, prefix = "color: ")
#'     )) +
#'   theme_light() +
#'   theme(
#'     strip.text.x = element_text_interactive(),
#'     strip.text.y = element_text_interactive()
#'   )
#'
#' x <- girafe(ggobj = gg_jitter, width_svg = 8, height_svg = 5)
#'
#' if (interactive()) print(x)
#' @seealso [id_label()], [label_interactive()]
labeller_interactive <- function(custom_label_func=id_label, ..., .default = ggplot2::label_value) {
  # must apply the user custom function for a single label only
  # otherwise the attributes of label_interactive will be dropped
  single_label_func <- function(x) {
    if (is.list(x) || is.matrix(x) || length(x) > 1) {
      lapply(x, single_label_func)
    } else {
      custom_label_func(x, ...)
    }
  }

  # must return a labeller function
  fun <- function(label_df) {
    # call default labeller
    labels <- .default(label_df)
    # call user function
    if (is.function(custom_label_func)) {
      labels <- single_label_func(labels)
    }

    labels
  }
  structure(fun, class = "labeller")
}


sanitize_id <- function(x) {
  # should start with an alphabetic char
  x <- paste0("id", x)
  # returns a valid html id
  gsub("^[^a-zA-Z]+|[^\\w:.-]+", "", x, perl = TRUE)
}

#' @export
#' @title simple interactive label
#' @description A simple implementation to turn strip labels into
#' interactive strip labels.
#' @param x the input text
#' @return an interactive label, see [label_interactive()].
#' id_label("a")
#' @seealso [labeller_interactive()]
id_label <- function(x) {
  label_interactive(label = x, data_id = sanitize_id(x), tooltip = x)
}
