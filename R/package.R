
#------------------------
# Load the python-modules
#------------------------


MONGO <- NULL; BSON <- NULL; SCHEMA <- NULL; BUILTINS <- NULL;


.onLoad <- function(libname, pkgname) {

  if (reticulate::py_available(initialize = TRUE)) {

    if (reticulate::py_module_available("pymongo")) {

      MONGO <<- reticulate::import("pymongo", delay_load = TRUE)
    }

    if (reticulate::py_module_available("bson")) {

      BSON <<- reticulate::import("bson.json_util", delay_load = TRUE)
    }

    if (reticulate::py_module_available("jsonschema")) {

      SCHEMA <<- reticulate::import('jsonschema', delay_load = TRUE)
    }

    BUILTINS <<- reticulate::import_builtins(convert = FALSE)
  }
}
