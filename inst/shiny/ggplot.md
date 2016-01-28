    library(maps)
    
    crimes <- data.frame(state = tolower(rownames(USArrests)), USArrests)
    
    onclick <- "function() {var dataid = jQuery(this).attr(\"data-id\");\
    Shiny.onInputChange(\"state\", dataid);}"
    
    dataset <- crimes
    dataset$onclick = onclick
    
    states_map <- map_data("state")
    gg_map <- ggplot(dataset, aes(map_id = state))
    gg_map <- gg_map + 
              geom_map_interactive( aes( fill = Murder,
                tooltip = state, onclick = onclick, data_id = state
              ), map = states_map) +
              expand_limits(x = states_map$long, y = states_map$lat)
