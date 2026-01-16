#' @importFrom htmltools htmlDependency
#' @title Create a girafe object
#'
#' @description Create an interactive graphic with a ggplot object
#' to be used in a web browser.
#'
#' @details
#' Use `geom_zzz_interactive` to create interactive graphical elements.
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
#' @param check_fonts_registered whether to check if fonts families found in
#' the ggplot are registered with 'systemfonts'.
#' @param check_fonts_dependencies whether to check if fonts families found in
#' the ggplot are found in the `dependencies` list.
#' @param ... arguments passed on to [dsvg()]
#' @example examples/girafe.R
#' @section Managing Grouping with Interactive Aesthetics:
#'
#' Adding an interactive aesthetic like `tooltip` can sometimes alter the implicit
#' grouping that ggplot2 performs automatically.
#'
#' In these cases, you **must explicitly** specify the `group` aesthetic to ensure
#' correct graph rendering by clearly defining the variables that determine the
#' grouping.
#'
#' ```r
#' mapping = ggplot2::aes(tooltip = .data_tooltip, group = interaction(factor1, factor2, ...))
#' ```
#'
#' This precaution is necessary:
#'
#' - ggplot2 automatically determines grouping based on the provided aesthetics
#' - Interactive aesthetics added by ggiraph can interfere with this logic
#' - Explicit `group` specification prevents unexpected behavior and ensures predictable results
#'
#' @section Widget options:
#' girafe animations can be customized with function [girafe_options()].
#' Options are available to customize tooltips, hover effects, zoom effects
#' selection effects and toolbar.
#' @section Widget sizing:
#' girafe graphics are responsive, which mean, they will be resized
#' according to their container. There are two responsive behavior
#' implementations:
#'
#' - one for Shiny applications and flexdashboard documents,
#' - and another one for other documents (i.e. R markdown and `saveWidget`).
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
#' values are '100\%' and NULL. These arguments determine the
#' outer bounding box of the graphic (the HTML element that will
#' contain the graphic with an aspect ratio).
#'
#' When a girafe graphic is in an R markdown document (producing an HTML
#' document), the graphic will be resized according to the argument `width` of the
#' function `girafe`. Its value is beeing used to define a relative
#' width of the graphic within its HTML container. Its height is automatically
#' adjusted regarding to the argument `width` and the aspect ratio.
#' @seealso [girafe_options()], [validated_fonts()], [dsvg()]
#' @export
girafe <- function(
  ggobj = NULL,
  code,
  pointsize = 12,
  width_svg = NULL,
  height_svg = NULL,
  options = list(),
  dependencies = NULL,
  check_fonts_registered = FALSE,
  check_fonts_dependencies = FALSE,
  ...
) {
  path <- tempfile()

  # checks dims -----
  if (is.null(width_svg)) {
    width_svg <- default_width(default = 6)
  }
  if (is.null(height_svg)) {
    height_svg <- default_height(default = 5)
  }

  # prepare argument for dsvg -----
  args <- list(...)
  args$canvas_id <- args$canvas_id %||%
    paste("svg", UUIDgenerate(), sep = "_")
  args$file <- path
  args$width <- width_svg
  args$height <- height_svg
  args$pointsize <- pointsize
  args$standalone <- TRUE
  args$setdims <- FALSE
  # we need a surface with pointer events
  if (identical(args$bg, "transparent")) {
    args$bg <- "#ffffff01"
  }

  if (!is.null(ggobj)) {
    # check ggobj -----
    if (!inherits(ggobj, "ggplot")) {
      cli::cli_abort(c(
        "{.code ggobj} must be a {.code ggplot2} object."
      ))
    }
  }

  devlength <- length(dev.list())
  # graphic production -----
  do.call(dsvg, args)
  tryCatch(
    {
      if (!is.null(ggobj)) {
        print(ggobj)
      } else {
        code
      }
    },
    finally = {
      if (length(dev.list()) > devlength) {
        dev.off()
      }
    }
  )

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

  # check fonts
  family_list <- character()
  if (check_fonts_registered || check_fonts_dependencies) {
    family_list <- list_fonts(ggobj)
  }
  # check fonts -----
  if (check_fonts_registered && !is.null(ggobj)) {
    fonts_checking_registered(family_list = family_list)
  } else if (check_fonts_registered && is.null(ggobj)) {
    cli::cli_warn(
      c(
        "!" = "Dependencies checking can not be performed if `ggobj` is missing."
      )
    )
  }
  if (check_fonts_dependencies && !is.null(ggobj)) {
    fonts_checking_dependencies(
      dependencies = dependencies,
      family_list = family_list
    )
  } else if (check_fonts_dependencies && is.null(ggobj)) {
    cli::cli_warn(
      "!" = "Dependencies checking can not be performed if `ggobj` is missing."
    )
  }

  # create widget -----
  createWidget(
    name = "girafe",
    x = x,
    package = "ggiraph",
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
#' @section Size control:
#' If you want to control a fixed size, use
#' `opts_sizing(rescale = FALSE)` and set the chart size
#' with `girafe(width_svg=..., height_svg=...)`.
#'
#' If you want
#' the graphic to fit the available width,
#' use `opts_sizing(rescale = TRUE)` and set the size of the
#' graphic with `girafe(width_svg=..., height_svg=...)`, this
#' size will define the aspect ratio.
#'
#' @param outputId output variable to read the girafe from. Do not use special JavaScript
#' characters such as a period \code{.} in the id, this would create a JavaScript error.
#' @param width widget width, its default value is set so that the graphic can
#' cover the entire available horizontal space.
#' @param height widget height, its default value is NULL so that width
#' adaptation is not restricted. The height will then be defined according
#' to the width used and the aspect ratio. Only use a value for the height
#' if you have a specific reason and want to strictly control the size.
#' @export
girafeOutput <- function(outputId, width = "100%", height = NULL) {
  # if( "auto" %in% height )
  #   stop("'height:auto' is not supported", call. = FALSE)
  # if( "auto" %in% width )
  #   stop("'width:auto' is not supported", call. = FALSE)

  shinyWidgetOutput(
    outputId,
    "girafe",
    package = "ggiraph",
    width = width,
    height = height
  )
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
renderGirafe <- function(
  expr,
  env = parent.frame(),
  quoted = FALSE,
  outputArgs = list()
) {
  if (!quoted) {
    expr <- substitute(expr)
  } # force quoted
  f <- shinyRenderWidget(expr, girafeOutput, env, quoted = TRUE)
  # shinyRenderWidget is missing outputArgs argument
  # set outputArgs to the result function instead
  if (inherits(f, "shiny.render.function")) {
    attr(f, "outputArgs") <- outputArgs
  }
  f
}

girafe_app_paths <- function() {
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
run_girafe_example <- function(name = "crimes") {
  example_dir <- system.file(package = "ggiraph", "examples", "shiny")
  apps <- girafe_app_paths()
  if (!name %in% basename(apps)) {
    abort(
      "could not find app named ",
      shQuote(name),
      " in the following list: ",
      paste0(shQuote(basename(apps)), collapse = ", "),
      call = NULL
    )
  }
  if (requireNamespace("shiny")) {
    shiny::runApp(
      appDir = file.path(example_dir, name),
      display.mode = "showcase"
    )
  } else {
    warning("package shiny is required to be able to use the function")
  }
}


UUIDgenerate <- function() {
  paste(
    format(as.hexmode(sample(256, 8, replace = TRUE) - 1), width = 2),
    collapse = ""
  )
}
