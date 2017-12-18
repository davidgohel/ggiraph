.onLoad= function(libname, pkgname){

	options( "ggiwid" = list( svgid = 0 ) )
	invisible()
}


setGrobName <- function (prefix, grob)
{
	grob$name <- grobName(grob, prefix)
	grob
}

encode_cr <- function(x)
  gsub(pattern = "\n", replacement = "<br>", x = x)



zoom_logo_on = "<svg width='15pt' height='15pt' viewBox='0 0 512 512'><g><ellipse ry='150' rx='150' cy='213' cx='203.5' stroke-width='50' fill='transparent'/><line y2='455.5' x2='416' y1='331.5' x1='301' stroke-width='50'/></g></svg>";
zoom_logo_off = "<svg width='15pt' height='15pt' viewBox='0 0 512 512'><g><ellipse ry='150' rx='150' cy='213' cx='203.5' stroke-width='50' fill='transparent'/><line y2='455.5' x2='416' y1='331.5' x1='301' stroke-width='50'/><line y2='455' x2='0' y1='0' x1='416' stroke-width='30'/></g></svg>";
lasso_logo = "<svg width='15pt' height='15pt' viewBox='0 0 230 230'><g><ellipse ry='65.5' rx='86.5' cy='94' cx='115.5' stroke-width='20' fill='transparent'/><ellipse ry='11.500001' rx='10.5' cy='153' cx='91.5' stroke-width='20' fill='transparent'/><line y2='210.5' x2='105' y1='164.5' x1='96' stroke-width='20'/></g></svg>";
arrow_expand_logo = "<svg width='15pt' height='15pt' viewBox='0 0 512 512'><g><polygon points='274,209.7 337.9,145.9 288,96 416,96 416,224 366.1,174.1 302.3,238 '/><polygon points='274,302.3 337.9,366.1 288,416 416,416 416,288 366.1,337.9 302.3,274'/><polygon points='238,302.3 174.1,366.1 224,416 96,416 96,288 145.9,337.9 209.7,274'/><polygon points='238,209.7 174.1,145.9 224,96 96,96 96,224 145.9,174.1 209.7,238'/></g><svg>";

ui_div <- function(id, zoomable, letlasso, sel_array_name, selected_class){

  bar_ <- "<div class='ggiraph-toolbar'>";
  if( letlasso ){
    bar_ <- paste0(bar_,
                   "<div class='ggiraph-toolbar-block shinyonly'>",
                   sprintf("<a class='ggiraph-toolbar-icon neutral' title='lasso selection' href='javascript:lasso_on(\"%s\", true, \"%s\", \"%s\");'>",
                           id, sel_array_name, selected_class),
                   lasso_logo, "</a>",
                   sprintf("<a class='ggiraph-toolbar-icon drop' title='lasso anti-selection' href='javascript:lasso_on(\"%s\", false, \"%s\", \"%s\");'>", id, sel_array_name, selected_class),
                   lasso_logo, "</a>", "</div>")
  }
  if( zoomable ){
    bar_ <- paste0(bar_,
                   "<div class='ggiraph-toolbar-block'>",
                   "<a class='ggiraph-toolbar-icon neutral' title='pan-zoom reset' href='javascript:zoom_identity(\"",
                   id,
                   "\");'>",
                   arrow_expand_logo,
                   "</a>",
                   "<a class='ggiraph-toolbar-icon neutral' title='activate pan-zoom' href='javascript:zoom_on(\"",
                   id, "\");'>",
                   zoom_logo_on,
                   "</a>",
                   "<a class='ggiraph-toolbar-icon neutral' title='desactivate pan-zoom' href='javascript:zoom_off(\"",
                   id,
                   "\");'>", zoom_logo_off, "</a>",
                   "</div>")
  }
  paste0(bar_, "</div>")
}

#
ui_div2 <- function(id, zoomable, letlasso, sel_array_name, selected_class, zoom_name){

  bar_ <- "<div class='ggiraph-toolbar'>";
  if( letlasso ){
    bar_ <- paste0(bar_,
                   "<div class='ggiraph-toolbar-block shinyonly'>",
                   sprintf("<a class='ggiraph-toolbar-icon neutral' title='lasso selection' href='javascript:lasso_on(\"%s\", true, \"%s\", \"%s\");'>",
                           id, sel_array_name, selected_class),
                   lasso_logo, "</a>",
                   sprintf("<a class='ggiraph-toolbar-icon drop' title='lasso anti-selection' href='javascript:lasso_on(\"%s\", false, \"%s\", \"%s\");'>", id, sel_array_name, selected_class),
                   lasso_logo, "</a>", "</div>")
  }
  if( zoomable ){
    bar_ <- paste0(bar_,
                   "<div class='ggiraph-toolbar-block'>",
                   "<a class='ggiraph-toolbar-icon neutral' title='pan-zoom reset' href='javascript:zoom_identity_ggiraph(\"",
                   id,
                   "\", ", zoom_name, ");'>",
                   arrow_expand_logo,
                   "</a>",
                   "<a class='ggiraph-toolbar-icon neutral' title='activate pan-zoom' href='javascript:zoom_on_ggiraph(\"",
                   id, "\", ", zoom_name, ");'>",
                   zoom_logo_on,
                   "</a>",
                   "<a class='ggiraph-toolbar-icon neutral' title='desactivate pan-zoom' href='javascript:zoom_off_ggiraph(\"",
                   id,
                   "\", ", zoom_name, ");'>", zoom_logo_off, "</a>",
                   "</div>")
  }
  paste0(bar_, "</div>")
}

#
