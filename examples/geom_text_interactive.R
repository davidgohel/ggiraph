## the data
dataset = mtcars
dataset$label = row.names(mtcars)

dataset$tooltip = paste0( "<h5>", row.names(mtcars) ,"</h5>",
                          "<ul><li>cyl:", dataset$cyl, "</li>",
       "<li>gear:", dataset$gear, "</li>",
       "<li>carb:", dataset$carb, "</li></ul>")

## the plot
gg_text = ggplot(dataset,
                 aes(x = mpg, y = wt, label = label,
                     color = qsec,
                     tooltip = tooltip) ) +
  geom_text_interactive() +
  coord_cartesian(xlim = c(0,50))

## display the plot
ggiraph(fun=print, x = gg_text)
