shinyUI(fluidPage(
  h2("Crimes map"),
  sidebarLayout(

    sidebarPanel(
      actionButton("reset", label = "Reset selection"),
      tags$hr(),
      tags$p(tags$code("data_id"), " values of the selected elements are available through ",
             tags$code("input$ggiraphId_selected"), "."), tags$br(),
      tags$p(tags$code("input$ggiraphId_selected"), " values can be modified with ",
             tags$code("session$sendCustomMessage(type = 'ggiraphId_set', message = character(0))"), "."), tags$br()
    ),

    mainPanel(
      ggiraph::ggiraphOutput("plot"),

      dataTableOutput("datatab")
    )
  )
))
