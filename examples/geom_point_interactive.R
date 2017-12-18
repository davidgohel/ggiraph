library(ggplot2)

# create dataset
dataset = mtcars
dataset$carname = row.names(mtcars)

# plots
gg_point = ggplot(
  data = dataset,
  mapping = aes(x = wt, y = qsec, color = disp,
                tooltip = carname, data_id = carname) ) +
	geom_point_interactive() + theme_minimal()

ggiraph(ggobj = gg_point, width = .7 )
