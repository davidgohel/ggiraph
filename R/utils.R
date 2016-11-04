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

