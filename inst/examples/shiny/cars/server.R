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
      geom_point_interactive(size = 4) + theme_minimal()
    girafe(
      ggobj = p,
      width_svg = 7, height_svg = 2/3 * 7,
      options = list(
        opts_hover(css = "fill:red;cursor:pointer;"),
        opts_selection(type = "single", css = "fill:red;"),
        opts_toolbar(saveaspng = FALSE)
      )
    )
  })

  output$selpoint <- renderUI({
    value <- selected_car()
    if( !isTruthy(value) )
      value <- "<none>"
    tags$button(type="button", class="btn btn-danger",
      "Selected point is:",
      tags$span(class="badge", tags$strong(value) )
    )

  })

})
