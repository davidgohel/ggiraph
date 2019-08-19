library(ggplot2)
library(ggiraph)


p <- ggplot(mtcars, aes(wt, mpg, label = rownames(mtcars))) +
  geom_label_interactive(aes(tooltip = paste(rownames(mtcars), mpg, sep = "\n")))
x <- girafe(ggobj = p)
if( interactive() ) print(x)


p <- ggplot(mtcars, aes(wt, mpg, label = rownames(mtcars))) +
  geom_label_interactive(aes(fill = factor(cyl),
                             tooltip = paste(rownames(mtcars), mpg, sep = "\n")),
                         colour = "white",
                         fontface = "bold")
x <- girafe(ggobj = p)
if( interactive() ) print(x)

