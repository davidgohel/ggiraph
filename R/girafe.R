#' @importFrom htmltools htmlDependency
#' @title Create a girafe object
#'
#' @description Create an interactive graphic with a ggplot object
#' to be used in a web browser. The function should replace function
#' `ggiraph`.
#'
#' @details
#' Use `geom_zzz_interactive` to create interactive graphical elements.
#'
#' Difference from original functions is that some extra aesthetics are understood:
#' the [interactive_parameters].
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
#' @param ggobj ggplot object to print. Argument `code` will
#' be ignored if this argument is supplied.
#' @param width_svg,height_svg The width and height of the graphics region in inches.
#' The default values are 6 and 5 inches. This will define the aspect ratio of the
#' graphic as it will be used to define viewbox attribute of the SVG result.
#'
#' If you use `girafe()` in an 'R Markdown' document, we
#' recommend not using these arguments so that the knitr
#' options `fig.width` and `fig.height` are used instead.
#' @param pointsize the default pointsize of plotted text in pixels, default to 12.
#' @param options a list of options for girafe rendering, see
#' [opts_tooltip()], [opts_hover()], [opts_selection()], ...
#' @param dependencies Additional widget HTML dependencies, see [htmlwidgets::createWidget()].
#' @param ... arguments passed on to [dsvg()]
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
#' x <- girafe(ggobj = gg_point)
#'
#' if(interactive()){
#'   print(x)
#' }
#' @section Widget options:
#' girafe animations can be customized with function [girafe_options()].
#' Options are available to customize tooltips, hover effects, zoom effects
#' selection effects and toolbar.
#' @section Widget sizing:
#' girafe graphics are responsive, which mean, they will be resized
#' according to their container. There are two responsive behavior
#' implementations: one for Shiny applications and flexdashboard documents
#' and one for other documents (i.e. R markdown and `saveWidget`).
#'
#' Graphics are created by an R graphic device (i.e pdf, png, svg here) and
#' need arguments width and height to define a graphic region.
#' Arguments `width_svg` and `height_svg` are used as corresponding
#' values. They are defining the aspect ratio of the graphic. This proportion is
#' always respected when the graph is displayed.
#'
#' When a girafe graphic is in a Shiny application,
#' graphic will be resized according to the arguments `width` and
#' `height` of the function `girafeOutput`. Default
#' values are '100\%' and '500px'. These arguments determine the
#' outer bounding box of the graphic (the HTML element that will
#' contain the graphic with an aspect ratio).
#'
#' When a girafe graphic is in an R markdown document (producing an HTML
#' document), the graphic will be resized according to the argument `width` of the
#' function `girafe`. Its value is beeing used to define a relative
#' width of the graphic within its HTML container. Its height is automatically
#' adjusted regarding to the argument `width` and the aspect ratio.
#'
#' If this behavior does not fit with your need, I recommend you to use
#' package widgetframe that wraps htmlwidgets inside a responsive iframe.
#' @seealso [girafe_options()], [validated_fonts()], [dsvg()]
#' @export
#' @importFrom uuid UUIDgenerate
girafe <- function(
  code, ggobj = NULL,  pointsize = 12,
  width_svg = NULL, height_svg = NULL,
  options = list(), dependencies = NULL, ...) {

  path = tempfile()

  if (is.null(width_svg)) {
    width_svg <- default_width(default = 6)
  }
  if (is.null(height_svg)) {
    height_svg <- default_height(default = 5)
  }


  args <- list(...)
  args$canvas_id <- args$canvas_id %||% paste("svg", gsub('-', '_', UUIDgenerate()), sep = "_")
  args$file <- path
  args$width <- width_svg
  args$height <- height_svg
  args$pointsize <- pointsize
  args$standalone <- TRUE
  args$setdims <- FALSE
  # we need a surface with pointer events
  if (identical(args$bg, "transparent")) {
    args$bg <- "#fffffffd"
  }

  devlength <- length(dev.list())
  do.call(dsvg, args)
  tryCatch({
    if (!is.null(ggobj)) {
      if (!inherits(ggobj, "ggplot")) {
        abort("`ggobj` must be a ggplot2 plot", call = NULL)
      }
      print(ggobj)
    } else
      code
  }, finally = {
    if (length(dev.list()) > devlength) {
      dev.off()
    }
  })

  settings <- merge_options(default_opts(), options)
  sizing_policy <- merge_sizing_policy(default_sizing_policy(), options)
  x <- list(
    html = read_file(path),
    js = NULL,
    uid = args$canvas_id,
    ratio = width_svg / height_svg,
    settings = settings
  )

  unlink(path)

  createWidget(
    name = 'girafe', x = x, package = 'ggiraph',
    sizingPolicy = sizing_policy,
    dependencies = dependencies
  )

}



#' @importFrom htmlwidgets shinyRenderWidget shinyWidgetOutput sizingPolicy createWidget
#' @import grid
#' @import ggplot2
#' @importFrom grDevices dev.off
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
#' @param quoted Is `expr` a quoted expression
#' @param outputArgs A list of arguments to be passed through to the implicit call to [girafeOutput()]
#' when `renderGirafe` is used in an interactive R Markdown document.
#' @export
renderGirafe <- function(expr, env = parent.frame(), quoted = FALSE, outputArgs = list()) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  f <- shinyRenderWidget(expr, girafeOutput, env, quoted = TRUE)
  # shinyRenderWidget is missing outputArgs argument
  # set outputArgs to the result function instead
  if (inherits(f, "shiny.render.function")) {
    attr(f, "outputArgs") <- outputArgs
  }
  f
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
    abort("could not find app named ", shQuote(name), " in the following list: ",
         paste0(shQuote(basename(apps)), collapse = ", "), call = NULL
    )
  }
  if(requireNamespace("shiny"))
    shiny::runApp(
      appDir = file.path(example_dir, name),
      display.mode = "showcase")
  else warning("package shiny is required to be able to use the function")
}

