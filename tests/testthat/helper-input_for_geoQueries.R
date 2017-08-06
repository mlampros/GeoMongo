#--------------------------------
# 'geonear' [ using 'aggregate' ]

query_geonear = list('$geoNear' =

                       list(near =

                              list(

                                type = "Point",

                                coordinates = c(-122.5, 37.1)),

                            distanceField = "distance",

                            maxDistance = 900 * 1609.34,

                            distanceMultiplier = 1 / 1609.34,

                            spherical = TRUE)
                     )


#------------------------------
# 'nearSphere' [ using 'find' ]

query_nearSphere = list('location' =

                          list('$nearSphere' =

                                 list('$geometry' =

                                        list(

                                          type = 'Point',

                                          coordinates = c(-122.5, 37.1)),

                                      '$maxDistance' = 900 * 1609.34)
                               )
                        )


#------------------------------
# 'geoIntersects' [ using 'find' ]

query_geoIntersects = list('location' =

                             list('$geoIntersects' =

                                    list('$geometry' =

                                           list(

                                             type = "Polygon",

                                             coordinates = list(

                                               list(

                                                 c(-109, 41),

                                                 c(-102, 41),

                                                 c(-102, 37),

                                                 c(-109, 37),

                                                 c(-109, 41)

                                                 )
                                               )
                                             )
                                         )
                                  )
                           )


#------------------------------
# 'geoWithin' [ using 'find' ]

query_geoWithin = list('location' =

                         list('$geoWithin' =

                                list('$geometry' =

                                       list(

                                         type = "Polygon",

                                         coordinates = list(

                                           list(

                                             c(-109, 41),

                                             c(-102, 41),

                                             c(-102, 37),

                                             c(-109, 37),

                                             c(-109, 41)
                                             )
                                           )
                                         )
                                     )
                              )
                       )


#------------------------------
# 'geoWithin-centerSphere' [ using 'find' ]

query_geoWithin_sph = list('location' =

                             list('$geoWithin' =

                                    list('$centerSphere' =

                                           list(

                                             c(-122.5, 37.7), 300 / 3963.2)
                                         )
                                  )
                           )

#============================================================= geoqueries based on bulk import : https://docs.mongodb.com/manual/tutorial/geospatial-tutorial/


#---------------neighborhoods

QUER = list('geometry' =

              list('$geoIntersects' =

                     list('$geometry' =

                            list(

                              'type' = 'Point',

                              'coordinates' = c(-73.93414657, 40.82302903)
                              )
                          )
                   )
            )



#---------------- restaurants - geowithin


rest_geowithin = list('location' =

                        list('$geoWithin' =

                               list('$centerSphere' =

                                      list(

                                        c(-73.93414657, 40.82302903 ), 5 / 3963.2 )
                                    )
                             )
                      )


#--------------- restaurants - nearSphere

# returns all restaurants within five miles of the user in sorted order from nearest to farthest

QUER_nearsph = list('location' =

                      list('$nearSphere' =

                             list('$geometry' =

                                    list(

                                      'type' = 'Point',

                                      'coordinates' =

                                        c(-73.93414657, 40.82302903)),

                                  '$maxDistance' = 5 * 1609.34)
                           )
                    )



#--------------------- https://docs.mongodb.com/manual/geospatial-queries/


NESTED = list(list('name' = "Central Park", 'location' =  list('type' = "Point", 'coordinates' = c(-73.97, 40.77)), 'category' = "Parks"),
              list('name' = "Sara D. Roosevelt Park", 'location' =  list('type' = "Point", 'coordinates' = c(-73.9928, 40.7193)), 'category' = "Parks"),
              list('name' = "Polo Grounds", 'location' =  list('type' = "Point", 'coordinates' = c(-73.9375, 40.8303)), 'category' = "Stadiums"))


#--------------------- 'json_schema_validator' function

schema_dict = list("type" = "object",

                   "properties" = list(

                     "name" = list("type" = "string"),

                     "location" = list("type" = "object",

                                       "properties" = list(

                                         "type" = list("enum" = c("Point", "Polygon")),                     # in case that "type" is at the same time also a property name do not include "type" = "string" , https://github.com/epoberezkin/ajv/issues/137

                                         #"type1" = list("type" = "string", "enum" = c("Point", "Polygon")),

                                         "coordinates" = list("type" = "array")
                                       ))))

data_dict = list("name" = "Squaw Valley", "location" = list("type" = "Point", "coordinates" = c(-120.24, 39.21)))


