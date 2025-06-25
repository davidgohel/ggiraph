#' @title Create interactive theme elements
#'
#' @description
#' With these functions the user can add interactivity to various [ggplot2::theme()]
#' elements.
#'
#' They are based on [ggplot2::element_rect()],
#' [ggplot2::element_line()] and [ggplot2::element_text()]
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters].
#'
#' @inheritSection interactive_parameters Details for element_*_interactive functions
#' @examples
#' # add interactive theme elements -------
#' @example examples/element_interactive.R
#' @seealso [girafe()]
#' @name element_interactive
#' @aliases NULL
NULL

#' @rdname element_interactive
#' @export
element_line_interactive <- function(...) {
  element_interactive(element_line, ...)
}

#' @rdname element_interactive
#' @export
element_rect_interactive <- function(...) {
  element_interactive(element_rect, ...)
}

#' @rdname element_interactive
#' @export
element_text_interactive <- function(...) {
  element_interactive(element_text, ...)
}

#' Calls a base ggplot2 element function and returns an interactive element.
#' @importFrom rlang list2
#' @noRd
element_interactive <- function(
  element_func,
  ...,
  extra_interactive_params = NULL
) {
  args <- list2(...)
  # We need to get the interactive parameters from the arguments and remove them
  ipar <- get_default_ipar(extra_interactive_params)
  ip <- get_interactive_attrs(args, ipar = ipar)
  args <- remove_interactive_attrs(args, ipar = ipar)
  # Call default element function
  struct <- do.call(element_func, args)
  # Store the params, as an attribute of the structure.
  # if we set them straight inside, ggplot resets their value
  # and gives errors at the time of rendering because of theme inheritance.
  # By setting them as an attribute they are preserved.
  attr(struct, "interactive") <- ip
  attr(struct, "ipar") <- ipar
  class(struct) <- c(
    paste("interactive", class(struct)[1], sep = "_"),
    "interactive_element",
    class(struct)
  )
  struct
}

#' @title Create an interactive label
#' @description
#' This function returns an object that can be used as a label
#' via the [ggplot2::labs()] family of functions or
#' when setting a `scale`/`guide` name/title or key label.
#' It passes the interactive parameters to a theme element created via
#' [element_text_interactive()] or via an interactive guide.
#'
#' @param label The text for the label (scalar character)
#' @param ... any of the [interactive_parameters].
#' @return an interactive label object
#' @export
#' @examples
#' library(ggplot2)
#' library(ggiraph)
#'
#' gg_jitter <- ggplot(
#'   mpg, aes(cyl, hwy, group = cyl)) +
#'   geom_boxplot() +
#'   labs(title =
#'          label_interactive(
#'            "title",
#'            data_id = "id_title",
#'            onclick = "alert(\"title\")",
#'            tooltip = "title" )
#'   ) +
#'   theme(plot.title = element_text_interactive())
#'
#' x <- girafe(ggobj = gg_jitter)
#' if( interactive() ) print(x)
#' @seealso [interactive_parameters], [labeller_interactive()]
label_interactive <- function(label, ...) {
  dots <- list2(...)
  ipar <- get_default_ipar(dots$extra_interactive_params)
  ip <- get_interactive_attrs(dots, ipar = ipar)
  structure(
    label,
    interactive = ip,
    ipar = ipar,
    class = c("interactive_label")
  )
}

#' @export
#' @importFrom purrr transpose
element_grob.interactive_element_text <- function(element, label = "", ...) {
  ipar <- get_ipar(element)
  el_ip <- get_interactive_attrs(element, ipar = ipar)
  if (inherits(label, "interactive_label")) {
    ipar <- unique(c(ipar, get_ipar(label)))
    lbl_ip <- get_interactive_attrs(label, ipar = ipar)
    ip <- modify_list(el_ip, lbl_ip)
    attr(element, "interactive") <- ip
    attr(element, "ipar") <- ipar
  } else if (is.list(label)) {
    # guide labels in continuous scales are passed as a list
    label <- label[!is.na(label)]
    # process items
    ip <- lapply(label, function(x) {
      if (inherits(x, "interactive_label")) {
        ipar <<- unique(c(ipar, get_ipar(x)))
        lbl_ip <- get_interactive_attrs(x, ipar = ipar)
        modify_list(el_ip, lbl_ip)
      } else {
        el_ip
      }
    })
    # transpose and convert to character
    ip <- lapply(transpose(ip), as.character)
    attr(element, "interactive") <- ip
    attr(element, "ipar") <- ipar
  }
  NextMethod()
}

#' @export
element_grob.interactive_element <- function(element, ...) {
  dots <- list(...)
  ipar <- get_ipar(element)
  data_attr <- get_data_attr(element, "theme-id")
  el_ip <- get_interactive_attrs(element, ipar = ipar)
  dots_ip <- get_interactive_attrs(dots, ipar = ipar)
  ip <- modify_list(el_ip, dots_ip)
  gr <- NextMethod()
  zz <- add_interactive_attrs(gr, ip, ipar = ipar, data_attr = data_attr)
  zz
}

#' @export
#' @method merge_element interactive_element
merge_element.interactive_element <- function(new, old) {
  new <- NextMethod()

  ipar <- unique(c(get_ipar(new), get_ipar(old)))
  new_data <- get_interactive_data(new)
  old_data <- get_interactive_data(old)

  missing_names <- setdiff(ipar, names(new_data))
  if (length(missing_names) > 0) {
    new_data[missing_names] <- old_data[missing_names]
  }

  attr(new, "interactive") <- new_data
  attr(new, "ipar") <- ipar
  new
}

as_interactive_element_text <- function(el) {
  if (!inherits(el, "interactive_element_text")) {
    class(el) <- c("interactive_element_text", "interactive_element", class(el))
  }
  el
}
