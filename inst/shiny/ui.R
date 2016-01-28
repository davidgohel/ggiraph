library(shiny)

shinyUI(fluidPage(
  title = "ggiraph demo",
  tags$script("var state = null;"),
  # Application title
  titlePanel("Crimes map"),

  fluidRow(column(7,

      ggiraph::ggiraphOutput("plot"),

      shiny::inputPanel(
        actionButton("reset", label = "Reset selection", onclick = "{Shiny.onInputChange('state', null);}")
      ),
      dataTableOutput("datatab")
    ),
    column(5,
           wellPanel(
           h4("Details", class = "section-title"),
           h5("ui.R", class = "section-title"),
           p(span("Declare a javascript variable"),
             tags$code("state"), span(":") ),
           p(tags$code("tags$script('var state = null;')")),
           h5("server.R", class = "section-title"),
           p(span("Make that variable reactive:")),
           p(tags$code("state <- reactive({input$state})")),
           h5("ggplot commands", class = "section-title"),
           p(span("use data_id and onclick arguments with ggplot:")),
           tags$li(
              tags$ul(
                  tags$strong("onclick"),
                  tags$i("the javascript function to execute on click"),
                        tags$code("function() {var dataid = jQuery(this).attr(\"data-id\");\
Shiny.onInputChange(\"state\", dataid);}") ),
              tags$ul(
                tags$strong("data_id"),
                tags$i("assign data id to elements."), tags$span("Elements with a data id attribute will be animated when mouse will be over.") )
                   )
    ))
  ),
  fluidRow(
    column(12,h3("code"))
    ),
  fluidRow(
    column(1), column(10,
      tabsetPanel(
        tabPanel(title = "File ui.R",
          includeMarkdown("ui.md") ),
        tabPanel(title = "ggplot code",
          includeMarkdown("ggplot.md") ),
        tabPanel(title = "File server.R",
          includeMarkdown("server.md") )
      )
    ), column(1)
  ))
)

