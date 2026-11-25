mock_session <- function() {
  env <- new.env()
  env$messages <- list()
  env$sendCustomMessage <- function(type, message) {
    env$messages[[length(env$messages) + 1]] <- list(type = type, message = message)
  }
  env
}

# messages sent to the JS handler ----
test_that("girafe_class_* send the action and the class", {
  session <- mock_session()
  girafe_class_add(session, "plot", "hl", data_id = "a")
  girafe_class_remove(session, "plot", "hl", data_id = "a")
  girafe_class_toggle(session, "plot", "hl", data_id = "a")
  expect_length(session$messages, 3)
  types <- vapply(session$messages, function(m) m$type, "")
  expect_equal(types, rep("plot_class", 3))
  actions <- vapply(session$messages, function(m) m$message$action, "")
  expect_equal(actions, c("add", "remove", "toggle"))
  expect_equal(session$messages[[1]]$message$cls, "hl")
})

test_that("girafe_class_* send only the given ids, as character", {
  session <- mock_session()
  girafe_class_add(session, "plot", "hl", data_id = 1:2)
  expect_equal(session$messages[[1]]$message$data_id, c("1", "2"))
  expect_null(session$messages[[1]]$message$key_id)
  expect_null(session$messages[[1]]$message$theme_id)

  girafe_class_add(session, "plot", "hl", key_id = "k", theme_id = "t")
  msg <- session$messages[[2]]$message
  expect_null(msg$data_id)
  expect_equal(msg$key_id, "k")
  expect_equal(msg$theme_id, "t")
})

# invalid arguments ----
test_that("girafe_class_* check their arguments", {
  session <- mock_session()
  expect_error(girafe_class_add(session, "plot", "", data_id = "a"), "non-empty string")
  expect_error(girafe_class_add(session, "plot", c("a", "b"), data_id = "a"), "non-empty string")
  expect_error(girafe_class_add(session, "plot", 1, data_id = "a"), "non-empty string")
  expect_error(girafe_class_add(session, "plot", "hl"), "At least one of")
  expect_length(session$messages, 0)
})

test_that("girafe_class_* explain a missing session", {
  expect_error(
    girafe_class_add("plot", "hl", data_id = "a"),
    "must be the Shiny session"
  )
  expect_error(girafe_class_toggle(NULL, "plot", "hl", data_id = "a"), "Did you forget it")
})
