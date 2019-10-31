library(ggplot2)
library(ggiraph)

shinyServer(function(input, output, session) {

  selected_car <- reactive({
    if( is.null(input$plot_selected)){
      character(0)
    } else input$plot_selected
  })

  output$plot <- renderGirafe({
    p <- ggplot(aes(x=wt,y=mpg, data_id = row.names(mtcars) ),data=mtcars) +
      geom_point_interactive(size = 3) + theme_minimal()
    girafe(
      ggobj = p,
      options = list(
        opts_hover(css = "fill:red;cursor:pointer;"),
        opts_selection(type = "single", css = "fill:red;")
      )
    )
  })

  output$selpoint <- renderUI({
    value <- selected_car()
    if( !isTruthy(value) )
      value <- "<none>"
    tags$div(
      tags$caption("Selected point is:"),
      tags$strong(value)
    )

  })

})
