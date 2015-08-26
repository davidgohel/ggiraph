
# create datasets -----
id = paste0("id", 1:10) 
data = expand.grid(list( 
	variable = c("2000", "2005", "2010", "2015"), 
	id = id
	)
)
groups = sample(LETTERS[1:3], size = length(id), replace = T)
data$group = groups[match(data$id, id)]
data$value = runif(n = nrow(data))
data$tooltips = paste0('id ', data$id )
data$clicks = paste0("function() {alert('", data$id, "')}" )

cols = c("orange", "orange1", "orange2", "navajowhite4", "navy")
dataset2 <- data.frame(x = rep(1:20, 5), 
		y = rnorm(100, 5, .2) + rep(1:5, each=20), 
		z = rep(1:20, 5), 
		grp = factor(rep(1:5, each=20)),
		color = factor(rep(1:5, each=20)),
		label = paste0( "id ", round( runif(100)*10^8 ) )
)


# plots ---
gg_path_1 = ggplot(data, aes(variable, value, group = id, 
		colour = group, tooltips = tooltips, clicks = clicks)) +
	geom_path_interactive(alpha = 0.5)

gg_path_2 = ggplot(data, aes(variable, value, group = id, 
		tooltips = tooltips)) +
	geom_path_interactive(alpha = 0.5) + 
	facet_wrap( ~ group )

gg_path_3 = ggplot(dataset2) +
	geom_path_interactive(aes(x, y, group=grp, 
		color = color, tooltips = label) )

# ggiraph widgets ---
ggiraph(fun=print, x = gg_path_1)
ggiraph(fun=print, x = gg_path_2)
ggiraph(fun=print, x = gg_path_3)
