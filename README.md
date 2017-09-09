
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/GeoMongo)](http://cran.r-project.org/package=GeoMongo)
[![Travis-CI Build Status](https://travis-ci.org/mlampros/GeoMongo.svg?branch=master)](https://travis-ci.org/mlampros/GeoMongo)
[![codecov.io](https://codecov.io/github/mlampros/GeoMongo/coverage.svg?branch=master)](https://codecov.io/github/mlampros/GeoMongo?branch=master)
[![AppVeyor build status](https://ci.appveyor.com/api/projects/status/github/mlampros/GeoMongo?branch=master&svg=true)](https://ci.appveyor.com/project/mlampros/GeoMongo/branch/master)
[![Downloads](http://cranlogs.r-pkg.org/badges/grand-total/GeoMongo?color=blue)](http://www.r-pkg.org/pkg/GeoMongo)



## GeoMongo
<br>

The **GeoMongo** package utilizes methods of the [*PyMongo*](https://api.mongodb.com/python/current/#) Python library to initialize, insert and query GeoJson data. Furthermore, it allows the user to validate GeoJson objects and to use the console for [*MongoDB*](https://www.mongodb.com/) (bulk) commands. The [*reticulate*](https://github.com/rstudio/reticulate) package provides the R interface to Python modules, classes and functions. More details on the functionality of GeoMongo can be found in the [blog post](http://mlampros.github.io/2017/08/07/the_GeoMongo_package/) and in the package Vignette.


<br>

### **System Requirements**

<br>

* [MongoDB (>= 3.4.0)](https://docs.mongodb.com/manual/installation/)

* Python (>= 2.7)

* [PyMongo](http://api.mongodb.com/python/current/installation.html) (to install use : **python -m pip install pymongo**)

* [jsonschema](https://pypi.python.org/pypi/jsonschema) (to install use : **python -m pip install jsonschema**)


<br>

### **Installation of the GeoMongo package**

<br>

To install the package from CRAN use, 

```R

install.packages('GeoMongo')

```
<br>

and to download the latest version from Github use the *install_github* function of the devtools package,
<br><br>

```R

devtools::install_github(repo = 'mlampros/GeoMongo')

```
<br>
Use the following link to report bugs/issues,
<br><br>

[https://github.com/mlampros/GeoMongo/issues](https://github.com/mlampros/GeoMongo/issues)

<br>

