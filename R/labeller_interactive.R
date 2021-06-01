#' @export
#' @title Construct interactive labelling specification for facet strips
#'
#' @description
#' This function is a wrapper around [labeller()] that allows the user to turn
#' facet strip labels into interactive labels via [label_interactive()].
#'
#' It requires that the [theme()]'s `strip.text` elements are defined as interactive
#' theme elements via [element_text_interactive()], see details.
#'
#' @details
#' The aesthetics set provided via `.mapping` is evaluated against the data provided
#' by the ggplot2 facet. This means that the variables for each facet are available
#' for using inside the aesthetic mappings. In addition the `.label` variable provides
#' access to the produced label. See the examples.
#'
#' The plot's theme is required to have the strip texts as interactive text elements.
#' This involves `strip.text` or individually `strip.text.x` and `strip.text.y`:
#' `theme(strip.text.x = element_text_interactive())`
#' `theme(strip.text.y = element_text_interactive())`
#'
#' @param ... arguments passed to base function [labeller()]
#' @param .mapping set of aesthetic mappings created by [aes()] or [aes_()].
#' It should provide mappings for any of the [interactive_parameters()].
#' In addition it understands a `label` parameter for creating a new label text.
#' @examples
#' # use interactive labeller
#' @example examples/labeller_interactive.R
#' @seealso [labeller()], [label_interactive()], [labellers]
#' @importFrom rlang eval_tidy
labeller_interactive <- function(.mapping = NULL, ...) {
  # get interactive aesthetics, plus a label parameter
  ipar = c(IPAR_NAMES, "label")
  ip <- get_interactive_attrs(.mapping, ipar = ipar)
  # create ggplot2 labeller
  lbl_fun <- labeller(...)

  # helper to evaluate the aesthetics and return a data frame
  interactive_to_df <- function(data) {
    evaled <- lapply(ip, eval_tidy, data = data)
    evaled <- compact(evaled)
    n <- nrow(data)
    check_aesthetics(evaled, n)
    new_data_frame(evaled)
  }

  # labeller function
  fun <- function(data) {
    if (!is.data.frame(data)) {
      data <- new_data_frame(data)
    }
    # call default labeller to get the labels
    labels <- lbl_fun(data)
    # if we have labels and interactive parameters
    if (nrow(data) > 0 && length(labels) > 0 && length(ip) > 0) {

      labels <- lapply(labels, function(x) {
        # add the labels
        data$.label <- x
        # get all interactive parameters as a data frame
        ip_data <- interactive_to_df(data)

        # for each factor element
        imap(x, function(x, i) {
          if (inherits(x, "interactive_label")) {
            # already a label_interactive
            x
          } else {
            # create a label_interactive, applying the interactive parameters
            args <- list(label = x)
            args <- copy_interactive_attrs(ip_data, args, rows = i, ipar = ipar)
            do.call(label_interactive, args)
          }
        })
      })
    }
    # done
    labels
  }
  structure(fun, class = "labeller")
}
