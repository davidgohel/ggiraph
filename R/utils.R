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

setGrobName <- function (prefix, grob) 
{
	grob$name <- grobName(grob, prefix)
	grob
}

ggplot2.pt <- 1 / 0.352777778
ggplot2.stroke <- 96 / 25.4



