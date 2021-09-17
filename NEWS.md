
## GeoMongo 1.0.3

* I've added a 'packageStartupMessage' informing the user in case of the error 'attempt to apply non-function' that he/she has to use the 'reticulate::py_config()' before loading the package (in a new R session)


## GeoMongo 1.0.2

* I've added the *CITATION* file in the *inst* directory
* I've removed *Lazydata* from the DESCRIPTION file


## GeoMongo 1.0.1

I fixed a bug in the *geoInsert* method of the *geomongo* class (replaced file.exists() with dir.exists() for a folder of files). I added an *ellipsis* in mongodb_console() function to allow for additional parameters for the system() (unix) and shell() (windows) command line functions.


## GeoMongo 1.0.0




