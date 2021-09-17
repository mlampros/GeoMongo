
#------------------------
# Load the python-modules
#------------------------


MONGO <- NULL; BSON <- NULL; SCHEMA <- NULL; BUILTINS <- NULL;


.onLoad <- function(libname, pkgname) {

  try({
    if (reticulate::py_available(initialize = FALSE)) {

      try({
        BUILTINS <<- reticulate::import_builtins(convert = FALSE)                      # 'buildins' are used in non-ascii languages (see issue https://github.com/mlampros/fuzzywuzzyR/issues/3) where the R-function accepts a python object as input [ convert = FALSE ]
      }, silent=TRUE)

      try({
        MONGO <<- reticulate::import("pymongo", delay_load = TRUE)                     # delay load foo module ( will only be loaded when accessed via $ )
      }, silent=TRUE)

      try({
        BSON <<- reticulate::import("bson.json_util", delay_load = TRUE)
      }, silent=TRUE)

      try({
        SCHEMA <<- reticulate::import('jsonschema', delay_load = TRUE)
      }, silent=TRUE)
    }
  }, silent=TRUE)
}


.onAttach <- function(libname, pkgname) {
  packageStartupMessage("If the 'GeoMongo' package gives the following error: 'attempt to apply non-function' then make sure to open a new R session and run 'reticulate::py_config()' before loading the package!")
}
