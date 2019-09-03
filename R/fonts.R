r_font_families <- c("sans", "serif", "mono", "symbol")

default_fontname <- function() {
  c(
    sans = match_family("sans"),
    serif = match_family("serif"),
    mono = match_family("mono"),
    symbol = match_family("symbol")
  )
}

#' @importFrom gdtools match_family
validate_fonts <- function(system_fonts = list()) {
  missing_fonts <- setdiff(r_font_families, names(system_fonts) )
  system_fonts[missing_fonts] <- lapply(default_fontname()[missing_fonts], match_family)
  system_fonts <- lapply(system_fonts, match_family)
  system_fonts
}
