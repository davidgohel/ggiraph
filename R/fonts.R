r_font_families <- c("sans", "serif", "mono", "symbol")

#' @export
#' @title List of validated default fonts
#' @description Validates and possibly modifies the fonts to be used as default
#' value in a graphic according to the fonts available on the machine. It
#' processes elements named "sans", "serif", "mono" and "symbol".
#'
#' Default font resolution is delegated to [gdtools::font_set_liberation()],
#' which uses Liberation fonts (bundled by 'fontquiver', SIL Open Font
#' License) for reproducible offline output.
#'
#' @param fonts Named list of font names to be aliased with
#' fonts installed on your system. If unspecified, the defaults
#' from [gdtools::font_set_liberation()] are used.
#' @return a named list of validated font family names
#' @seealso [girafe()], [dsvg()]
#' @family functions for font management
#' @importFrom gdtools font_set_liberation sys_fonts
#' @examples
#' validated_fonts()
validated_fonts <- function(fonts = list()) {
  # listing the fonts is slow when many are installed: list them once
  # and only build the Liberation defaults when a family is missing
  if (length(fonts) > 0) {
    families <- tolower(sys_fonts()$family)
    fonts <- fonts[vapply(
      fonts,
      function(x) tolower(x) %in% families,
      logical(1)
    )]
  }
  missing_fonts <- setdiff(r_font_families, names(fonts))
  if (length(missing_fonts) > 0) {
    auto <- font_set_liberation()
    defaults <- c(
      sans = auto$sans,
      serif = auto$serif,
      mono = auto$mono,
      symbol = auto$symbol
    )
    fonts[missing_fonts] <- defaults[missing_fonts]
  }
  fonts
}


#' Find best family match with systemfonts
#'
#' @description
#' `match_family()` is deprecated: use [systemfonts::match_fonts()] instead.
#' It is no longer used by ggiraph, and its equivalent in 'gdtools' is
#' deprecated too.
#'
#' `match_family()` returns the best font family match.
#'
#' @param font family or face to match.
#' @param bold Wheter to match a font featuring a `bold` face.
#' @param italic Wheter to match a font featuring an `italic` face.
#' @param debug deprecated
#' @export
#' @keywords internal
#' @importFrom gdtools sys_fonts
#' @importFrom systemfonts match_font system_fonts registry_fonts
match_family <- function(
  font = "sans",
  bold = TRUE,
  italic = TRUE,
  debug = NULL
) {
  .Deprecated(new = "systemfonts::match_fonts")
  font <- match_font(font, bold = bold, italic = italic)
  font_db <- sys_fonts()
  match <- which(font_db$path %in% font$path)
  font_db$family[match[1]]
}

# girafe font checking ------

# the fonts written by dsvg in the `font-family` attribute of the `<text>`
# elements: the families really used, aliases resolved ("sans" is written
# as the font of the font set), whatever set them (theme of the plot or
# theme_set(), `family` of a layer, element_geom(), an aesthetic, base
# graphics...). Texts drawn as outlines (equations, 'marquee') have no
# `<text>` and need no font.
list_svg_fonts <- function(svg) {
  m <- regmatches(svg, gregexpr("font-family=(['\"])[^'\"]*\\1", svg, perl = TRUE))[[1]]
  fonts <- substr(m, 14L, nchar(m) - 1L)
  fonts <- gsub("&apos;", "'", fonts, fixed = TRUE)
  fonts <- gsub("&quot;", "\"", fonts, fixed = TRUE)
  fonts <- gsub("&amp;", "&", fonts, fixed = TRUE)
  sort(unique(fonts[nzchar(fonts)]))
}

extract_family_names_regex <- function(lines) {
  # one single line
  css_text <- paste(lines, collapse = "\n")

  # Pattern for @font-face
  fontface_pattern <- "@font-face\\s*\\{[^}]+\\}"
  fontface_blocks <- regmatches(
    css_text,
    gregexpr(fontface_pattern, css_text, perl = TRUE)
  )[[1]]

  if (length(fontface_blocks) == 0) {
    return(character())
  }

  # family in @font-face blocks, quoted or not (`font-family: Open Sans;`)
  family_pattern <- "font-family:\\s*['\"]?([^;'\"}]+?)['\"]?\\s*(;|\\})"

  font_names <- character()
  for (block in fontface_blocks) {
    matches <- regmatches(block, regexpr(family_pattern, block, perl = TRUE))
    if (length(matches) > 0) {
      family_name <- gsub(family_pattern, "\\1", matches, perl = TRUE)
      font_names <- c(font_names, family_name)
    }
  }

  return(sort(unique(font_names)))
}

# the local css files of a dependency, as htmltools finds them: `src$file`
# relative to the package when `package` is given; a stylesheet can be
# given as a list with `href`; remote dependencies (`src$href` only) and
# missing files are skipped
htmldep_css_files <- function(dep) {
  src <- dep$src
  dir <- if (is.list(src)) src$file else if (!is.null(names(src))) src[["file"]] else src
  if (is.null(dir) || is.null(dep$stylesheet)) {
    return(character())
  }
  if (!is.null(dep$package)) {
    dir <- system.file(dir, package = dep$package)
  }
  sheets <- dep$stylesheet
  if (is.list(sheets)) {
    sheets <- vapply(
      sheets,
      function(x) if (is.list(x)) x$href %||% NA_character_ else as.character(x),
      character(1)
    )
  }
  paths <- file.path(dir, sheets[!is.na(sheets)])
  paths[file.exists(paths)]
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
  missing_family_list <- family_list[
    !tolower(family_list) %in% tolower(datafonts$family)
  ]

  if (length(missing_family_list) > 0) {
    # a warning: the graphic is drawn, but its texts are measured with
    # another font than the one the browser will use
    cli::cli_warn(c(
      "!" = "Font famil{?y/ies} {.val {missing_family_list}} {?is/are} not installed or not registered with {.pkg systemfonts}: the texts are measured with another font and may not fit.",
      "i" = "You can install and register Google Fonts with {.code gdtools::register_gfont()}.",
      "i" = "You can install and register any fonts with {.code systemfonts::register_font()}.",
      "i" = "For an easy offline alternative with good rendering, use {.code gdtools::register_liberationsans()} to get 'Liberation Sans'.",
      "i" = "Set {.code check_fonts_registered = FALSE} in {.fn girafe} to skip this check."
    ), call = NULL)
  }
}

fonts_checking_dependencies <- function(dependencies, family_list) {
  font_families <- list_families_from_dependencies(dependencies)
  # font-family names are case insensitive in css
  missing_family_list <- family_list[!tolower(family_list) %in% tolower(font_families)]
  if (length(missing_family_list) > 0L) {
    missing_family_list <- shQuote(missing_family_list)
    cli::cli_warn(
      c(
        "!" = "Found {length(missing_family_list)} missing font famil{?y/ies} in the htmlDependencies provided in `dependencies`:",
        "!" = "Missing: {missing_family_list}",
        "i" = "You can add your font families as 'htmlDependencies' within the call to {.fn girafe}:",
        "i" = "for example to add 'Open Sans': {.code girafe(..., dependencies = list(gdtools::gfontHtmlDependency(family = 'Open Sans')))}",
        "!" = "This can be a false positive if fonts are loaded from other sources. In that case, set {.code check_fonts_dependencies = FALSE} in {.fn girafe} as we only scan the htmlDependencies from the {.code dependencies} argument."
      )
    )
  }
}
