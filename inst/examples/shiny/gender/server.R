library(ggplot2)
library(ggiraph)
library(dplyr)

source("stateHandler.R")

options(shiny.trace = FALSE)

dat <- data.frame(
  name = c("Christine", "Ginette", "David", "Cedric", "Frederic"),
  gender = c("Female", "Female", "Male", "Male", "Male"),
  height = c(169, 160, 171, 172, 171)
)

p <- ggplot(dat,
            aes(
              x = name,
              y = height,
              fill = gender,
              data_id = name,
              tooltip = name
            )) +
  labs(title = "Interactive title", subtitle = "Interactive subtitle") +
  geom_bar_interactive(stat = "identity") +
  scale_fill_manual_interactive(
    name = label_interactive("gender", tooltip = "Gender levels", data_id =
                               "legend.title"),
    values = c(Male = "#0072B2", Female = "#009E73"),
    data_id = function(breaks) {
      as.character(breaks)
    },
    tooltip = function(breaks) {
      as.character(breaks)
    },
    labels = function(breaks) {
      lapply(breaks, function(br) {
        label_interactive(as.character(br),
                          data_id = as.character(br),
                          tooltip = as.character(br))
      })
    }
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text_interactive(tooltip = "Title", data_id = "title"),
    plot.subtitle = element_text_interactive(tooltip = "Subitle", data_id =
                                               "subtitle"),
  )


shinyServer(function(input, output, session) {
  output$plot <- renderGirafe({
    x <- girafe(ggobj = p,
                width_svg = 6,
                height_svg = 8)
    x <- girafe_options(
      x,
      opts_selection(type = input$opt_selected_data),
      opts_hover(reactive = input$opt_hover_data),
      opts_selection_key(
        type = input$opt_selected_key,
        css = girafe_css("stroke:red; stroke-width:2px",
                         text = "stroke:none;fill:red;font-size:12px")
      ),
      opts_hover_key(
        css = girafe_css("stroke:red", text = "stroke:none;fill:red"),
        reactive = input$opt_hover_key
      ),
      opts_selection_theme(type = input$opt_selected_theme),
      opts_hover_theme(reactive = input$opt_hover_theme),
      opts_hover_inv(css = if (input$hover_inv == TRUE) "opacity:0.3" else "")
    )
    x
  })

  output$checkboxes <- renderUI({
    result <- list()

    if (input$opt_selected_data == "multiple" ||
        input$opt_selected_data == "single") {
      result[[length(result) + 1]] <-
        StateHandlerUI(
          'selected_data',
          label = "Selected data elements:",
          choices = list("Christine", "Ginette", "David", "Cedric", "Frederic")
        )
    }
    if (input$opt_hover_data == TRUE) {
      result[[length(result) + 1]] <-
        StateHandlerUI(
          "hovered_data",
          label = "Hovered data elements:",
          choices = list("Christine", "Ginette", "David", "Cedric", "Frederic")
        )
    }

    if (input$opt_selected_key == "multiple" ||
        input$opt_selected_key == "single") {
      result[[length(result) + 1]] <-
        StateHandlerUI(
          "selected_key",
          label = "Selected legend key elements:",
          choices = list("legend.title", "Female", "Male")
        )
    }
    if (input$opt_hover_key == TRUE) {
      result[[length(result) + 1]] <-
        StateHandlerUI(
          "hovered_key",
          label = "Hovered legend key elements:",
          choices = list("legend.title", "Female", "Male")
        )
    }

    if (input$opt_selected_theme == "multiple" ||
        input$opt_selected_theme == "single") {
      result[[length(result) + 1]] <-
        StateHandlerUI(
          "selected_theme",
          label = "Selected theme elements:",
          choices = list("title", "subtitle")
        )
    }
    if (input$opt_hover_theme == TRUE) {
      result[[length(result) + 1]] <-
        StateHandlerUI(
          "hovered_theme",
          label = "Hovered theme elements:",
          choices = list("title", "subtitle")
        )
    }

    result
  })

  link_selection_default <- FALSE
  link_hover_default <- FALSE

  output$linkoptions <- renderUI({
    result <- list()

    linkSelection <-
      (input$opt_selected_data == "multiple" ||
        input$opt_selected_data == "single") &&
      (input$opt_selected_key == "multiple" ||
          input$opt_selected_key == "single")

    linkHover <-
      (input$opt_hover_data == TRUE) &&
      (input$opt_hover_key == TRUE)

    if (linkSelection || linkHover) {
      result <- tagList(
        column(
          width = 4,
          if (linkSelection)
            checkboxInput(
              "link_selection",
              label = "Selecting legend key, selects relevant data",
              value = link_selection_default
            )
          else div()
        ),
        column(
          width = 4,
          if (linkHover)
            checkboxInput(
              "link_hover",
              label = "Hovering legend key, highlights relevant data",
              value = link_hover_default
            )
          else div()
        )
      )
    }
    result
  })

  callModule(StateHandler,
             'selected_data',
             reactive(input$plot_selected),
             'plot_set')
  callModule(StateHandler,
             'hovered_data',
             reactive(input$plot_hovered),
             'plot_hovered_set')
  callModule(StateHandler,
             'selected_key',
             reactive(input$plot_key_selected),
             'plot_key_set')
  callModule(
    StateHandler,
    'hovered_key',
    reactive(input$plot_key_hovered),
    'plot_key_hovered_set'
  )
  callModule(
    StateHandler,
    'selected_theme',
    reactive(input$plot_theme_selected),
    'plot_theme_set'
  )
  callModule(
    StateHandler,
    'hovered_theme',
    reactive(input$plot_theme_hovered),
    'plot_theme_hovered_set'
  )

  observeEvent(input$link_selection, {
    link_selection_default <<- input$link_selection
  })

  observeEvent(input$link_hover, {
    link_hover_default <<- input$link_hover
  })

  observeEvent(input$plot_key_selected, {
    enabled <- isolate(input$link_selection)
    if (is.logical(enabled) && enabled == TRUE) {
      v <- input$plot_key_selected
      if (is.null(v)) {
        v <- character(0)
      }
      data_sel <- (dat %>% dplyr::filter(gender %in% v ))$name
      session$sendCustomMessage(type = 'plot_set', message = data_sel)
    }
  }, ignoreInit = TRUE, ignoreNULL = FALSE)

  observeEvent(input$plot_key_hovered, {
    enabled <- isolate(input$link_hover)
    if (is.logical(enabled) && enabled == TRUE) {
      v <- input$plot_key_hovered
      if (is.null(v)) {
        v <- character(0)
      }
      data_sel <- (dat %>% dplyr::filter(gender %in% v ))$name
      session$sendCustomMessage(type = 'plot_hovered_set', message = data_sel)
    }
  }, ignoreInit = TRUE, ignoreNULL = FALSE)



})
