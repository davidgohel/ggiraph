library(ggplot2)
library(ggiraph)

shinyServer(function(input, output, session) {

  output$plot_ <- renderGirafe({
    data <- mtcars
    data$label <- gsub(pattern = "'", " ", row.names(data) )
    data$onclick <- paste0("set_search_val(\"", data$label, "\");")
    p <- ggplot(aes(x=wt, y=mpg,
                    tooltip = label,
                    data_id = label, onclick = onclick ),data=data) +
      geom_point_interactive(size = 3) + theme_minimal()

    girafe(code = print(p),
           options = list(
             opts_hover(css = "fill:red;cursor:pointer;"),
             opts_selection(type = "single", css = "fill:red;")
           )
           )
  })

  output$dt_ <- DT::renderDataTable({
    mtcars
  })
})
