.onLoad <- function(libname, pkgname) {
  # S7 methods for generics of other packages (ggplot2::merge_element)
  S7::methods_register()
}
