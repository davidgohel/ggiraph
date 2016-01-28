# create dataset
dataset = iris
dataset$tooltip = dataset$Species
dataset$clickjs = paste0("function() {alert('",dataset$Species, "')}" )

# plots
gg_point = ggplot(dataset, aes(x = Sepal.Length, y = Petal.Width,
		color = Species, tooltip = tooltip, onclick = clickjs) ) +
	geom_point_interactive()

ggiraph(code = {print(gg_point)})
