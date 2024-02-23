r_font_families <- c("sans", "serif", "mono", "symbol")
default_fonts <- list(
  windows = c(
    sans = "Arial",
    serif = "Times New Roman",
    mono = "Courier New",
    symbol = "Symbol"
  ),
  osx = c(
    sans = "Helvetica",
    serif = "Times",
    mono = "Courier",
    symbol = "Symbol"
  ),
  unix = c(
    sans = "DejaVu Sans",
    serif = "DejaVu serif",
    mono = "DejaVu mono",
    symbol = "DejaVu Sans"
  )
)

default_fontname <- function() {
  os <- get_os()
  if (!os %in% c("windows", "osx"))
    os <- "unix"
  def_fonts <- default_fonts[[os]]
  def_fonts <- def_fonts[unlist(lapply(def_fonts, font_family_exists))]
  missing_fonts <- setdiff(r_font_families, names(def_fonts) )
  def_fonts[missing_fonts] <- lapply(def_fonts[missing_fonts], match_family)
  def_fonts
}

#' @export
#' @title List of validated default fonts
#' @description Validates and possibly modifies the fonts to be used as default
#' value in a graphic according to the fonts available on the machine. It process
#' elements named "sans", "serif", "mono" and "symbol".
#' @param fonts Named list of font names to be aliased with
#' fonts installed on your system. If unspecified, the R default
#' families "sans", "serif", "mono" and "symbol"
#' are aliased to the family returned by [match_family()].
#'
#' If fonts are available, the default mapping will use these values:
#'
#' | R family | Font on Windows    | Font on Unix | Font on Mac OS |
#' |----------|--------------------|--------------|----------------|
#' | `sans`   | Arial              | DejaVu Sans  | Helvetica      |
#' | `serif`  | Times New Roman    | DejaVu serif | Times          |
#' | `mono`   | Courier            | DejaVu mono  | Courier        |
#' | `symbol` | Symbol             | DejaVu Sans  | Symbol         |
#' @return a named list of validated font family names
#' @seealso [girafe()], [dsvg()]
#' @family functions for font management
#' @examples
#' validated_fonts()
validated_fonts <- function(fonts = list()) {
  fonts <- fonts[unlist(lapply(fonts, font_family_exists))]
  missing_fonts <- setdiff(r_font_families, names(fonts) )
  fonts[missing_fonts] <- default_fontname()[missing_fonts]
  fonts
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
#' @family functions for font management
font_family_exists <- function( font_family = "sans" ){
  datafonts <- fortify_font_db()
  tolower(font_family) %in% tolower(datafonts$family)
}

#' Find best family match with systemfonts
#'
#' \code{match_family()} returns the best font family match.
#'
#' @param font family or face to match.
#' @param bold Wheter to match a font featuring a `bold` face.
#' @param italic Wheter to match a font featuring an `italic` face.
#' @param debug deprecated
#' @export
#' @examples
#' match_family("sans")
#' match_family("serif")
#' @importFrom systemfonts match_font system_fonts registry_fonts
#' @family functions for font management
match_family <- function(font = "sans", bold = TRUE, italic = TRUE, debug = NULL) {
  font <- match_font(font, bold = bold, italic = italic)
  font_db <- fortify_font_db()
  match <- which( font_db$path %in% font$path )
  font_db$family[match[1]]
}

fortify_font_db <- function(){
  db_sys <- system_fonts()
  db_reg <- registry_fonts()
  nam <- intersect(colnames(db_sys), colnames(db_reg))
  db_sys <- db_sys[,nam]
  db_reg <- db_reg[,nam]
  font_db <- rbind(db_sys, db_reg)
  font_db
}

list_theme_fonts <- function(gg) {
  element_text_set <- Filter(f = function(x) inherits(x, "element_text") && !is.null(x$family), gg[["theme"]])
  fonts <- vapply(
    X = element_text_set,
    FUN = function(x) {
      z <- x$family
      if (isTRUE(all.equal(z, ""))) "sans"
      else z
    },
    FUN.VALUE = NA_character_,
    USE.NAMES = FALSE
  )
  fonts <- setdiff(unique(fonts), c("sans", "serif", "mono", "symbol"))
  fonts
}

