# Tests draw inside `dsvg_doc()` (or another explicit device). A test that
# opens the default graphics device (an Rplots.pdf file, or a window in an
# interactive session) fails, instead of leaving that file or window behind.
old_device <- options(device = function(...) {
  stop(
    "A test opened the default graphics device: draw inside `dsvg_doc()`.",
    call. = FALSE
  )
})
withr::defer(options(old_device), teardown_env())
