library(ggplot2)
library(ggiraph)
library(maps)


shinyServer(function(input, output, session) {

  # selected_car <- reactive({
  #   if( is.null(input$plot_selected)){
  #     character(0)
  #   } else input$plot_selected
  # })

  output$plot_ <- renderggiraph({
    data <- mtcars
    data$label <- gsub(pattern = "'", " ", row.names(data) )
    data$onclick <- paste0("set_search_val(\"", data$label, "\");")
    p <- ggplot(aes(x=wt, y=mpg,
                    tooltip = label,
                    data_id = label, onclick = onclick ),data=data) +
      geom_point_interactive(size = 3) + theme_minimal()

    ggiraph(code = print(p),
            hover_css = "fill:red;cursor:pointer;",
            selection_type = "single",
            selected_css = "fill:red;")
  })

  output$dt_ <- DT::renderDataTable({
    mtcars
  })
})