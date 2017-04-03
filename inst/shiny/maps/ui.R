library(ggiraph)
library(shiny)
shinyUI(fluidPage(

  # Application title
  titlePanel("Select states on the map"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      textInput("sel", label = "Selected states")
    ),

    # Show a plot of the generated distribution
    mainPanel(
      ggiraphOutput("plot")
    )
  )
))
