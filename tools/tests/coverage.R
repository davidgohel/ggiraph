if (requireNamespace("covr", quietly = TRUE)) {
  coverage <- covr::package_coverage(line_exclusions = c(
    "src/tinyxml2.cpp", "src/tinyxml2.h",
    "R/utils_ggplot2.R", "R/utils_ggplot2_performance.R"
  ))
  print.coverage <- function(x, ..., threshhold = 100, sort_by_percent = FALSE) {
    lst <- covr::coverage_to_list(x)
    message(
      crayon::bold(paste(collapse = " ", c(attr(x, "package")$package, "Coverage: "))),
      covr:::format_percentage(lst$totalcoverage)
    )
    {
      lst <- lst$filecoverage
      if (is.numeric(threshhold)) {
        lst <- Filter(x = lst, function(x) x < threshhold)
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
  }
  print(coverage)
}
