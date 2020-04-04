library(ggiraph)

source("stateHandler.R")

shinyUI(fluidPage(
  tags$h3("ggiraph selection/highlight demo"),
  tags$hr(),
  fluidRow(
    column(
      width = 2,
      selectInput(
        "opt_selected_data",
        label = "Data selections:",
        choices = list("multiple", "single", "none"),
        selected = "multiple"
      )
    ),
    column(
      width = 2,
      checkboxInput(
        "opt_hover_data",
        label = "Reactive data hovering",
        value = FALSE
      )
    ),
    column(
      width = 2,
      selectInput(
        "opt_selected_key",
        label = "Legend key selections:",
        choices = list("multiple", "single", "none"),
        selected = "single"
      )
    ),
    column(
      width = 2,
      checkboxInput(
        "opt_hover_key",
        label = "Reactive legend key hovering",
        value = FALSE
      )
    ),
    column(
      width = 2,
      selectInput(
        "opt_selected_theme",
        label = "Theme elements selections:",
        choices = list("multiple", "single", "none"),
        selected = "single"
      )
    ),
    column(
      width = 2,
      checkboxInput(
        "opt_hover_theme",
        label = "Reactive theme element hovering",
        value = FALSE
      )
    )
  ),
  fluidRow(
    column(
      width = 4,
      checkboxInput(
        "hover_inv",
        label = "Hovering over one data element, makes the rest semi-transparent",
        value = FALSE
      )
    ),
    uiOutput("linkoptions")
  ),

  tags$hr(),
  fluidRow(column(width = 8,
                  girafeOutput("plot")),
           column(width = 4,
                  uiOutput("checkboxes")))
))
