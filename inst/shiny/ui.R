shinyUI(fluidPage(
  h2("Crimes map"),
  sidebarLayout(

    sidebarPanel(

      h4("Details", class = "section-title"),

      tags$blockquote("ui.R"),
      p(span("Declare a javascript variable"),
        tags$code("state"), span(":") ),
      p(tags$code("tags$script('var state = null;')")),

      tags$blockquote("server.R"),
      p(span("Make that variable reactive:")),
      p(tags$code("state <- reactive({input$state})")),

      tags$blockquote("ggplot commands ",
         tags$i("(use data_id and onclick arguments with ggplot):") ),
      tags$p(
        tags$strong("onclick"),
        tags$i("the javascript function to execute on click"),
        tags$code("{var dataid = d3.select(this).attr(\"data-id\");Shiny.onInputChange(\"state\", dataid);}") ),
      tags$p(
        tags$strong("data_id"),
        tags$i("assign data id to elements."),
        tags$span("Elements with a data id attribute will be animated when mouse will be over.") ),
      tags$script("var state = null;")

    ),

    mainPanel(
      ggiraph::ggiraphOutput("plot"),
      inputPanel(
        actionButton("reset", label = "Reset selection", onclick = "{Shiny.onInputChange('state', null);}")
      ),
      dataTableOutput("datatab")
    )
  )
))


