if (requireNamespace("covr", quietly = TRUE)) {
  coverage <- covr::package_coverage(line_exclusions = c(
    "src/tinyxml2.cpp", "src/tinyxml2.h",
    "R/utils_ggplot2.R", "R/utils_ggplot2_performance.R"
  ))
  print.coverage <- function(x, ...,
                             group = c("filename", "functions"),
                             by = "line",
                             threshold = 100,
                             sort_by_percent = FALSE) {
    if (length(x) == 0) {
      return()
    }
    group <- match.arg(group)
    type <- attr(x, "type")
    if (is.null(type) || type == "none") {
      type <- NULL
    }
    df <- covr::tally_coverage(x, by = by)
    if (!NROW(df)) {
      return(invisible())
    }
    percents <- tapply(df$value, df[[group]],
      FUN = function(x) (sum(x > 0) / length(x)) * 100
    )
    overall_percentage <- covr::percent_coverage(df, by = by)
    message(
      crayon::bold(paste(collapse = " ", c(attr(x, "package")$package, "Coverage: "))),
      covr:::format_percentage(overall_percentage)
    )
    lst <- as.list(percents)
    if (is.numeric(threshold)) {
      lst <- Filter(x = lst, function(x) x < threshold)
    }
    if (sort_by_percent) {
      for (i in seq_along(sort(lst))) {
        message(
          crayon::bold(paste0(names(lst)[i], ": ")),
          covr:::format_percentage(lst[i])
        )
      }
    } else {
      for (n in sort(names(lst))) {
        message(
          crayon::bold(paste0(n, ": ")),
          covr:::format_percentage(lst[[n]])
        )
      }
    }
  }
  print(coverage)
}
