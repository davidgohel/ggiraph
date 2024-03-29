library(ggplot2)
library(ggiraph)

m <- ggplot(faithful, aes(x = eruptions, y = waiting)) +
  geom_point_interactive(aes(tooltip = paste("Waiting:", waiting, "\neruptions:", eruptions))) +
  xlim(0.5, 6) +
  ylim(40, 110)
p <- m + geom_density_2d_interactive(aes(tooltip = paste("Level:", after_stat(level))))
x <- girafe(ggobj = p)
if (interactive()) print(x)

set.seed(4393)
dsmall <- diamonds[sample(nrow(diamonds), 1000), ]
d <- ggplot(dsmall, aes(x, y))


p <- d + geom_density_2d_interactive(aes(colour = cut, tooltip = cut, data_id = cut))
x <- girafe(ggobj = p)
x <- girafe_options(x = x,
                    opts_hover(css = "stroke:red;stroke-width:3px;") )
if (interactive()) print(x)

p <- d + geom_density_2d_filled_interactive(aes(colour = cut, tooltip = cut, data_id = cut),
                                            contour_var = "count") + facet_wrap(vars(cut))
x <- girafe(ggobj = p)
x <- girafe_options(x = x,
                    opts_hover(css = "stroke:red;stroke-width:3px;") )
if (interactive()) print(x)


p <- d + stat_density_2d(aes(fill = after_stat(nlevel),
                             tooltip = paste("nlevel:", after_stat(nlevel))),
                         geom = "interactive_polygon") +
  facet_grid(. ~ cut) + scale_fill_viridis_c_interactive(tooltip = "nlevel")
x <- girafe(ggobj = p)
if (interactive()) print(x)

