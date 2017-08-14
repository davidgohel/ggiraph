#' @import htmlwidgets
#' @import htmltools
#' @import rvg
#' @import grid
#' @importFrom grDevices dev.off
#' @importFrom xml2 read_xml xml_find_all xml_text xml_ns
#' @importFrom xml2 xml_remove xml_attr xml_attr<-
#' @importFrom uuid UUIDgenerate

#' @title create a ggiraph object
#'
#' @description Create an interactive graphic to be used in a web browser.
#'
#' Use \code{geom_zzz_interactive} to create interactive graphical elements.
#'
#' Difference from original functions is that the following
#' aesthetics are understood: \code{tooltip}, \code{onclick}
#' and \code{data_id}.
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
#' When \code{zoom_max} is set, "zoom activate", "zoom desactivate" and
#' "zoom init" buttons are available in a toolbar.
#'
#' When \code{selection} is set to multiple (in Shiny applications), lasso
#' selection and lasso anti-selections buttons are available in a toolbar.
#'
#' @param code Plotting code to execute
#' @param ggobj ggplot objet to print. argument \code{code} will
#' be ignored if this argument is supplied.
#' @param pointsize the default pointsize of plotted text in pixels, default to 12.
#' @param width_svg,height_svg svg viewbox width and height in inches
#' @param tooltip_extra_css extra css (added to \code{position: absolute;pointer-events: none;})
#' used to customize tooltip area.
#' @param hover_css css to apply when mouse is hover and element with a data-id attribute.
#' @param tooltip_opacity tooltip opacity
#' @param tooltip_offx tooltip x offset
#' @param tooltip_offy tooltip y offset
#' @param tooltip_zindex tooltip css z-index, default to 999.
#' @param zoom_max maximum zoom factor
#' @param selection_type row selection mode ("single", "multiple", "none")
#'  when widget is in a Shiny application.
#' @param selected_css css to apply when element is selected (shiny only).
#' @param width deprecated
#' @param flexdashboard should be TRUE when used within a flexdashboard to
#' ensure svg will fit in boxes.
#' @param ... arguments passed on to \code{\link[rvg]{dsvg}}
#' @examples
#' # ggiraph simple example -------
#' @example examples/geom_point_interactive.R
#' @export
ggiraph <- function(code, ggobj = NULL,
	pointsize = 12, width = NULL,
	width_svg = 6, height_svg = 6,
	tooltip_extra_css,
	hover_css,
	tooltip_opacity = .9,
	tooltip_offx = 10,
	tooltip_offy = 0,
	tooltip_zindex = 999,
	zoom_max = 1,
	selection_type = "multiple",
	selected_css, flexdashboard = FALSE,
	...) {

  if( missing( tooltip_extra_css ))
    tooltip_extra_css <- "padding:5px;background:black;color:white;border-radius:2px 2px 2px 2px;"
  if( missing( hover_css ))
    hover_css <- "fill:orange;stroke:gray;"
  if( missing( selected_css ))
    selected_css <- hover_css

  if( !is.null(width) )
    warning("argument 'width' is deprecated and will have no effect.")

  stopifnot(selection_type %in% c("single", "multiple", "none"))
  stopifnot(is.numeric(tooltip_offx))
  stopifnot(is.numeric(tooltip_offy))
  stopifnot(is.numeric(tooltip_opacity))
  stopifnot(tooltip_opacity > 0 && tooltip_opacity <= 1)
  stopifnot(tooltip_opacity > 0 && tooltip_opacity <= 1)
  stopifnot(is.numeric(zoom_max))

  if( zoom_max < 1 )
    stop("zoom_max should be >= 1")

	ggiwid.options = getOption("ggiwid")
	tmpdir = tempdir()
	path = tempfile()
	canvas_id <- ggiwid.options$svgid
	dsvg(file = path, pointsize = pointsize, standalone = TRUE,
			width = width_svg, height = height_svg,
			canvas_id = canvas_id, ...
		)
	tryCatch({
	  if( !is.null(ggobj) ){
	    stopifnot(inherits(ggobj, "ggplot"))
	    print(ggobj)
	  } else
	    code
	  }, finally = dev.off() )

	ggiwid.options$svgid = 1 + ggiwid.options$svgid
	options("ggiwid"=ggiwid.options)

	data <- read_xml( path )
	scr <- xml_find_all(data, "//*[@type='text/javascript']", ns = xml_ns(data) )
	js <- paste( sapply( scr, xml_text ), collapse = ";")

	xml_remove(scr)
  xml_attr(data, "width") <- NULL
  xml_attr(data, "height") <- NULL

  if( flexdashboard )
    xml_attr(data, "class") <- "svg-inline-container"
  else xml_attr(data, "class") <- "svg-responsive-container"

	if( grepl(x = tooltip_extra_css, pattern = "position[ ]*:") )
	  stop("please, do not specify position in tooltip_extra_css, this parameter is managed by ggiraph.")
	if( grepl(x = tooltip_extra_css, pattern = "pointer-events[ ]*:") )
	  stop("please, do not specify pointer-events in tooltip_extra_css, this parameter is managed by ggiraph.")


	unlink(path)
	scale_ <- 100
	ratio_ <- width_svg / height_svg
	if( flexdashboard )
  	style_container <- paste0("style='",
  	  sprintf("%s:%.0f%%;", "padding-top", 1 / ratio_ * scale_),
  	  sprintf("%s:%.0f%%;", "width", scale_), "' " )
	else style_container <- ""

  id <- gsub("-", "", paste0("uid", UUIDgenerate() ))

  dep_dir <- tempfile()
  dir.create(dep_dir)

  init_prop_name <- paste0("init_prop_", id)
  array_selected_name <- paste0("array_selected_", id)
  zoom_name <- paste0("zoom_", id)
  lasso_name <- paste0("lasso_", id)
  class_selected_name <- paste0("clicked_", id)
  widget_id <- paste0("widget_", id)
  ratio_id <- paste0("ratio_", id)
  is_flexdashboard_id <- paste0("fd_", id)


  js <- paste0("function ", init_prop_name, "(){", js, "};")
  js <- paste0(js, paste0("var ", array_selected_name, " = [];") )
  js <- paste0(js, sprintf("var %s = %.3f;", ratio_id, ratio_) )
  js <- paste0(js, sprintf("var %s = d3.zoom().scaleExtent([%.02f, %.02f]);", zoom_name, 1, zoom_max) )
  js <- paste0(js, sprintf("var %s = d3.lasso();", lasso_name) )
  js <- paste0(js, sprintf("var %s = '';", widget_id) )
  js <- paste0(js, sprintf("var %s = %.0f;", is_flexdashboard_id, flexdashboard) )

  js_file <- file.path(dep_dir, paste0("scripts_", id, ".js"))
  cat(js, file = js_file)

  css <- paste0("div.tooltip_", id,
                sprintf( " {position:absolute;pointer-events:none;z-index:%.0f;", tooltip_zindex),
                tooltip_extra_css, "}\n",
                ".cl_data_id_", id, ":{}.cl_data_id_", id, ":hover{", hover_css, "}\n",
                ".", class_selected_name, "{", selected_css, "}"
                )

  dep <- htmlDependency(id, "0.0.1", src = dep_dir, script = basename(js_file) )
  ui_div_ <- ui_div(id = id, zoomable = (zoom_max > 1),
                    letlasso = selection_type %in% "multiple",
                    array_selected_name, class_selected_name )

  div_class <- ""
  if( flexdashboard ) div_class <- "class='container' "
  html_ <- paste0("<div id='", id, "' ", div_class, style_container, ">",
                  as.character(data), ui_div_,
                  "<style>", css, "</style>",
                  "</div>")
  x = list( html = html_, uid = id,
            funname = init_prop_name,
            sel_array_name = array_selected_name,
            selected_class = class_selected_name,
            tooltip_opacity = tooltip_opacity,
            tooltip_offx = tooltip_offx, tooltip_offy = tooltip_offy,
            zoom_max = zoom_max,
            selection_type = selection_type, flexdashboard = flexdashboard)

  htmlwidgets::createWidget(dependencies = list(dep),
                            name = 'ggiraph', x = x, package = 'ggiraph',
                            sizingPolicy = sizingPolicy(knitr.figure = FALSE)
  )

}

#' @title Create a ggiraph output element
#' @description Render a ggiraph within an application page.
#'
#' @param outputId output variable to read the ggiraph from.
#' @param width widget width
#' @param height widget height
#' @examples
#' \dontrun{
#' if( require(shiny) && interactive() ){
#'   app_dir <- file.path( system.file(package = "ggiraph"), "shiny/cars" )
#'   shinyAppDir(appDir = app_dir )
#'  }
#' if( require(shiny) && interactive() ){
#'   app_dir <- file.path( system.file(package = "ggiraph"), "shiny/crimes" )
#'   shinyAppDir(appDir = app_dir )
#' }
#' }
#' @export
ggiraphOutput <- function(outputId, width = "100%", height = "500px"){

  shinyWidgetOutput(outputId, 'ggiraph', package = 'ggiraph', width = width, height = height)
}

#' @title Reactive version of ggiraph object
#'
#' @description Makes a reactive version of a ggiraph object for use in Shiny.
#'
#' @param expr An expression that returns a \code{\link{ggiraph}} object.
#' @param env The environment in which to evaluate expr.
#' @param quoted Is \code{expr} a quoted expression
#' @examples
#' \dontrun{
#' if( require(shiny) && interactive() ){
#'   app_dir <- file.path( system.file(package = "ggiraph"), "shiny" )
#'   shinyAppDir(appDir = app_dir )
#' }
#' }
#' @export
renderggiraph <- function(expr, env = parent.frame(), quoted = FALSE) {
	if (!quoted) { expr <- substitute(expr) } # force quoted
	shinyRenderWidget(expr, ggiraphOutput, env, quoted = TRUE)
}









