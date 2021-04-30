library(ggplot2)
library(ggiraph)
library(sf)
library(rnaturalearth)

theme_set(theme_minimal())

world <- ne_countries(scale = "medium", returnclass = "sf")

gg <- ggplot(data = world) +
  geom_sf_interactive(aes(fill = pop_est, tooltip = name_long, data_id = brk_a3), colour = "transparent") +
  scale_fill_viridis_c(option = "plasma", trans = "sqrt") +
  coord_sf(crs = st_crs('ESRI:54030'))



shinyServer(function(input, output, session) {

  selected_states <- reactive({
    if( is.null(input$plot_selected)){
      character(0)
    } else input$plot_selected
  })

  output$plot <- renderGirafe({
    girafe(
      ggobj = gg, width_svg = 7, height_svg = 7,
      options = list(
        opts_hover(css = "fill:#666666;cursor:pointer;"),
        opts_selection(css = "fill:orange;", type = "multiple"),
        opts_zoom(max = 9)
      )
    )
  })
  output$seltext <- renderUI({
    value <- selected_states()
    if( !isTruthy(value) )
      value <- "<none>"
    value <- paste0(value, collapse = ", ")
    tags$div(role="alert", class="alert alert-success",
             tags$h4("Selected states:"),
             tags$p("Your selection is:"),
             tags$hr(),
             tags$p(value)
    )

  })

})
