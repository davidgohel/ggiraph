shinyUI(fluidPage(
  tags$h1("girafe CSS class demo"),

  tags$style(HTML(
    ".highlighted { fill: red !important; stroke: black !important; r: 8 !important; }"
  )),

  fluidRow(
    column(
      width = 7,
      ggiraph::girafeOutput("plot")
    ),
    column(
      width = 5,
      h4("Class manipulation"),
      textInput("data_ids", label = "data-id values (comma separated)",
                value = "florida, texas"),
      fluidRow(
        column(4, actionButton("btn_add", label = "Add class")),
        column(4, actionButton("btn_remove", label = "Remove class")),
        column(4, actionButton("btn_toggle", label = "Toggle class"))
      ),
      hr(),
      h4("Current selection (hover)"),
      verbatimTextOutput("console")
    )
  )
))
