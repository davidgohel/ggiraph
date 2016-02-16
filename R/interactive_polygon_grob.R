#' @title Generate interactive grob polygons
#' @description This function can be used to generate interactive grob
#' polygons.
#'
#' @inheritParams grid::polygonGrob
#' @param tooltip tooltip associated with polygons
#' @param onclick javascript action to execute when polygon is clicked
#' @param data_id identifiers to associate with polygons
#' @export
interactive_polygon_grob <- function(x=unit(c(0, 1), "npc"),
		y=unit(c(0, 1), "npc"),
		id=NULL, id.lengths=NULL,
		tooltip = NULL,
		onclick = NULL,
		data_id = NULL,
		default.units="npc",
		name=NULL, gp=gpar(), vp=NULL) {
	# Allow user to specify unitless vector;  add default units
	if (!is.unit(x))
		x <- unit(x, default.units)
	if (!is.unit(y))
		y <- unit(y, default.units)
	grob(tooltip = tooltip, onclick = onclick, data_id = data_id,
			x=x, y=y, id=id, id.lengths=id.lengths,
			name=name, gp=gp, vp=vp, cl="interactive_polygon_grob")
}

#' @export
#' @title interactive_polygon_grob drawing
#' @description draw an interactive_polygon_grob
#' @inheritParams grid::drawDetails
drawDetails.interactive_polygon_grob <- function(x,recording) {
	rvg_tracer_on()
	argnames = setdiff( names(x), c("tooltip", "onclick", "data_id") )
	do.call( grid.polygon, x[argnames] )
	ids = rvg_tracer_off()
	if( length( ids ) > 0 ) {

	  if( is.null(x$id) )
	    x$id <- rep( 1, length(x$x) )

	  posid = which(!duplicated(x$id))

	  if( !is.null( x$tooltip ))
	    set_attr( ids = as.integer( ids ), str = x$tooltip[posid], attribute = "title" )
	  if( !is.null( x$onclick ))
	    set_attr( ids = as.integer( ids ), str = x$onclick[posid], attribute = "onclick" )
	  if( !is.null( x$data_id ))
	    set_attr( ids = as.integer( ids ), str = x$data_id[posid], attribute = "data-id" )

	}


	invisible()
}


