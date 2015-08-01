# create dataset 
dataset = iris
dataset$tooltip = paste0( "Species <br/>", dataset$Species )
dataset$clickjs = paste0("alert('",dataset$Species, "');" )

# plots
gg_point_1 = ggplot(dataset, aes(x = Sepal.Length, y = Petal.Width, 
		color = Species, tooltips = tooltip, clicks=clickjs) ) + 
	geom_point_interactive()

gg_point_2 = ggplot(dataset, aes(x = Sepal.Length, y = Petal.Width, 
		tooltips = tooltip, clicks=clickjs) ) + 
	geom_point_interactive() + facet_wrap( ~ Species )

ggiraph(fun=print, x = gg_point_1)
ggiraph(fun=print, x = gg_point_2)
