#' @title Create interactive theme elements
#'
#' @description
#' With these functions the user can add interactivity to various [theme][ggplot2::theme]
#' elements.
#'
#' They are based on [element_rect()],
#' [element_line()] and [element_text()]
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters()].
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
element_line_interactive <- function(...)
  element_interactive(element_line, ...)

#' @rdname element_interactive
#' @export
element_rect_interactive <- function(...)
  element_interactive(element_rect, ...)

#' @rdname element_interactive
#' @export
element_text_interactive <- function(...)
  element_interactive(element_text, ...)

#' Calls a base ggplot2 element function and returns an interactive element.
#' @noRd
element_interactive <- function(element_func,
                                ...,
                                ipar = IPAR_NAMES) {
  args <- list(...)
  # We need to get the interactive parameters from the arguments and remove them
  ip <- get_interactive_attrs(args, ipar = ipar)
  args <- remove_interactive_attrs(args, ipar = ipar)
  # Call default element function
  struct <- do.call(element_func, args)
  # Store the params, as an attribute of the structure.
  # if we set them straight inside, ggplot resets their value
  # and gives errors at the time of rendering because of theme inheritance.
  # By setting them as an atrribute they are preserved.
  attr(struct, "interactive") <- ip
  attr(struct, "ipar") <- ipar
  class(struct) <- c(paste("interactive", class(struct)[1], sep = "_"),
                     "interactive_element",
                     class(struct))
  struct
}

#' @title Create an interactive label
#' @description
#' This function returns an object that can be used as a label
#' via the [labs()] family of functions or
#' when setting a \code{scale}/\code{guide} name/title or key label.
#' It passes the interactive parameters to a theme element created via
#' \code{\link{element_text_interactive}} or via an interactive guide.
#'
#' @param label The text for the label (scalar character)
#' @param ... any of the [interactive_parameters()].
#' @return an interactive label object
#' @export
label_interactive <- function(label, ...) {
  ip <- get_interactive_attrs(list(...))
  structure(
    label,
    interactive = ip,
    class = c("interactive_label")
  )
}

#' @export
#' @importFrom purrr transpose
element_grob.interactive_element_text <- function(element,
                                                  label = "",
                                                  ...) {
  ipar <- attr(element, "ipar")
  if (is.null(ipar))
    ipar <- IPAR_NAMES
  el_ip <- get_interactive_attrs(element, ipar = ipar)
  if (inherits(label, "interactive_label")) {
    lbl_ip <- get_interactive_attrs(label, ipar = ipar)
    ip <- modify_list(el_ip, lbl_ip)
    attr(element, "interactive") <- ip

  } else if (is.list(label)) {
    # guide labels in continuous scales are passed as a list
    label <- label[!is.na(label)]
    # process items
    ip <- lapply(label, function(x) {
      if (inherits(x, "interactive_label")) {
        lbl_ip <- get_interactive_attrs(x, ipar = ipar)
        modify_list(el_ip, lbl_ip)
      } else {
        el_ip
      }
    })
    # transpose and convert to character
    ip <- lapply(transpose(ip), as.character)
    attr(element, "interactive") <- ip
  }
  NextMethod()
}

#' @export
element_grob.interactive_element <- function(element, ...) {
  dots <- list(...)
  ipar <- dots$ipar %||% attr(element, "ipar") %||% IPAR_NAMES
  data_attr <- dots$data_attr %||% attr(element, "data_attr") %||% "theme-id"
  el_ip <- get_interactive_attrs(element, ipar = ipar)
  dots_ip <- get_interactive_attrs(dots, ipar = ipar)
  ip <- modify_list(el_ip, dots_ip)
  gr <- NextMethod()
  add_interactive_attrs(gr, ip, ipar = ipar, data_attr = data_attr)
}

#' @export
merge_element.interactive_element <- function(new, old) {
  new <- NextMethod()

  new_attr <- attr(new, "interactive")
  if (is.null(new_attr))
    new_attr <- IPAR_DEFAULTS
  old_attr <- attr(old, "interactive")
  if (is.null(old_attr))
    old_attr <- IPAR_DEFAULTS

  # Override NULL properties of new with the values in old
  # Get logical vector of NULL properties in new
  idx <- vapply(new_attr, is.null, logical(1))
  # Get the names of TRUE items
  idx <- names(idx[idx])

  # Update non-NULL items
  new_attr[idx] <- old_attr[idx]

  attr(new, "interactive") <- new_attr
  new
}

as_interactive_element_text <- function(el) {
  if (!inherits(el, "interactive_element_text")) {
    class(el) <- c("interactive_element_text",
                   "interactive_element",
                   class(el))
  }
  el
}
