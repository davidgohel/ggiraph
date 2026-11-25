# This file is part of the standard setup for testthat.
# It is recommended that you do not modify it.
#
# Where should you do additional test configuration?
# Learn more about the roles of various files in:
# * https://r-pkgs.org/testing-design.html#sec-tests-files-overview
# * https://testthat.r-lib.org/articles/special-files.html

library(testthat)
library(ggiraph)

# With _R_CHECK_DEPENDS_ONLY_ (hard dependencies check), R CMD check hides
# the suggested packages but the test framework: the tests, which read the
# SVG with xml2, are skipped, as they were with tinytest.
if (requireNamespace("xml2", quietly = TRUE)) {
  test_check("ggiraph")
}
