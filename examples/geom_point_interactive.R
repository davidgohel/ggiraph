# create dataset 
dataset = iris
dataset$tooltip = paste0( "Species <br/>", dataset$Species )
dataset$clickjs = paste0("function() {alert('",dataset$Species, "')}" )

# plots
gg_point_1 = ggplot(dataset, aes(x = Sepal.Length, y = Petal.Width, 
		color = Species, tooltip = tooltip, onclick=clickjs) ) + 
	geom_point_interactive()

gg_point_2 = ggplot(dataset, aes(x = Sepal.Length, y = Petal.Width, 
		tooltip = tooltip, onclick=clickjs) ) + 
	geom_point_interactive() + facet_wrap( ~ Species )

ggiraph(fun=print, x = gg_point_1)
ggiraph(fun=print, x = gg_point_2)
