
#.........................................
# skip a test if a module is not available      [ see: https://github.com/rstudio/reticulate ]
#.........................................

check_availability = function() {

  builtins_av = mongo = bson = schema = NULL

  try({
    if (reticulate::py_available(initialize = FALSE)) {

      try({
        builtins_av = reticulate::import_builtins(convert = FALSE)                      # 'buildins' are used in non-ascii languages (see issue https://github.com/mlampros/fuzzywuzzyR/issues/3) where the R-function accepts a python object as input [ convert = FALSE ]
      }, silent=TRUE)

      try({
        mongo = reticulate::import("pymongo", delay_load = TRUE)                     # delay load foo module ( will only be loaded when accessed via $ )
      }, silent=TRUE)

      try({
        bson = reticulate::import("bson.json_util", delay_load = TRUE)
      }, silent=TRUE)

      try({
        schema = reticulate::import('jsonschema', delay_load = TRUE)
      }, silent=TRUE)
    }
  }, silent=TRUE)


  if (any(c(is.null(builtins_av), is.null(mongo), is.null(bson), is.null(schema)))) {
    FALSE
  }
  else {
    TRUE
  }
}



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



