library(ggplot2)

p <- ggplot(mpg, aes( x = class, tooltip = class,
        data_id = class ) ) +
  geom_bar_interactive()

ggiraph(code = print(p))

dat <- data.frame( name = c( "David", "Constance", "Leonie" ),
    gender = c( "Male", "Female", "Female" ),
    height = c(172, 159, 71 ) )
p <- ggplot(dat, aes( x = name, y = height, tooltip = gender,
        data_id = name ) ) +
  geom_bar_interactive(stat = "identity")

girafe(ggobj = p)
