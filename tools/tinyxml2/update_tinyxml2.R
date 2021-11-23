
update_tinyxml2 <- function() {
  current_version <- NULL
  current_header <- ggiraph:::read_file("src/tinyxml2.h")
  m <- regmatches(current_header, gregexec("TINYXML2_(\\w+)_VERSION (\\d)", current_header))
  if (is.matrix(m[[1]]) && nrow(m[[1]]) == 3 && ncol(m[[1]]) == 3) {
    current_version <- paste0(m[[1]][3, ], collapse = ".")
  }
  if (length(current_version) == 0) {
    stop("Failed to extract current version of tinyxml2")
  } else {
    message("Current version: ", current_version)
  }

  tags <- jsonlite::fromJSON("https://api.github.com/repos/leethomason/tinyxml2/tags")
  tags <- head(tags, 1)
  latest_version <- tags$name
  if (length(latest_version) == 0) {
    stop("Failed to extract latest version of tinyxml2")
  } else {
    message("Latest version: ", latest_version)
  }

  if (current_version >= latest_version) {
    message("No update necessary!")
    return(invisible(FALSE))
  }

  tarfile <- tempfile()
  on.exit(unlink(tarfile))
  if (download.file(tags$tarball_url, tarfile) != 0) {
    stop("Failed to download tinyxml2 tarball")
  }

  files <- Filter(
    x = untar(tarfile, list = TRUE),
    function(x) { grepl("tinyxml2\\.(cpp|h)", x) }
  )
  if (length(files) != 2) {
    stop("Failed to find tinyxml2 files in tarball")
  }
  exdir <- tempfile()
  on.exit(unlink(exdir))
  if (untar(tarfile, files = files, exdir = exdir) != 0) {
    stop("Failed to extract tinyxml2 files from tarball")
  }
  files <- list.files(exdir, full.names = TRUE, recursive = TRUE)
  destdir <- "tools/tinyxml2/tmp"
  if (!all(file.copy(files, destdir, overwrite = TRUE))) {
    stop("Failed to copy tinyxml2 files")
  }
  h_file <- file.path(destdir, "tinyxml2.h")
  cpp_file <- file.path(destdir, "tinyxml2.cpp")

  # use unix line endings
  convert_crlf <- function (infile) {
    txt <- readLines(infile)
    f <- file(infile, open = "wb")
    cat(txt, file = f, sep = "\n")
    close(f)
  }
  convert_crlf(h_file)
  convert_crlf(cpp_file)
  message("Downloaded and prepared tinyxml2 files to ", destdir)

  # apply patches
  patchdir <- "tools/tinyxml2/patches_cpp"
  patchfound <- FALSE
  if (dir.exists(patchdir)) {
    for (fn in list.files(patchdir, full.names = TRUE)) {
      patchfound <- TRUE
      message("Applying patch: ", fn)
      system2("patch", c(
        "-u", "-t", shQuote(cpp_file), "-i", shQuote(fn)
      ))
    }
  }
  if (!patchfound) {
    warning("No patches found, aborting")
  } else {
    # copy back to src
    if (!all(file.copy(c(h_file, cpp_file), "src/", overwrite = TRUE))) {
      stop("Failed to copy tinyxml2 files to src")
    }
  }
}
if (interactive()) {
  update_tinyxml2()
}
