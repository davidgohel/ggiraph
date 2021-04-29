r_font_families <- c("sans", "serif", "mono", "symbol")

default_fontname <- function() {
  def_fonts <- if( Sys.info()["sysname"] == "Windows" ){
    c(
      sans = "Arial",
      serif = "Times New Roman",
      mono = "Courier New",
      symbol = "Symbol"
    )
  } else if( Sys.info()["sysname"] == "Darwin" ){
    c(
      sans = "Helvetica",
      serif = "Times",
      mono = "Courier",
      symbol = "Symbol"
    )
  } else {
    c(
      sans = "DejaVu Sans",
      serif = "DejaVu serif",
      mono = "DejaVu mono",
      symbol = "DejaVu Sans"
    )
  }

  def_fonts <- def_fonts[unlist(lapply(def_fonts, font_family_exists))]
  missing_fonts <- setdiff(r_font_families, names(def_fonts) )
  def_fonts[missing_fonts] <- lapply(def_fonts[missing_fonts], match_family)
  def_fonts
}


validate_fonts <- function(system_fonts = list()) {
  system_fonts <- system_fonts[unlist(lapply(system_fonts, font_family_exists))]
  missing_fonts <- setdiff(r_font_families, names(system_fonts) )
  system_fonts[missing_fonts] <- default_fontname()[missing_fonts]
  system_fonts
}



#' @title Check if font family exists.
#'
#' @description Check if a font family exists in system fonts.
#'
#' @return A logical value
#' @param font_family font family name (case sensitive)
#' @examples
#' font_family_exists("sans")
#' font_family_exists("Arial")
#' font_family_exists("Courier")
#' @export
#' @importFrom systemfonts match_font system_fonts
font_family_exists <- function( font_family = "sans" ){
  datafonts <- system_fonts()
  tolower(font_family) %in% tolower(datafonts$family)
}

#' Find best family match with systemfonts
#'
#' \code{match_family()} returns the best font family match.
#'
#' @param font family or face to match.
#' @param bold Wheter to match a font featuring a \code{bold} face.
#' @param italic Wheter to match a font featuring an \code{italic} face.
#' @param debug deprecated
#' @export
#' @examples
#' match_family("sans")
#' match_family("serif")
#' @importFrom systemfonts match_font system_fonts
match_family <- function(font = "sans", bold = TRUE, italic = TRUE, debug = NULL) {
  font <- match_font(font, bold = bold, italic = italic)
  sysfonts <- system_fonts()
  match <- which( sysfonts$path %in% font$path )
  sysfonts$family[match[1]]
}

