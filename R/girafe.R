#' @title Create a girafe object
#'
#' @description Create an interactive graphic with a ggplot object
#' to be used in a web browser. The function should replace function
#' \code{ggiraph}.
#'
#' @details
#' Use \code{geom_zzz_interactive} to create interactive graphical elements.
#'
#' Difference from original functions is that some extra aesthetics are understood:
#' the [interactive_parameters()].
#'
#' Tooltips can be displayed when mouse is over graphical elements.
#'
#' If id are associated with points, they get animated when mouse is
#' over and can be selected when used in shiny apps.
#'
#' On click actions can be set with javascript instructions. This option
#' should not be used simultaneously with selections in Shiny
#' applications as both features are "on click" features.
#'
#' When a zoom effect is set, "zoom activate", "zoom desactivate" and
#' "zoom init" buttons are available in a toolbar.
#'
#' When selection type is set to 'multiple' (in Shiny applications), lasso
#' selection and lasso anti-selections buttons are available in a toolbar.
#'
#' @param code Plotting code to execute
#' @param ggobj ggplot objet to print. argument \code{code} will
#' be ignored if this argument is supplied.
#' @param width_svg,height_svg The width and height of the graphics region in inches.
#' The default values are 6 and 5 inches. This will define the aspect ratio of the
#' graphic as it will be used to define viewbox attribute of the SVG result.
#' @param pointsize the default pointsize of plotted text in pixels, default to 12.
#' @param options a list of options for girafe rendering, see
#' \code{\link{opts_tooltip}}, \code{\link{opts_hover}}, \code{\link{opts_selection}}, ...
#' @param ... arguments passed on to \code{\link{dsvg}}
#' @examples
#' library(ggplot2)
#'
#' dataset <- mtcars
#' dataset$carname = row.names(mtcars)
#'
#' gg_point = ggplot( data = dataset,
#'     mapping = aes(x = wt, y = qsec, color = disp,
#'     tooltip = carname, data_id = carname) ) +
#'   geom_point_interactive() + theme_minimal()
#'
#' x <- girafe(ggobj = gg_point, width = 0.7)
#'
#' if(interactive()){
#'   print(x)
#' }
#' @section Widget options:
#' girafe animations can be customized with function \code{\link{girafe_options}}.
#' Options are available to customize tooltips, hover effects, zoom effects
#' selection effects and toolbar.
#' @section Widget sizing:
#' girafe graphics are responsive, which mean, they will be resized
#' according to their container. There are two responsive behavior
#' implementations: one for Shiny applications and flexdashboard documents
#' and one for other documents (i.e. R markdown and \code{saveWidget}).
#'
#' Graphics are created by an R graphic device (i.e pdf, png, svg here) and
#' need arguments width and height to define a graphic region.
#' Arguments \code{width_svg} and \code{height_svg} are used as corresponding
#' values. They are defining the aspect ratio of the graphic. This proportion is
#' always respected when the graph is displayed.
#'
#' When a girafe graphic is in a Shiny application,
#' graphic will be resized according to the arguments \code{width} and
#' \code{height} of the function \code{girafeOutput}. Default
#' values are '100\%' and '500px'. These arguments determine the
#' outer bounding box of the graphic (the HTML element that will
#' contain the graphic with an aspect ratio).
#'
#' When a girafe graphic is in an R markdown document (producing an HTML
#' document), the graphic will be resized according to the argument \code{width} of the
#' function \code{girafe}. Its value is beeing used to define a relative
#' width of the graphic within its HTML container. Its height is automatically
#' adjusted regarding to the argument \code{width} and the aspect ratio.
#'
#' If this behavior does not fit with your need, I recommand you to use
#' package widgetframe that wraps htmlwidgets inside a responsive iframe.
#' @seealso \code{\link{girafe_options}}
#' @export
#' @importFrom uuid UUIDgenerate
girafe <- function(
  code, ggobj = NULL,  pointsize = 12,
  width_svg = 6, height_svg = 5,
  options = list(), ...) {

  path = tempfile()

  args <- list(...)
  args$canvas_id <- args$canvas_id %||% paste("svg", UUIDgenerate(), sep = "_")
  args$file <- path
  args$width <- width_svg
  args$height <- height_svg
  args$pointsize <- pointsize
  args$standalone <- TRUE
  args$setdims <- FALSE

  do.call(dsvg, args)
  tryCatch({
    if( !is.null(ggobj) ){
      stopifnot(inherits(ggobj, "ggplot"))
      print(ggobj)
    } else
      code
  }, finally = dev.off() )

  settings <- merge_options(default_opts(), options)
  x = list( html = paste0(readLines(path, encoding = "UTF-8"), collapse = "\n"),
            js = NULL,
            uid = args$canvas_id,
            ratio = width_svg / height_svg,
            settings = settings
            )

  unlink(path)

  createWidget(
    name = 'girafe', x = x, package = 'ggiraph',
    sizingPolicy = sizingPolicy(knitr.figure = TRUE, browser.fill = FALSE)
  )

}



#' @title Create a girafe output element
#' @description Render a girafe within an application page.
#'
#' @param outputId output variable to read the girafe from. Do not use special JavaScript
#' characters such as a period \code{.} in the id, this would create a JavaScript error.
#' @param width widget width
#' @param height widget height
#' @export
girafeOutput <- function(outputId, width = "100%", height = "500px"){
  # if( "auto" %in% height )
  #   stop("'height:auto' is not supported", call. = FALSE)
  # if( "auto" %in% width )
  #   stop("'width:auto' is not supported", call. = FALSE)

  shinyWidgetOutput(outputId, 'girafe', package = 'ggiraph', width = width, height = height)
}

#' @title Reactive version of girafe
#'
#' @description Makes a reactive version of girafe
#' object for use in Shiny.
#'
#' @param expr An expression that returns a [girafe()] object.
#' @param env The environment in which to evaluate expr.
#' @param quoted Is \code{expr} a quoted expression
#' @export
renderGirafe <- function(expr, env = parent.frame(), quoted = FALSE) {
	if (!quoted) { expr <- substitute(expr) } # force quoted
	shinyRenderWidget(expr, girafeOutput, env, quoted = TRUE)
}

default_opts <- function(){
  settings <- list(
    tooltip = opts_tooltip(),
    hover = opts_hover(),
    hoverkey = opts_hover_key(),
    hovertheme = opts_hover_theme(),
    hoverinv = opts_hover_inv(),
    zoom = opts_zoom(),
    capture = opts_selection(),
    capturekey = opts_selection_key(),
    capturetheme = opts_selection_theme(),
    toolbar = opts_toolbar(),
    sizing = opts_sizing()
  )
  settings
}

merge_options <- function(options, args){
  for (arg in args) {
    if (inherits(arg, "opts_zoom")) {
      options$zoom <- arg
    } else if (inherits(arg, "opts_selection")) {
      options$capture <- arg
    } else if (inherits(arg, "opts_selection_key")) {
      options$capturekey <- arg
    } else if (inherits(arg, "opts_selection_theme")) {
      options$capturetheme <- arg
    } else if (inherits(arg, "opts_tooltip")) {
      options$tooltip <- arg
    } else if (inherits(arg, "opts_hover")) {
      options$hover <- arg
    } else if (inherits(arg, "opts_hover_key")) {
      options$hoverkey <- arg
    } else if (inherits(arg, "opts_hover_theme")) {
      options$hovertheme <- arg
    } else if (inherits(arg, "opts_hover_inv")) {
      options$hoverinv <- arg
    } else if (inherits(arg, "opts_toolbar")) {
      options$toolbar <- arg
    } else if (inherits(arg, "opts_sizing")) {
      options$sizing <- arg
    }
  }
  options
}

girafe_app_paths <- function(){
  example_dir <- system.file(package = "ggiraph", "examples", "shiny")
  list.files(example_dir, full.names = TRUE)
}



#' Run shiny examples and see corresponding code
#'
#' @param name an application name, one of
#' cars, click_scale, crimes, DT, dynamic_ui,
#' iris, maps and modal.
#'
#' @export
run_girafe_example <- function(name = "crimes"){
  example_dir <- system.file(package = "ggiraph", "examples", "shiny")
  apps <- girafe_app_paths()
  if( !name %in% basename(apps) ){
    stop("could not find app named ", shQuote(name), " in the following list: ",
         paste0(shQuote(basename(apps)), collapse = ", ")
    )
  }
  if(requireNamespace("shiny"))
    shiny::runApp(
      appDir = file.path(example_dir, name),
      display.mode = "showcase")
  else warning("package shiny is required to be able to use the function")
}

