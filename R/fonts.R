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

#' @importFrom gdtools font_family_exists
default_fontname <- function() {
  os <- get_os()
  if (!os %in% c("windows", "osx")) {
    os <- "unix"
  }
  def_fonts <- default_fonts[[os]]
  def_fonts <- def_fonts[unlist(lapply(def_fonts, font_family_exists))]
  missing_fonts <- setdiff(r_font_families, names(def_fonts))
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
  missing_fonts <- setdiff(r_font_families, names(fonts))
  fonts[missing_fonts] <- default_fontname()[missing_fonts]
  fonts
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
#' @importFrom gdtools sys_fonts
#' @importFrom systemfonts match_font system_fonts registry_fonts
#' @family functions for font management
match_family <- function(
  font = "sans",
  bold = TRUE,
  italic = TRUE,
  debug = NULL
) {
  font <- match_font(font, bold = bold, italic = italic)
  font_db <- sys_fonts()
  match <- which(font_db$path %in% font$path)
  font_db$family[match[1]]
}

# girafe font checking ------

list_fonts <- function(gg) {
  fonts_families <- c(
    list_layers_fonts(gg),
    list_theme_fonts(gg)
  )
  browser()
  fonts_families <- sort(unique(fonts_families))
  fonts_families %||% character()
}

#' @importFrom S7 prop_exists
list_theme_fonts <- function(gg) {
  if (!prop_exists(gg, "theme")) {
    return(character())
  }
  element_text_set <- Filter(
    f = function(x) inherits(x, "element_text") && !is.null(x$family),
    gg@theme
  )
  fonts <- vapply(
    X = element_text_set,
    FUN = function(x) {
      z <- x$family
      if (isTRUE(all.equal(z, ""))) {
        "sans"
      } else {
        z
      }
    },
    FUN.VALUE = NA_character_,
    USE.NAMES = FALSE
  )
  fonts <- setdiff(unique(fonts), c("sans", "serif", "mono", "symbol"))
  fonts
}

list_layers_fonts <- function(gg) {
  if (!prop_exists(gg, "layers") || length(gg@layers) == 0) {
    return(character())
  }

  fonts <- character()

  for (layer in gg@layers) {
    if (!is.null(layer$aes_params) && !is.null(layer$aes_params$family)) {
      family_value <- layer$aes_params$family
      if (!is.null(family_value) && !identical(family_value, "")) {
        fonts <- c(fonts, family_value)
      }
    }
  }

  fonts <- setdiff(unique(fonts), c("sans", "serif", "mono", "symbol"))
  fonts
}

extract_family_names_regex <- function(lines) {
  # Pattern pour capturer le contenu entre quotes après font-family:
  pattern <- "font-family:\\s*['\"]([^'\"]+)['\"]"
  matches <- regmatches(lines, regexpr(pattern, lines, perl = TRUE))

  # Extraire seulement le nom de la police (groupe capturé)
  font_names <- gsub("font-family:\\s*['\"]([^'\"]+)['\"]", "\\1", matches, perl = TRUE)

  return(font_names)
}

htmldep_css_files <- function(dep) {
  css_files <- list()

  if (!is.null(dep$stylesheet)) {
    for (i in seq_along(dep$stylesheet)) {
      css_file <- dep$stylesheet[i]
      if (is.list(dep$src)) {
        full_path <- file.path(dep$src$file, css_file)
      } else {
        full_path <- file.path(dep$src, css_file)
      }
      css_files[[css_file]] <- full_path
    }
  }
  css_files <- unlist(css_files)
  css_files <- unname(css_files)
  as.character(css_files)
}

list_families_from_dependencies <- function(dependencies) {
  css_files <- lapply(dependencies, htmldep_css_files)
  css_files <- unlist(css_files)
  css_files <- unname(css_files)
  font_families <- lapply(css_files, function(path) {
    x <- readLines(path)
    extract_family_names_regex(x)
  })
  font_families <- unlist(font_families)
  font_families <- unname(font_families)
  font_families <- unique(font_families)
  font_families
}

fonts_checking_registered <- function(family_list) {
  datafonts <- sys_fonts()
  missing_family_list <- family_list[!tolower(family_list) %in% tolower(datafonts$family)]

  if (length(missing_family_list) > 0) {
    cli::cli_abort(c(
      "!" = "Some fonts are not available in system fonts or are not registered with the {.pkg systemfonts} package.",
      "!" = "Found {length(missing_family_list)} missing font famil{?y/ies} used in ggplot theme: {missing_family_list}.",
      "i" = "You can install and register Google Fonts with {.code gdtools::register_gfont()}.",
      "i" = "You can install and register any fonts with {.code systemfonts::register_font()}.",
      "i" = "For an easy offline alternative with good rendering, use {.code gdtools::register_liberationsans()} to get 'Liberation Sans'."
    ))
  }
}

fonts_checking_dependencies <- function(dependencies, family_list) {
  font_families <- list_families_from_dependencies(dependencies)
  missing_family_list <- setdiff(family_list, font_families)
  if (length(missing_family_list) > 0L) {
    missing_family_list <- shQuote(missing_family_list)
    cli::cli_warn(
      c(
        "!" = "Found {length(missing_family_list)} missing font famil{?y/ies} in the htmlDependencies provided in `dependencies`:",
        "!" = "Missing: {missing_family_list}",
        "i" = "You can add you font families as 'htmlDependencies' within the call to {.fn girafe}:",
        "i" = "for example to add 'Open Sans': {.code girafe(..., dependencies = list(gdtools::gfontHtmlDependency(family = 'Open Sans')))}",
        "!" = "This can be a false positive if fonts are loaded from other sources. In that case, set {.code check_fonts_dependencies = FALSE} in {.fn girafe} as we only scan the htmlDependencies from the {.code dependencies} argument."
      )
    )
  }
}

