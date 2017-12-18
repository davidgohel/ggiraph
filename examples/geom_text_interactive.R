library(ggplot2)

## the data
dataset = mtcars
dataset$label = row.names(mtcars)

dataset$tooltip = paste0( "cyl: ", dataset$cyl, "<br/>",
       "gear: ", dataset$gear, "<br/>",
       "carb: ", dataset$carb)

## the plot
gg_text = ggplot(dataset,
                 aes(x = mpg, y = wt, label = label,
                     color = qsec,
                     tooltip = tooltip, data_id = label ) ) +
  geom_text_interactive() +
  coord_cartesian(xlim = c(0,50))

## display the plot
ggiraph(code = {print(gg_text)}, hover_css = "fill:#FF4C3B;font-style:italic;")
