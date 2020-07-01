library(ggiraph)
library(ggplot2)
library(tidyverse)

theme_set(theme_minimal())

data <- esoph %>% mutate(ncontrols = ncontrols - ncases) %>%
  rename(yes = "ncases", no = "ncontrols") %>%
  pivot_longer(
  cols = c("yes", "no"),
  names_to = "cancer", values_to = "count")


shinyServer(function(input, output, session) {

  output$fixedplot <-renderGirafe({
    gg <- ggplot(data = data,
      mapping = aes( x = agegp, tooltip = agegp, data_id = agegp ) ) +
      geom_bar_interactive()
    girafe(ggobj = gg, options = list(opts_selection(type = "single")))
  })

  key_selected <- reactive({
    input$modalplot_key_selected
  })

  datasubset <- reactive({
    selected_cut <-  input$fixedplot_selected
    data <- filter(data, agegp %in% selected_cut) %>%
      group_by(alcgp, cancer) %>%
      summarise(count = sum(count), .groups = "drop")
    data$transparent = "no"
    data$transparent[!data$cancer %in% key_selected()] <- "yes"
    data
  })

  output$modalplot <- renderGirafe({
    zz <- ggplot(datasubset(), aes(x = alcgp, y = count, fill = cancer, tooltip = count))+
      geom_col_interactive() +
      scale_fill_manual_interactive(
        values = c("no" = "#E41A1C", "yes" = "#377EB8"),
        data_id = c("no" = "no", "yes" = "yes"),
        tooltip = c("no" = "no", "yes" = "yes")) +
      geom_text(aes( y = Inf, label = count, alpha = transparent ), vjust = 2) +
      scale_alpha_manual(values = c(yes = 0, no = 1)) +
      guides(alpha = "none")

    girafe(ggobj = zz, options = list(opts_tooltip(zindex = 9999)))
  })


  observeEvent(input$fixedplot_selected,{

    showModal(modalDialog(
      tags$caption("click a legend key to display corresponding counts"),
      girafeOutput("modalplot")
    ))
    }
  )
})

