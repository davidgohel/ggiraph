.onLoad= function(libname, pkgname){
	
	options( "ggiwid" = list( id = 0 ) )
	invisible()
}


rm.na <- function(dataset, vars = names(dataset) ) {
		
	.w <- !stats::complete.cases(dataset[, intersect(vars, names(dataset)), drop = FALSE])
	
	if (any(.w)) {
		dataset <- dataset[!.w, ]
	}
	
	dataset
}

ggname <- function (prefix, grob) 
{
	grob$name <- grobName(grob, prefix)
	grob
}

.pt <- 1 / 0.352777778
.stroke <- 96 / 25.4



zeroGrob <- function() .zeroGrob

.zeroGrob <- grob(cl = "zeroGrob", name = "NULL")

#' @export
#' @method widthDetails zeroGrob
widthDetails.zeroGrob <- function(x) unit(0, "cm")

#' @export
#' @method heightDetails zeroGrob
heightDetails.zeroGrob <- function(x) unit(0, "cm")

#' @export
#' @method grobWidth zeroGrob
grobWidth.zeroGrob <- function(x) unit(0, "cm")

#' @export
#' @method grobHeight zeroGrob
grobHeight.zeroGrob <- function(x) unit(0, "cm")

#' @export
#' @method drawDetails zeroGrob
drawDetails.zeroGrob <- function(x, recording) {}
