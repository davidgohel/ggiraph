shinyUI(fluidPage(
  tags$h1("ggiraph demo"),

  fluidRow(
    column(width = 6,
           h4("Selected states"),
           tableOutput("datatab")
    ),
    column(width = 6,
           textInput("title", label = "Title", placeholder = "type graph title"),
           ggiraph::ggiraphOutput("plot"),
           actionButton("reset", label = "Reset selection", width = "100%")
    ) )
  )
)


