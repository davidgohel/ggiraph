shinyUI(fluidPage(
  tags$h1("ggiraph selection demo"),

  fluidRow(
    column(width = 6,
           h4("Select states: "),
           ggiraph::ggiraphOutput("plot"),
           actionButton("reset", label = "Reset selection", width = "100%")
    ),
    column(width = 6,
           h4("Selected states"),
           tableOutput("datatab")
    )
    )
  )
)


