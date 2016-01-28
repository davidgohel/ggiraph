    shinyUI(
      fluidPage(
        title = "ggiraph demo",
        tags$script("var state = null;"),
        titlePanel("Crimes map"),
        fluidRow(
    
            ggiraph::ggiraphOutput("plot"),
            shiny::inputPanel(
              actionButton("reset",
                           label = "Reset selection",
                           onclick = "{Shiny.onInputChange('state', null);}")
            ),
            dataTableOutput("datatab")
    
        )
      )
    )
