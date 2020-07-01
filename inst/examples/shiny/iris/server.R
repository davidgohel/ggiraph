library(ggplot2)
library(ggiraph)

shinyServer(function(input, output, session) {

  selected_car <- reactive({
    if( is.null(input$plot_selected)){
      character(0)
    } else input$plot_selected
  })

  output$plot <- renderGirafe({
    p <- ggplot(aes(x=Sepal.Length,y=Petal.Length, data_id = Species ),data=iris) +
      geom_point_interactive(size = 3) + theme_minimal()
    girafe(
      ggobj = p,
      options = list(
        opts_hover(css = "fill:red;cursor:pointer;"),
        opts_selection(type = "single", css = "fill:orange;")
      )
    )
  })
  output$selpoint <- renderUI({
    value <- selected_car()
    if( !isTruthy(value) )
      value <- "<none>"
    tags$button(type="button", class="btn btn-danger",
                "Selected data_id is:",
                tags$span(class="badge", tags$strong(value) )
    )

  })

})
