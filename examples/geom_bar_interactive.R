library(ggplot2)
library(ggiraph)

p <- ggplot(mpg, aes( x = class, tooltip = class,
        data_id = class ) ) +
  geom_bar_interactive()

x <- girafe(ggobj = p)
if( interactive() ) print(x)

dat <- data.frame( name = c( "David", "Constance", "Leonie" ),
    gender = c( "Male", "Female", "Female" ),
    height = c(172, 159, 71 ) )
p <- ggplot(dat, aes( x = name, y = height, tooltip = gender,
        data_id = name ) ) +
  geom_bar_interactive(stat = "identity")

x <- girafe(ggobj = p)
if( interactive() ) print(x)

p <- ggplot(diamonds, aes(carat)) +
  geom_histogram_interactive(bins=30, aes(tooltip = ..count..,
                             data_id = carat) )

x <- girafe(ggobj = p)
if( interactive() ) print(x)

# an example with interactive guide ----
dat <- data.frame(
  name = c( "Guy", "Ginette", "David", "Cedric", "Frederic" ),
  gender = c( "Male", "Female", "Male", "Male", "Male" ),
  height = c(169, 160, 171, 172, 171 ) )
p <- ggplot(dat, aes( x = name, y = height, fill = gender,
                      data_id = name ) ) +
  geom_bar_interactive(stat = "identity") +
    scale_fill_manual_interactive(
      values = c(Male = "#0072B2", Female = "#009E73"),
      data_id = c(Female = "Female", Male = "Male"),
      tooltip = c(Male = "Male", Female = "Female")
    )
x <- girafe(ggobj = p)
if( interactive() ) print(x)
