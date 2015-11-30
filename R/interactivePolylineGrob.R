#' @title Generate an Interactive Grob Path
#' @description This function can be used to generate an interactive grob
#' path.
#'
#' @inheritParams grid::polylineGrob
#' @param tooltip tooltip associated with polylines
#' @param onclick javascript action to execute when polyline is clicked
#' @param data_id identifiers to associate with polylines
#' @export
interactivePolylineGrob <- function(x=unit(c(0, 1), "npc"),
		y=unit(c(0, 1), "npc"),
		id=NULL, id.lengths=NULL,
		tooltip = NULL,
		onclick = NULL,
		data_id = NULL,
		default.units="npc",
		arrow=NULL,
		name=NULL, gp=gpar(), vp=NULL) {
	# Allow user to specify unitless vector;  add default units
	if (!is.unit(x))
		x <- unit(x, default.units)
	if (!is.unit(y))
		y <- unit(y, default.units)
	grob(tooltip = tooltip, onclick = onclick, data_id = data_id,
			x=x, y=y, id=id, id.lengths=id.lengths,
			arrow=arrow, name=name, gp=gp, vp=vp, cl="interactivePolylineGrob")
}

#' @export
#' @title interactivePolylineGrob drawing
#' @description draw an interactivePolylineGrob
#' @inheritParams grid::drawDetails
drawDetails.interactivePolylineGrob <- function(x,recording) {
	rvg_tracer_on()
	argnames = setdiff( names(x), c("tooltip", "onclick", "data_id") )
	do.call( grid.polyline, x[argnames] )

	ids = rvg_tracer_off()
	if( length( ids ) > 0 ) {

		.w = c( TRUE, x$id[-1]!=x$id[-length(x$id)] )
		if( !is.null( x$tooltip ))
			send_tooltip(ids, x$tooltip[.w])
		if( !is.null( x$onclick ))
			send_click(ids, x$onclick[.w])
		if( !is.null( x$data_id ))
			set_data_id(ids, x$data_id[.w])

	}


	invisible()
}



