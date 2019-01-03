library(shiny)

ui <- bootstrapPage(div(
  class = "container-fluid",
  div(class = "row", div(
    class = "col-sm-12",
    sliderInput("n", "Number of plots", value = 3, min = 1, max = 5, step = 1L),
    uiOutput("plots")
  ))
))

