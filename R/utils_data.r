#' @importFrom dplyr
#'  group_by mutate lag ungroup consecutive_id filter
panel_path_reshape <- function(data) {
  data <- group_by(data, .data$group)
  data <- mutate(
    data,
    has_na = is.na(.data$x) | is.na(.data$y),
    segment_change = cumsum(lag(.data$has_na, default = FALSE))
  )
  data <- ungroup(data)
  data <- mutate(
    data,
    group = consecutive_id(.data$group, .data$segment_change)
  )
  data <- filter(data, !.data$has_na)
  data <- mutate(
    data,
    has_na = NULL, segment_change = NULL
  )
  as.data.frame(data)
}

