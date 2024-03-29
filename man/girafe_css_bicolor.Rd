% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils_css.R
\name{girafe_css_bicolor}
\alias{girafe_css_bicolor}
\title{Helper for a 'girafe' css string}
\usage{
girafe_css_bicolor(primary = "orange", secondary = "gray")
}
\arguments{
\item{primary, secondary}{colors used to define animations of
fill and stroke properties with text, lines, areas, points
and images in 'girafe' outputs.}
}
\description{
It allows the creation of a css set of individual
styles for animation of 'girafe' elements. The used model is
based on a simple pattern that works \emph{most of the time} for
girafe hover effects and selection effects.

It sets properties based on a primary and a secondary color.
}
\examples{
library(ggplot2)
library(ggiraph)

dat <- mtcars
dat$id <- "id"
dat$label <- "a line"
dat <- dat[order(dat$wt), ]

p <- ggplot(
  data = dat,
  mapping = aes(
    x = wt, y = mpg, data_id = id, tooltip = label)) +
  geom_line_interactive(color = "white", size  = .75,
                        hover_nearest = TRUE) +
  theme_dark() +
  theme(plot.background = element_rect(fill="black"),
        panel.background = element_rect(fill="black"),
        text = element_text(colour = "white"),
        axis.text = element_text(colour = "white")
        )

x <- girafe(
  ggobj = p,
  options = list(
    opts_hover(
      css = girafe_css_bicolor(
        primary = "yellow", secondary = "black"))
))
if (interactive()) print(x)
}
\seealso{
\code{\link[=girafe_css]{girafe_css()}}, \code{\link[=girafe]{girafe()}}
}
