library(ggplot2)
library(ggiraph)

crimes <- data.frame(state = tolower(rownames(USArrests)), USArrests)

gg_crime <- ggplot(crimes, aes(x = Murder, y = Assault, colour = UrbanPop)) +
  geom_point_interactive(
    aes(data_id = state, tooltip = state), size = 3,
    hover_nearest = TRUE
  ) +
  scale_colour_gradient(low = "#999999", high = "orange") +
  theme_minimal()

shinyServer(function(input, output, session) {

  output$plot <- renderGirafe({
    girafe(
      code = print(gg_crime),
      width_svg = 6, height_svg = 5,
      options = list(
        opts_hover(css = "cursor:pointer;", reactive = TRUE)
      )
    )
  })

  output$console <- renderPrint({
    input$plot_hovered
  })

  get_ids <- reactive({
    ids <- trimws(unlist(strsplit(input$data_ids, ",")))
    ids[nzchar(ids)]
  })

  observeEvent(input$btn_add, {
    ids <- get_ids()
    if (length(ids) > 0) {
      girafe_class_add(session, "plot", "highlighted", data_id = ids)
    }
  })

  observeEvent(input$btn_remove, {
    ids <- get_ids()
    if (length(ids) > 0) {
      girafe_class_remove(session, "plot", "highlighted", data_id = ids)
    }
  })

  observeEvent(input$btn_toggle, {
    ids <- get_ids()
    if (length(ids) > 0) {
      girafe_class_toggle(session, "plot", "highlighted", data_id = ids)
    }
  })
})
