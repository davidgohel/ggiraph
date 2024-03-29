#' Calls a base grid grob function and returns an interactive grob.
#' @noRd
grob_interactive <- function(grob_func,
                             ...,
                             cl = NULL,
                             data_attr = "data-id",
                             extra_interactive_params = NULL) {
  args <- list(...)
  # We need to get the interactive parameters from the arguments and remove them
  ipar <- get_default_ipar(extra_interactive_params)
  interactive_params <- get_interactive_attrs(args, ipar = ipar)
  args <- remove_interactive_attrs(args, ipar = ipar)
  # Call default grob function
  gr <- do.call(grob_func, args)
  # Put back the interactive_params
  add_interactive_attrs(
    gr,
    interactive_params,
    cl = cl,
    data_attr = data_attr,
    ipar = ipar
  )
}
