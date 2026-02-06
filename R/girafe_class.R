#' @title Add, remove or toggle CSS classes on girafe elements
#'
#' @description
#' These functions allow programmatic manipulation of CSS classes
#' on SVG elements within a girafe output in Shiny applications.
#' Elements are targeted by their `data-id`, `key-id`, or `theme-id`
#' attributes.
#'
#' @param session The Shiny session object.
#' @param id The output id of the girafe element
#'   (the `outputId` used in [girafeOutput()]).
#' @param class A non-empty character string of CSS class names to
#'   add, remove, or toggle.
#' @param data_id A character vector of `data-id` values identifying
#'   the target elements.
#' @param key_id A character vector of `key-id` values identifying
#'   the target elements.
#' @param theme_id A character vector of `theme-id` values identifying
#'   the target elements.
#'
#' @details
#' At least one of `data_id`, `key_id`, or `theme_id` must be provided.
#'
#' These functions send a custom message to the JavaScript side,
#' which applies the CSS class operation to all matching SVG elements
#' within the girafe root node.
#'
#' @examples
#' \dontrun{
#' # In a Shiny server function:
#' girafe_class_add(session, "plot", "highlighted", data_id = "some_id")
#' girafe_class_remove(session, "plot", "highlighted", data_id = "some_id")
#' girafe_class_toggle(session, "plot", "highlighted", data_id = "some_id")
#' }
#' @name girafe_class
NULL

#' @rdname girafe_class
#' @export
girafe_class_add <- function(session, id, class, data_id = NULL, key_id = NULL, theme_id = NULL) {
  girafe_class_action(session, id, class, action = "add", data_id = data_id, key_id = key_id, theme_id = theme_id)
}

#' @rdname girafe_class
#' @export
girafe_class_remove <- function(session, id, class, data_id = NULL, key_id = NULL, theme_id = NULL) {
  girafe_class_action(session, id, class, action = "remove", data_id = data_id, key_id = key_id, theme_id = theme_id)
}

#' @rdname girafe_class
#' @export
girafe_class_toggle <- function(session, id, class, data_id = NULL, key_id = NULL, theme_id = NULL) {
  girafe_class_action(session, id, class, action = "toggle", data_id = data_id, key_id = key_id, theme_id = theme_id)
}

girafe_class_action <- function(session, id, class, action, data_id = NULL, key_id = NULL, theme_id = NULL) {
  if (!is.character(class) || length(class) != 1 || !nzchar(class)) {
    stop("`class` must be a non-empty string.", call. = FALSE)
  }
  if (is.null(data_id) && is.null(key_id) && is.null(theme_id)) {
    stop("At least one of `data_id`, `key_id`, or `theme_id` must be provided.", call. = FALSE)
  }

  message <- list(action = action, cls = class)
  if (!is.null(data_id)) message$data_id <- as.character(data_id)
  if (!is.null(key_id)) message$key_id <- as.character(key_id)
  if (!is.null(theme_id)) message$theme_id <- as.character(theme_id)

  session$sendCustomMessage(
    type = paste0(id, "_class"),
    message = message
  )
}
