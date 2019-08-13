shinyUI(fluidPage(
  tags$h1("ggiraph selection demo"),

  fluidRow(
    column(width = 7,
           h4("Select states: "),
           actionButton("reset", label = "Reset selection"),
           ggiraph::ggiraphOutput("plot")
    ),
    column(width = 5,
           h4("Selected states"),
           tableOutput("datatab")
    )
    )
  )
)
