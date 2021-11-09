library(ggplot2)
library(ggiraph)

df <- expand.grid(x = 1:10, y=1:10)
df$angle <- runif(100, 0, 2*pi)
df$speed <- runif(100, 0, sqrt(0.1 * df$x))

p <- ggplot(df, aes(x, y)) +
  geom_point() +
  geom_spoke_interactive(aes(angle = angle, tooltip=round(angle, 2)), radius = 0.5)
x <- girafe(ggobj = p)
if( interactive() ) print(x)

p2 <- ggplot(df, aes(x, y)) +
  geom_point() +
  geom_spoke_interactive(aes(angle = angle, radius = speed,
                             tooltip=paste(round(angle, 2), round(speed, 2), sep="\n")))
x2 <- girafe(ggobj = p2)
if( interactive() ) print(x2)
