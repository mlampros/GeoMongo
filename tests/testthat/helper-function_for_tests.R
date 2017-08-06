
# helper function to skip tests if we don't have the 'foo' module
# https://github.com/rstudio/reticulate



# MODULE is of type character vector [ can take one or more MODULES as input ]


skip_test_if_no_modules <- function(MODULES) {

  modules_exist <- sapply(MODULES, function(x) reticulate::py_module_available(x))

  if (!all(modules_exist)) {

    idx = which(modules_exist != T)

    if (length(idx) > 1) {

      MESSAGE = paste(paste(MODULES[idx], collapse = " and "), "are not available for testthat-testing", collapse = " ")}

    else {

      MESSAGE = paste(MODULES[idx], "is not available for testthat-testing", collapse = " ")
    }

    testthat::skip(MESSAGE)
  }
}
