.onLoad= function(libname, pkgname){
	
	options( "ggiwid" = list( svgid = 0 ) )
	invisible()
}


setGrobName <- function (prefix, grob) 
{
	grob$name <- grobName(grob, prefix)
	grob
}

