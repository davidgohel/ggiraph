library(ggiraph)

shinyUI(fluidPage(
  tags$h1("EXPLORING THE CRAN SOCIAL NETWORK"),
  fluidRow(
    column(
      width=12,
      ggiraphOutput("plot")
    )
  ),
  fluidRow(
    column(
      width=4, offset = 1,
      selectizeInput("selpoint", label = "Choose authors: ", choices = aut_list$Name, multiple = TRUE )
    )
  ),
  fluidRow(
    column(
      width=5, offset = 1,
      sliderInput(inputId = "rowsel_min", step = 1L, label = "Rows", min = 0, max = 0, value = 0)
    ),
    column(
      width=5,
      sliderInput(inputId = "rowsel_max", step = 1L, label = "Rows", min = 0, max = 0, value = 0)
    )
  ),
  fluidRow(
    column(
      width=12,
      uiOutput("subset")
    )
  )
))
