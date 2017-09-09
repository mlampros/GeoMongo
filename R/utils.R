
#' mongodb geospatial methods ( using PyMongo in R )
#'
#'
#' @param host (optional) hostname or IP address or Unix domain socket path of a single mongod or mongos instance to connect to, or a mongodb URI, or a list of hostnames / mongodb URIs. See the reference link for more information.
#' @param port (optional) port number on which to connect
#' @param document_class (optional) default class to use for documents returned from queries on this client
#' @param tz_aware (optional) if TRUE, datetime instances returned as values in a document by this MongoClient will be timezone aware (otherwise they will be naive)
#' @param connect (optional) if TRUE (the default), immediately begin connecting to MongoDB in the background. Otherwise connect on the first operation
#' @param ... See the reference link for more details on the \emph{ellipsis} (...) concerning the additional parameters of the MongoClient()
#' @param FILE a character string specifying a valid path to a file ( applies to \emph{read_mongo_bson} method )
#' @param STR a character string ( applies to \emph{read_mongo_bson} method )
#' @param DATA a valid path to a file/folder or a list ( applies to \emph{geoInsert} method )
#' @param TYPE_DATA a character string. One of 'folder', 'file', 'dict_one' (takes as input a \emph{list} or a \emph{character string}) or 'dict_many' (takes as input a \emph{list} or a \emph{character string vector}) ( applies to \emph{geoInsert} method )
#' @param COLLECTION a \emph{pymongo.collection.Collection} object ( applies to \emph{geoInsert} and \emph{geoQuery} methods )
#' @param GEOMETRY_NAME a character string specifying the name of the geometry object, as it appears in the file/string ( applies to \emph{geoInsert} and \emph{geoQuery} methods )
#' @param read_method a character string specifying the method to use to read the data. Either using the \emph{"geojsonR"} (package) or the \emph{"mongo_bson"} utility function ( applies to \emph{geoInsert} method )
#' @param QUERY a named list specifying the query to use in mongodb ( applies to \emph{geoQuery} method )
#' @param METHOD a character string specifying the method to use to perform geospatial queries in mongodb. One of "find", "aggregate" OR "command" ( applies to \emph{geoQuery} method )
#' @param DATABASE a \emph{"pymongo.database.Database"} object ( applies to \emph{geoQuery} method )
#' @param TO_LIST either TRUE or FALSE. If TRUE then the output of the \emph{geoQuery} method will be a list, otherwise a data.table (matrix) object ( applies to \emph{geoQuery} method )
#' @export
#' @details
#'
#' the \emph{geomongo$new} method initializes the MongoClient
#'
#' the \emph{getClient} method returns a \emph{"pymongo.mongo_client.MongoClient"} object
#'
#' the \emph{read_mongo_bson} method allows the user to read a file/string using the \emph{bson.json_util} module, which loads MongoDB Extended JSON data ( SEE \emph{https://stackoverflow.com/questions/42089045/bson-errors-invaliddocument-key-oid-must-not-start-with-trying-to-insert} )
#'
#' the \emph{geoInsert} method allows the user to import data to a mongo-db from a \emph{folder}, \emph{file} or \emph{list}
#'
#' the \emph{geoQuery} method allows the user to perform geospatial queries using one of the \emph{find}, \emph{aggregate} or \emph{command} methods
#'
#' For spherical query operators to function properly, you must convert distances to radians, and convert from radians to the distances units used by your application.
#'
#' To convert distance to radians: divide the distance by the radius of the sphere (e.g. the Earth) in the same units as the distance measurement.
#' To convert radians to distance: multiply the radian measure by the radius of the sphere (e.g. the Earth) in the units system that you want to convert the distance to.
#'
#' The equatorial radius of the Earth is approximately 3,963.2 miles or 6,378.1 kilometers.
#'
#' If specifying latitude and longitude coordinates, list the longitude first and then latitude:
#'
#' Valid longitude values are between -180 and 180, both inclusive.
#' Valid latitude values are between -90 and 90 (both inclusive).
#'
#' @references
#' https://api.mongodb.com/python/current/api/index.html, https://docs.mongodb.com/manual/tutorial/calculate-distances-using-spherical-geometry-with-2d-geospatial-indexes/
#' @docType class
#' @importFrom R6 R6Class
#' @import reticulate
#' @importFrom geojsonR FROM_GeoJson_Schema
#' @importFrom data.table rbindlist
#' @section Methods:
#'
#' \describe{
#'  \item{\code{geomongo$new(host = 'localhost', port = 27017, tz_aware = FALSE, connect = TRUE, ...)}}{}
#'
#'  \item{\code{--------------}}{}
#'
#'  \item{\code{getClient()}}{}
#'
#'  \item{\code{--------------}}{}
#'
#'  \item{\code{read_mongo_bson(FILE = NULL, STR = NULL)}}{}
#'
#'  \item{\code{--------------}}{}
#'
#'  \item{\code{geoInsert(DATA = NULL, TYPE_DATA = NULL, COLLECTION = NULL, GEOMETRY_NAME = NULL, read_method = "geojsonR")}}{}
#'
#'  \item{\code{--------------}}{}
#'
#'  \item{\code{geoQuery(QUERY = NULL, METHOD = NULL, COLLECTION = NULL, DATABASE = NULL, GEOMETRY_NAME = NULL, TO_LIST = FALSE)}}{}
#'  }
#'
#' @usage # init <- geomongo$new(host = 'localhost', port = 27017,
#'
#'        #                      tz_aware = FALSE, connect = TRUE, ...)
#' @examples
#'
#' \dontrun{
#' library(GeoMongo)
#'
#' init = geomongo$new()
#'
#' getter_client = init$getClient()
#'
#' init_db = getter_client$get_database("example_db")
#'
#' init_col = init_db$get_collection("example_collection")
#'
#' #--------------------------
#' # geonear using 'aggregate'
#' #--------------------------
#'
#' query_geonear = list('$geoNear' = list(near = list(type = "Point", coordinates = c(-122.5, 37.1)),
#'
#'                      distanceField = "distance", maxDistance = 900 * 1609.34,
#'
#'                      distanceMultiplier = 1 / 1609.34, spherical = TRUE))
#'
#'
#' init$geoQuery(QUERY = query_geonear, METHOD = "aggregate", COLLECTION = init_col,
#'
#'               DATABASE = init_db, GEOMETRY_NAME = "location", TO_LIST = FALSE)
#' }


geomongo <- R6::R6Class("geomongo",

                        lock_objects = FALSE,

                        public = list(


                          #--------------------------------
                          # method to initialize the client
                          #--------------------------------

                          initialize = function(host = 'localhost', port = 27017, tz_aware = FALSE, connect = TRUE, ...) {               # document_class = dict by default

                            port = as.integer(port)

                            ARGS = c(as.list(environment()), list(...))

                            cli_mongo = do.call(MONGO$MongoClient, ARGS)

                            private$CLIENT = cli_mongo
                          },


                          #-----------------------
                          # getter for MongoClient
                          #------------------------

                          getClient = function() {

                            return(private$CLIENT)
                          },

                          #---------------------------------------------------------------------------------------------------------------------
                          # read data from file/string using mongo-bson
                          # this function can be used both internally
                          # and externally in order to first read the data
                          # and then pass the data to the insert function
                          # Don't add stops/exceptions because they will slow
                          # down the function especially when inserting many geojson objects
                          # The reason for reading data using bson is the format of the 'id' parameter when inserting data :
                          # https://stackoverflow.com/questions/42089045/bson-errors-invaliddocument-key-oid-must-not-start-with-trying-to-insert
                          #-----------------------------------------------------------------------------------------------------------------------

                          read_mongo_bson = function(FILE = NULL, STR = NULL) {

                            if (!is.null(FILE)) {

                              STR = readLines(FILE)

                              STR = paste(STR, collapse = "\n")
                            }

                            return(BSON$loads(STR))
                          },


                          #-------------------------------------------------------------------------------
                          # method : populate database [ the input format must be a reticulate::dict() ]
                          # TYPE_DATA : 'folder', 'file', 'dict_one', 'dict_many'
                          # read_method : either "geojsonR" or "mongo_bson"
                          #-------------------------------------------------------------------------------

                          geoInsert = function(DATA = NULL, TYPE_DATA = NULL, COLLECTION = NULL, GEOMETRY_NAME = NULL, read_method = "geojsonR") {

                            if (!inherits(GEOMETRY_NAME, "character")) { stop("the 'GEOMETRY_NAME' parameter should be of type character", call. = F) }
                            if (TYPE_DATA %in% c("folder", "file")) {
                              if (!inherits(DATA, "character")) stop("In case that the TYPE_DATA parameter is either a 'folder' or a 'file', then the DATA parameter should be a valid path to a file", call. = F)
                              if (TYPE_DATA == "file") {
                                if (!file.exists(DATA)) stop("the path to the 'file' parameter does not exist", call. = F)}
                              if (TYPE_DATA == "folder") {
                                if (!dir.exists(DATA)) stop("the path to the 'folder' parameter does not exist", call. = F)
                              }
                            }

                            private$copy_collection = COLLECTION

                            private$geometry_name = GEOMETRY_NAME

                            if (TYPE_DATA == "folder") {

                              geo_json_files = list.files(DATA, full.names = T)

                              for (i in 1:length(geo_json_files)) {

                                if (read_method == "geojsonR") {

                                  imp_geoj = geojsonR::FROM_GeoJson_Schema(geo_json_files[i], GEOMETRY_NAME, To_List = T)}         # by default "To_List = TRUE", otherwise conversion to python dictionary returns an array which is not accepted in mongodb

                                else if (read_method == "mongo_bson") {

                                  imp_geoj = self$read_mongo_bson(FILE = geo_json_files[i], STR = NULL)}

                                else {

                                  stop("invalid 'read_method' parameter", call. = F)
                                }

                                conv_dict = reticulate::dict(imp_geoj)

                                private$copy_collection$insert_one(conv_dict)
                              }
                            }

                            else if (TYPE_DATA == "file") {

                              if (read_method == "geojsonR") {

                                imp_geoj = geojsonR::FROM_GeoJson_Schema(DATA, GEOMETRY_NAME, To_List = T)}

                              else if (read_method == "mongo_bson") {

                                imp_geoj = self$read_mongo_bson(FILE = DATA, STR = NULL)}

                              else {

                                stop("invalid 'read_method' parameter", call. = F)
                              }

                              conv_dict = reticulate::dict(imp_geoj)

                              private$copy_collection$insert_one(conv_dict)
                            }

                            else if (TYPE_DATA == "dict_one") {

                              if (!inherits(TYPE_DATA, "character")) stop("the TYPE_DATA parameter should be of type string", call. = F)

                              if (inherits(DATA, "list")) {

                                private$copy_collection$insert_one(reticulate::dict(DATA))}

                              else if (inherits(DATA, "character")) {

                                if (read_method == "geojsonR") {

                                  input_str = FROM_GeoJson_Schema(DATA, GEOMETRY_NAME, To_List = T)}

                                else if (read_method == "mongo_bson") {

                                  input_str = self$read_mongo_bson(FILE = NULL, STR = DATA)}

                                else {

                                  stop("invalid 'read_method' parameter", call. = F)
                                }

                                private$copy_collection$insert_one(reticulate::dict(input_str))
                              }

                              else {

                                stop("the input data should be either a list or a character string", call. = F)
                              }
                            }

                            else if (TYPE_DATA == "dict_many") {

                              if (!inherits(TYPE_DATA, "character")) stop("the TYPE_DATA parameter should be of type string", call. = F)

                              INIT_LIST = BUILTINS$list()                           # initialize a python-list to save multiple geojson objects

                              if (inherits(DATA, "list")) {

                                for (j in 1:length(DATA)) {                           # simple for loop to insert the data [ in case of too many sublists build an rcpp loop ]

                                  INIT_LIST$append(reticulate::dict(DATA[[j]]))       # append to the list
                                }
                              }

                              else if (inherits(DATA, c("character", "vector")) && length(DATA) > 1) {

                                for (i in 1:length(DATA)) {

                                  if (read_method == "geojsonR") {

                                    INIT_LIST$append(reticulate::dict(FROM_GeoJson_Schema(url_file_string = DATA[i], GEOMETRY_NAME, To_List = T)))}

                                  else if (read_method == "mongo_bson") {

                                    input_str_iter = self$read_mongo_bson(FILE = NULL, STR = DATA[i])

                                    INIT_LIST$append(reticulate::dict(input_str_iter))
                                  }

                                  else {

                                    stop("invalid 'read_method' parameter", call. = F)
                                  }
                                }
                              }

                              else {

                                stop("the input data should be either a list or a character string vector", call. = F)
                              }

                              private$copy_collection$insert_many(INIT_LIST)        # insert the list in mongodb
                            }

                            else {

                              stop("invalid TYPE_DATA parameter", call. = F)
                            }

                            private$idx_2dsphere()              # add 2dsphere indexing (after data is inserted)

                            invisible()
                          },


                          #-------------------------------------------------
                          # method to perform geo-spatial queries
                          # METHOD : one of "find", "aggregate" OR "command"
                          #-------------------------------------------------

                          geoQuery = function(QUERY = NULL, METHOD = NULL, COLLECTION = NULL, DATABASE = NULL, GEOMETRY_NAME = NULL, TO_LIST = FALSE) {

                            if (!inherits(QUERY, "list")) { stop("the 'QUERY' parameter should be a named list", call. = F) }
                            if (is.null(DATABASE)) {
                              if (is.null(COLLECTION) && is.null(private$copy_collection)) stop("give an input object for the COLLECTION parameter", call. = F)
                              if (!is.null(COLLECTION) && !is.null(private$copy_collection)) {
                                Message = c("You've already specified a COLLECTION object. The previous collection will be overwritten from the new '", deparse(substitute(COLLECTION)), "' collection.")
                                warning(paste0(Message), call. = F)}}
                            if (is.null(DATABASE) && METHOD == 'command' || !is.null(DATABASE) && METHOD != 'command') {
                              stop("in case that the 'DATABASE' parameter is non-NULL, then the 'METHOD' parameter should equal to 'command' ( and the opposite )", call. = F) }

                            if (!is.null(COLLECTION)) { private$copy_collection = COLLECTION }

                            if (is.null(private$geometry_name) && is.null(GEOMETRY_NAME)) stop("the 'GEOMETRY_NAME' is not specified", call. = F)

                            if (!is.null(private$geometry_name) && !is.null(GEOMETRY_NAME)) warning("the 'GEOMETRY_NAME' is already specified", call. = F)

                            if (!is.null(GEOMETRY_NAME) && is.null(private$geometry_name)) {

                              private$geometry_name = GEOMETRY_NAME

                              private$idx_2dsphere()              # add 2dsphere indexing (in case that the data isn't inserted but only queried)
                            }

                            if (METHOD == "aggregate") {

                              ret_pip_dict = reticulate::dict(QUERY)

                              PIPELINE = list(ret_pip_dict)                          # additional step : dict in R-list

                              res_col = private$copy_collection$aggregate(PIPELINE)
                            }

                            else if (METHOD == "find") {

                              ret_pip_dict = reticulate::dict(QUERY)

                              res_col = private$copy_collection$find(ret_pip_dict)
                            }

                            else if (METHOD == "command") {                    # the PyMongo 'command' equals the 'runCommand' of MongoDB, however there is a difference on how to give the various parameters [ see tests ]

                              Args_Kwargs = private$func_runCommand(QUERY)

                              res_col = do.call(DATABASE$command, Args_Kwargs)

                              res_col = lapply(res_col$results, function(x) private$inner_item_funct(x, remove_ID = "obj._id", add_ID = "id"))     # process the '_id's
                            }

                            else {

                              stop("valid METHOD is one of 'find', 'aggregate' or 'command'", call. = F)
                            }

                            if (TO_LIST) {

                              if (METHOD != 'command') {

                                res_col = reticulate::iterate(res_col)
                              }

                              return(res_col)
                            }

                            else {

                              if (METHOD == 'command') {

                                res = data.table::rbindlist(res_col, use.names = T)}                            # use.names = T : items will be bound by matching column names

                              else {

                                loop_res = reticulate::iterate(res_col, f = private$inner_item_funct)           # use the default arguments of 'inner_item_funct' function for 'find', 'aggregate'

                                res = data.table::rbindlist(loop_res, use.names = T)
                              }

                              return(res)
                            }
                          }
                        ),

                        private = list(

                          CLIENT = NULL,

                          copy_collection = NULL,

                          geometry_name = NULL,

                          #----------------------------------------------
                          # create 2dsphere indexing [ private function ]
                          #----------------------------------------------

                          idx_2dsphere = function() {

                            r_idx = list(reticulate::tuple(list(private$geometry_name, MONGO$GEOSPHERE)))          # once inserting of geojson objects is done, build the 2dsphere index

                            private$copy_collection$create_index(r_idx)
                          },

                          #-----------------------------------------------------------------------------------------------
                          # helper for 'reticulate::iterate(..., f = ...)' AND 'runCommand' functions [ private function ]
                          #-----------------------------------------------------------------------------------------------

                          inner_item_funct = function(x, remove_ID = "_id", add_ID = "id") {

                            tmp_lst = base::unlist(x)                              # unlist

                            copy_id = as.character(tmp_lst[[remove_ID]])           # convert the id to character (hexadecimal), as the returned type is an unrecognized one

                            tmp_lst[[remove_ID]] = NULL                            # delete the initial `_id`, as single quotation marks (due to underscore) cause trouble with data.table's rbindlist()

                            tmp_lst[[add_ID]] = copy_id                            # create new name for id

                            tmp_lst
                          },

                          #-------------------------------------------------------------------
                          # helper function for the 'runCommand' function [ private function ]
                          #-------------------------------------------------------------------

                          func_runCommand = function(LIST) {

                            lapply(LIST, function(SUBLIST) {

                              if (is.list(SUBLIST)) {

                                SUBLIST = reticulate::dict(SUBLIST)       # if item is list build a reticulate::dict(), otherwise return the item
                              }

                              SUBLIST
                            })
                          }
                        )
)



#' simple way to validate a json instance under a given schema
#'
#'
#' @param json_data a named list specifying the input data to validate against the json-schema
#' @param json_schema a named list specifying the json-schema
#' @details
#' Define a json-schema that the input data should follow and then validate the input data against the schema. If the input data follows the schema then by running the function
#' nothing will be returned, otherwise an error with Traceback will be printed in the R-session.
#'
#' In case that \emph{type} is at the same time also a property name in the json data, then do not include \emph{"type" = "string"} in the json schema ( https://github.com/epoberezkin/ajv/issues/137 )
#' @export
#' @references https://pypi.python.org/pypi/jsonschema, http://python-jsonschema.readthedocs.io/en/latest/
#' @examples
#'
#' library(GeoMongo)
#'
#' if (reticulate::py_available() && reticulate::py_module_available("jsonschema")) {
#'
#'  schema_dict = list("type" = "object",
#'
#'                       "properties" = list(
#'
#'                         "name" = list("type" = "string"),
#'
#'                            "location" = list("type" = "object",
#'
#'                            "properties" = list(
#'
#'                             "type" = list("enum" = c("Point", "Polygon")),
#'
#'                             "coordinates" = list("type" = "array")
#'  ))))
#'
#'
#'  data_dict = list("name" = "example location",
#'
#'                  "location" = list("type" = "Point", "coordinates" = c(-120.24, 39.21)))
#'
#'
#'  json_schema_validator(json_data = data_dict, json_schema = schema_dict)
#'
#' }
#'

json_schema_validator = function(json_data = NULL, json_schema = NULL) {

  if (!inherits(json_data, "list")) { stop("the 'json_data' parameter should be of type list", call. = F) }
  if (!inherits(json_schema, "list")) { stop("the 'json_schema' parameter should be of type list", call. = F) }

  ret_sch = reticulate::dict(json_schema)

  ret_dat = reticulate::dict(json_data)

  SCHEMA$validate(ret_dat, ret_sch)

  invisible()
}



#' MongoDB (bulk) commands
#'
#'
#' @param Argument a character string specifying the mongodb shell command to run from within an R-session
#' @param ... the \emph{ellipsis} (...) parameter allows a unix-user (windows-user) to give additional parameters to the base-R \emph{system() (shell())} function which is run in background.
#' @details
#' MongoDB shell commands are important for instance if someone has to import/export bulk data to a mongo database. This R function utilizes the \emph{system} base function to run the mongodb shell command from
#' within an R-session. See the reference links for more details.
#' The \emph{ellipsis} (...) parameter could be used for instance to disallow messages be printed in the console (on unix by using \emph{ignore.stdout} and \emph{ignore.stderr}).
#' @export
#' @references https://docs.mongodb.com/manual/reference/program/mongoimport/,  https://docs.mongodb.com/manual/reference/program/mongoexport/
#' @examples
#'
#' \dontrun{
#' library(GeoMongo)
#'
#' ARGs = "mongoimport -d DB -c COLLECTION --type json --file /MY_DATA.json"
#'
#' mongodb_console(Argument = ARGs)
#' }

mongodb_console = function(Argument = NULL, ...) {

  if (!inherits(Argument, "character")) { stop("the 'Argument' parameter should be of type character", call. = F) }

  if (.Platform$OS.type == "unix") {

    system(command = Argument, ...)
  }

  if (.Platform$OS.type == "windows") {

    shell(cmd = Argument, ...)
  }

  invisible()
}


