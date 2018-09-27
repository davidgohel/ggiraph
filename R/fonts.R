r_font_families <- c("sans", "serif", "mono", "symbol")

default_fontname <- function() {
  if (.Platform$OS.type == "windows") {
    serif_font <- "Times New Roman"
  } else {
    serif_font <- "Times"
  }
  c(
    sans = "Arial",
    serif = serif_font,
    mono = "Courier",
    symbol = "Symbol"
  )
}

match_sys_font <- function(x){
  if( !( is.character(x) && length(x) == 1 ) ){
    stop("System fonts must be scalar character vector", call. = FALSE)
  }
  matched <- gdtools::match_family(x)

  if (x != matched) {
    warning(call. = FALSE,
            "System font `", x, "` not found. ",
            "Closest match: `", matched, "`")
  }
  matched
}

validate_fonts <- function(system_fonts = list()) {
  missing_fonts <- setdiff(r_font_families, names(system_fonts) )
  system_fonts[missing_fonts] <- lapply(default_fontname()[missing_fonts], gdtools::match_family)
  system_fonts <- lapply(system_fonts, match_sys_font)
  system_fonts
}


