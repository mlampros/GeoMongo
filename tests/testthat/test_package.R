#===========================================================================================
# IMPORTANT : BESIDES THE PYTHON MODULES "pymongo", "bson", "jsonschema" ONE SHOULD HAVE AN
#             OPEN AND RUNNING MongoDB CONSOLE IN THE OPERATING SYSTEM (USING mongo, mongod)
#===========================================================================================

# connect to the relevant collection [ on travis I'll use only the "test" database]
#----------------------------------------------------------------------------------

library(GeoMongo)


# path to files / folder
#---------------------

PATH = paste0(getwd(), path.expand("/geojson_tests/"))

PATH_neigh = paste0(getwd(), path.expand("/neighborhoods.json"))

PATH_rest = paste0(getwd(), path.expand("/restaurants.json"))


# initialize mongodb
#-------------------

init = geomongo$new(host = 'localhost', port = 27017)       # use default configuration [ localhost ]

init_client = init$getClient()


# get 'test' database
#--------------------

FUNC_get_testdb = function() {
  
  if (!"test" %in% init_client$database_names()) {
    
    tmp_db = init_client[["test"]]
  }
  
  else {
    
    tmp_db = init_client$get_database("test")
  }
  
  return(tmp_db)
}


init_db = FUNC_get_testdb()


# function for collection
#------------------------

FUNC_COL = function(collection_name) {
  
  if (collection_name %in% init_db$collection_names()) {
    
    init_col = init_db$get_collection(collection_name)}
  
  else {
    
    init_col = init_db$create_collection(collection_name)
  }
  
  return(init_col)
}


# get collection
#---------------

init_col = FUNC_COL("geomongo_class")


# insert data [ only if collection is empty ]
#------------------------------------------------

FUNC_insert = function(collection) {
  
  if (collection$count() == 0) {
    
    init$geoInsert(DATA = PATH, TYPE_DATA = 'folder', COLLECTION = collection, GEOMETRY_NAME = 'location', read_method = 'geojsonR')
  }
}



context('test GeoMongo package')


#===================================================================== mongodb_console (bulk import)


#------------------------------------------
# Error handling "mongodb_console" function
#------------------------------------------

testthat::test_that("returns an error if the Argument parameter is not of type character", {
  
  skip_test_if_no_modules(c("pymongo", "bson"))
  
  testthat::expect_error( mongodb_console(Argument = NULL) )
})


#---------------------------------------
# expect true "mongodb_console" function
#---------------------------------------


if (.Platform$OS.type == "unix") {
  
  testthat::test_that("bulk imports data in a specified database (restaurants collection)", {
    
    skip_test_if_no_modules(c("pymongo", "bson"))
    
    if (!"restaurants" %in% init_db$collection_names()) {
      
      ARGUMENT = paste("mongoimport -d test -c restaurants --type json --file", PATH_rest, sep = " ")
      
      mongodb_console(Argument = ARGUMENT)
    }
    
    testthat::expect_true( "restaurants" %in% init_db$collection_names() )
  })
}


if (.Platform$OS.type == "unix") {
  
  testthat::test_that("bulk imports data in a specified database (neighborhoods collection)", {
    
    skip_test_if_no_modules(c("pymongo", "bson"))
    
    if (!"neighborhoods" %in% init_db$collection_names()) {
      
      ARGUMENT = paste("mongoimport -d test -c neighborhoods --type json --file", PATH_neigh, sep = " ")
      
      mongodb_console(Argument = ARGUMENT)
    }
    
    testthat::expect_true( "neighborhoods" %in% init_db$collection_names() )
  })
}

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# EXAMPLE ON HOW TO (BULK) IMPORT DATA ON WINDOWS   [ SEE ALSO : http://o7planning.org/en/10279/importing-and-exporting-mongodb-database#a69830]
#------------------------------------------------

# FIRST CHANGE TO THE DEFAULT MONGODB INSTALLATIONS DIRECTORY WHERE "bin" IS LOCATED (for instance) : setwd("C:\\Program Files\\MongoDB\\Server\\3.4\\bin")
# ONE CAN FIND THE DEFAULT DIRECTORY BY RUNNING MONGO ON THE COMMAND SHELL AND THEN EXECUTE : db.serverCmdLineOpts()
# THEN CONTINUE WITH THE FOLLOWING TEST CASE:


# if (.Platform$OS.type == "windows") {
#   
#   testthat::test_that("bulk imports data in a specified database (restaurants collection)", {
#     
#     skip_test_if_no_modules(c("pymongo", "bson"))
#     
#     if (!"restaurants" %in% init_db$collection_names()) {
#       
#       ARGUMENT = paste("mongoimport -d test -c restaurants --type json --file", PATH_rest, sep = " ")
#       
#       mongodb_console(Argument = ARGUMENT)
#     }
#     
#     testthat::expect_true( "restaurants" %in% init_db$collection_names() )
#   })
# }


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#################################################################   initialize collections for "neighborhoods" and "restaurants"

init_neighb = init_db$get_collection("neighborhoods")

init_rest = init_db$get_collection("restaurants")

#################################################################

#===================================================================== geoInsert

#----------------------------------
# Error handling "geoInsert" method
#----------------------------------


testthat::test_that("returns an error if the GEOMETRY_NAME is not of type character", {
  
  skip_test_if_no_modules(c("pymongo", "bson"))
  
  testthat::expect_error( init$geoInsert(DATA = PATH, TYPE_DATA = 'folder', COLLECTION = init_col, GEOMETRY_NAME = list(), read_method = 'geojsonR') )
})


testthat::test_that("returns an error if the TYPE_DATA is a 'folder' or 'file' but it does not exist", {
  
  skip_test_if_no_modules(c("pymongo", "bson"))
  
  PATH_invalid = paste0(getwd(), path.expand("/UNKNOWN/"))
  
  testthat::expect_error( init$geoInsert(DATA = PATH_invalid, TYPE_DATA = 'folder', COLLECTION = init_col, GEOMETRY_NAME = "location", read_method = 'geojsonR') )
})


testthat::test_that("returns an error if the TYPE_DATA is not one of 'folder', 'file', 'dict_one', 'dict_many'", {
  
  skip_test_if_no_modules(c("pymongo", "bson"))
  
  testthat::expect_error( init$geoInsert(DATA = PATH, TYPE_DATA = 'UNKNOWN', COLLECTION = init_col, GEOMETRY_NAME = "location", read_method = 'geojsonR') )
})


testthat::test_that("returns an error if the read_method is not one of 'geojsonR', 'mongo_bson'", {
  
  skip_test_if_no_modules(c("pymongo", "bson"))
  
  testthat::expect_error( init$geoInsert(DATA = PATH, TYPE_DATA = 'folder', COLLECTION = init_col, GEOMETRY_NAME = "location", read_method = 'INVALID') )
})


testthat::test_that("returns an error if the DATA is not a list or a character string (vector) and TYPE_DATA is 'folder' or 'file'", {
  
  skip_test_if_no_modules(c("pymongo", "bson"))
  
  mtrx = matrix(0, 3, 2)
  
  testthat::expect_error( init$geoInsert(DATA = mtrx, TYPE_DATA = 'folder', COLLECTION = init_col, GEOMETRY_NAME = "location", read_method = 'geojsonR') )
})


testthat::test_that("returns an error if the DATA is not a list or a character string (vector) and TYPE_DATA is 'dict_one' or 'dict_many'", {
  
  skip_test_if_no_modules(c("pymongo", "bson"))
  
  mtrx = matrix(0, 3, 2)
  
  testthat::expect_error( init$geoInsert(DATA = mtrx, TYPE_DATA = 'dict_one', COLLECTION = init_col, GEOMETRY_NAME = "location", read_method = 'geojsonR') )
})

#-----------------------------
# expect true geoInsert method
#-----------------------------

testthat::test_that("it returns the correct number of items after insertion of geojson objects", {
  
  skip_test_if_no_modules(c("pymongo", "bson"))
  
  FUNC_insert(init_col)
  
  testthat::expect_true( init_col$count() == 4 )
})


#===================================================================== geoQuery

#---------------------------------
# Error handling "geoQuery" method
#---------------------------------


testthat::test_that("returns an error if the QUERY parameter is not a named list", {
  
  skip_test_if_no_modules(c("pymongo", "bson"))
  
  mtrx = matrix(0, 3, 2)
  
  testthat::expect_error( init$geoQuery(QUERY = mtrx, METHOD = "aggregate", COLLECTION = init_col, DATABASE = NULL, GEOMETRY_NAME = "location", TO_LIST = FALSE) )
})


testthat::test_that("returns an error if the COLLECTION parameter is not specified", {
  
  skip_test_if_no_modules(c("pymongo", "bson"))
  
  init = geomongo$new(host = 'localhost', port = 27017)       # use default configuration [ localhost ]
  
  init_client = init$getClient()
  
  init_db = init_client$get_database("test")
  
  init_col = FUNC_COL("geomongo_class")
  
  testthat::expect_error( init$geoQuery(QUERY = query_geonear, METHOD = "aggregate", COLLECTION = NULL, DATABASE = NULL, GEOMETRY_NAME = "location", TO_LIST = FALSE) )
})


testthat::test_that("returns a warning if the COLLECTION or the GEOMETRY_NAME parameter is already specified", {
  
  skip_test_if_no_modules(c("pymongo", "bson"))
  
  init = geomongo$new(host = 'localhost', port = 27017)       # use default configuration [ localhost ]
  
  init_client = init$getClient()
  
  init_db = init_client$get_database("test")
  
  init_col = FUNC_COL("geomongo_class")
  
  tmp = init$geoQuery(QUERY = query_geonear, METHOD = "aggregate", COLLECTION = init_col, DATABASE = NULL, GEOMETRY_NAME = "location", TO_LIST = FALSE)
  
  testthat::expect_warning( init$geoQuery(QUERY = query_geonear, METHOD = "aggregate", COLLECTION = init_col, DATABASE = NULL, GEOMETRY_NAME = "location", TO_LIST = FALSE) )
})


testthat::test_that("returns an error if the DATABASE parameter is NULL and the METHOD equals to 'command'", {
  
  skip_test_if_no_modules(c("pymongo", "bson"))
  
  testthat::expect_error( init$geoQuery(QUERY = query_geonear, METHOD = "command", COLLECTION = init_col, DATABASE = NULL, GEOMETRY_NAME = "location", TO_LIST = FALSE) )
})


testthat::test_that("returns an error if the DATABASE parameter is not NULL and the METHOD equals a character string other than 'command'", {
  
  skip_test_if_no_modules(c("pymongo", "bson"))
  
  testthat::expect_error( init$geoQuery(QUERY = query_geonear, METHOD = "aggregate", COLLECTION = init_col, DATABASE = init_db, GEOMETRY_NAME = "location", TO_LIST = FALSE) )
})


testthat::test_that("returns an error if the GEOMETRY_NAME parameter is NULL (and not already specified)", {
  
  skip_test_if_no_modules(c("pymongo", "bson"))
  
  init = geomongo$new(host = 'localhost', port = 27017)       # use default configuration [ localhost ]
  
  init_client = init$getClient()
  
  init_db = init_client$get_database("test")
  
  init_col = FUNC_COL("geomongo_class")
  
  testthat::expect_error( init$geoQuery(QUERY = query_geonear, METHOD = "aggregate", COLLECTION = init_col, DATABASE = NULL, GEOMETRY_NAME = NULL, TO_LIST = FALSE) )
})


testthat::test_that("returns an error if the METHOD parameter is other than 'aggregate', 'find' or 'command'", {
  
  skip_test_if_no_modules(c("pymongo", "bson"))
  
  testthat::expect_error( init$geoQuery(QUERY = query_geonear, METHOD = "INVALID", COLLECTION = init_col, DATABASE = NULL, GEOMETRY_NAME = "location", TO_LIST = FALSE) )
})

#-------------------------------
# expect true "geoQuery" method
#-------------------------------


testthat::test_that("it returns the correct output ('geonear' [ using 'aggregate' ])", {
  
  skip_test_if_no_modules(c("pymongo", "bson"))
  
  res = init$geoQuery(QUERY = query_geonear, METHOD = "aggregate", COLLECTION = init_col, DATABASE = NULL, GEOMETRY_NAME = "location", TO_LIST = FALSE)
  
  testthat::expect_true( inherits(res, "data.table") && nrow(res) == 3 )
})


testthat::test_that("it returns the correct output ('nearSphere' [ using 'find' ])", {
  
  skip_test_if_no_modules(c("pymongo", "bson"))
  
  res = init$geoQuery(QUERY = query_nearSphere, METHOD = "find", COLLECTION = init_col, DATABASE = NULL, GEOMETRY_NAME = "location", TO_LIST = T)
  
  testthat::expect_true( inherits(res, "list") && length(res) == 3 )
})


testthat::test_that("it returns the correct output ('geoIntersects' [ using 'find' ])", {
  
  skip_test_if_no_modules(c("pymongo", "bson"))
  
  res = init$geoQuery(QUERY = query_geoIntersects, METHOD = "find", COLLECTION = init_col, DATABASE = NULL, GEOMETRY_NAME = "location", TO_LIST = FALSE)
  
  testthat::expect_true( inherits(res, "data.table") && nrow(res) == 1 )
})


testthat::test_that("it returns the correct output ('geoWithin' [ using 'find' ])", {
  
  skip_test_if_no_modules(c("pymongo", "bson"))
  
  res = init$geoQuery(QUERY = query_geoWithin, METHOD = "find", COLLECTION = init_col, DATABASE = NULL, GEOMETRY_NAME = "location", TO_LIST = T)
  
  testthat::expect_true( inherits(res, "list") && length(res) == 1 )
})


testthat::test_that("it returns the correct output ('geoWithin-centerSphere' [ using 'find' ])", {
  
  skip_test_if_no_modules(c("pymongo", "bson"))
  
  res = init$geoQuery(QUERY = query_geoWithin_sph, METHOD = "find", COLLECTION = init_col, DATABASE = NULL, GEOMETRY_NAME = "location", TO_LIST = F)
  
  testthat::expect_true( inherits(res, "data.table") && nrow(res) == 2 )
})


#=================================================================== geoqueries based on bulk import : https://docs.mongodb.com/manual/tutorial/geospatial-tutorial/


#---------------neighborhoods

if (.Platform$OS.type == "unix") {
  
  testthat::test_that("it returns the correct output (for neighborhoods)", {
    
    skip_test_if_no_modules(c("pymongo", "bson"))
    
    ints = init$geoQuery(QUERY = QUER, METHOD = "find", COLLECTION = init_neighb, GEOMETRY_NAME = 'geometry', TO_LIST = TRUE)       # ints : the returned list is an un-named list of length 1 [ this un-named list will include all other sublists ]
    
    res = ints[[1]]['geometry']$geometry                                                                                            # extract the 'geometry' object by taking the first list ( ints[[1]] )
    
    testthat::expect_true( inherits(res, "list") && length(ints[[1]]['geometry']$geometry$coordinates[[1]]) == 323 )
  })
}


if (.Platform$OS.type == "unix") {
  
  testthat::test_that("it returns the correct output (for restaurants taking into account the neighborhoods output)", {
    
    skip_test_if_no_modules(c("pymongo", "bson"))
    
    ints = init$geoQuery(QUERY = QUER, METHOD = "find", COLLECTION = init_neighb, GEOMETRY_NAME = 'geometry', TO_LIST = TRUE)
    
    # take the result from the previous 'QUER'
    #-----------------------------------------
    
    QUER_rest = list('location' =
                       
                       list('$geoWithin' =
                              
                              list('$geometry' =
                                     
                                     ints[[1]]['geometry']$geometry)
                       )
    )
    
    ints_rest = init$geoQuery(QUERY = QUER_rest, METHOD = "find", COLLECTION = init_rest, GEOMETRY_NAME = 'location', TO_LIST = F)
    
    testthat::expect_true( inherits(ints_rest, "data.table") && nrow(ints_rest) == 127 )
  })
}


##############################################################################################################################################################
#-------------------------------------------------------------------------------------
# UNCOMMENT THOSE TWO TESTS ON TRAVIS WHEN USING MongoDB (>= 3.4) AND Python (>= 3.5)
#-------------------------------------------------------------------------------------

# testthat::test_that("it returns the correct output (restaurants - geowithin)", {
#
#   skip_test_if_no_modules(c("pymongo", "bson"))
#
#   quer_geowithin = init$geoQuery(QUERY = rest_geowithin, METHOD = "find", COLLECTION = init_rest, GEOMETRY_NAME = 'location', TO_LIST = T)
#
#   #-------------------------------------------------------------------
#
#   # THIS QUERY WORKS ON PYTHON 3.0 BUT NOT ON PYTHON 2.7 ( DUE TO DIFFERENCE ON HOW EACH VERSION HANDLES CHARACTER STRINGS )
#
#   # RETURNS THE FOLLOWING ERROR:
#
#   # Error in py_str_impl(object) :
#   #   UnicodeEncodeError: 'ascii' codec can't encode character u'\xe9' in position 17: ordinal not in range(128)
#
#   # REFERENCES : https://www.reddit.com/r/Python/comments/2onenk/understanding_python_unicode_handling/,
#                  http://agiliq.com/blog/2014/12/understanding-python-unicode-str-unicodeencodeerro/
#
#   #-------------------------------------------------------------------
#
#   testthat::expect_true( inherits(quer_geowithin, "list") )
# })



#---------------nearSphere ( returns all restaurants within five miles of the user in sorted order from nearest to farthest )


# testthat::test_that("it returns the correct output (restaurants - nearSphere)", {
#
#   skip_test_if_no_modules(c("pymongo", "bson"))
#
#   quer_nearSphere = init$geoQuery(QUERY = QUER_nearsph, METHOD = "find", COLLECTION = init_rest, GEOMETRY_NAME = 'location', TO_LIST = F)
#
#   testthat::expect_true( inherits(quer_nearSphere, "data.table")  )
# })
##############################################################################################################################################################


#=================================================================== "command" method AND insert "dict_many" [ nested list ]


testthat::test_that("it inserts data from a nested list and runs the 'command' method", {
  
  skip_test_if_no_modules(c("pymongo", "bson"))
  
  init_places = FUNC_COL("places")
  
  FUNC_insert_places = function(collection) {
    
    if (collection$count() == 0) {
      
      init$geoInsert(DATA = NESTED, TYPE_DATA = 'dict_many', COLLECTION = collection, GEOMETRY_NAME = 'location', read_method = 'geojsonR')
    }
  }
  
  FUNC_insert_places(init_places)
  
  Args_Kwargs = list("geoNear", "places",
                     
                     near = list("type" = "Point", "coordinates" = c(-73.9667, 40.78)),
                     
                     spherical = TRUE,
                     
                     query = list("category" = "Parks"))
  
  res = init$geoQuery(QUERY = Args_Kwargs, METHOD = "command", COLLECTION = init_places, DATABASE = init_db, GEOMETRY_NAME = "location", TO_LIST = F)
  
  testthat::expect_true( inherits(res, "data.table") && nrow(res) == 2 )
})

#=========================================================================================== 'json_schema_validator' function

testthat::test_that("it returns an error if the 'json_data' is not a named list ", {
  
  skip_test_if_no_modules("jsonschema")
  
  mtrx = matrix(0, 3, 2)
  
  testthat::expect_error( json_schema_validator(json_data = mtrx, json_schema = schema_dict) )
})



testthat::test_that("it returns an error if the 'json_schema' is not a named list ", {
  
  skip_test_if_no_modules("jsonschema")
  
  mtrx = matrix(0, 3, 2)
  
  testthat::expect_error( json_schema_validator(json_data = data_dict, json_schema = mtrx) )
})


testthat::test_that("it returns an error if the 'json_schema' is not a named list ", {
  
  skip_test_if_no_modules("jsonschema")
  
  testthat::expect_silent( json_schema_validator(json_data = data_dict, json_schema = schema_dict) )
})
