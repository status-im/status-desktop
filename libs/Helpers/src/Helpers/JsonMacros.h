#pragma once

#include "Macros.h"

#define STATUS_READ_NLOHMAN_JSON_PROPERTY_3_ARGS(FIELD, NAME, REQUIRED)                                                \
    if(REQUIRED)                                                                                                       \
        j.at(NAME).get_to(d.FIELD);                                                                                    \
    else if(j.contains(NAME))                                                                                          \
        j.at(NAME).get_to(d.FIELD);

#define STATUS_READ_NLOHMAN_JSON_PROPERTY_2_ARGS(FIELD, NAME)                                                          \
    STATUS_READ_NLOHMAN_JSON_PROPERTY_3_ARGS(FIELD, NAME, true)

#define STATUS_READ_NLOHMAN_JSON_PROPERTY_1_ARGS(FIELD) STATUS_READ_NLOHMAN_JSON_PROPERTY_2_ARGS(FIELD, #FIELD)

// This macro reads prop from the nlohman json object. It implies that nlohman json object is named `j` and the struct
// instance that json object should be mapped to is named `d`.
//
// If the field is required this macro reads a property from nlohmann json object and sets it to the passed field,
// in case the property doesn't exist an error is thrown.
//
// If the field is not required this macro reads a property from nlohmann json object and sets it to the passed field
// only if the property exists it cannot throws an error ever.
//
// Usage: STATUS_READ_NLOHMAN_JSON_PROPERTY(field)
//        STATUS_READ_NLOHMAN_JSON_PROPERTY(field, "realFieldName")
//        STATUS_READ_NLOHMAN_JSON_PROPERTY(field, "realFieldName", false)
//
#define STATUS_READ_NLOHMAN_JSON_PROPERTY(...)                                                                         \
    STATUS_EXPAND(STATUS_MACRO_SELECTOR_3_ARGS(__VA_ARGS__,                                                            \
                                               STATUS_READ_NLOHMAN_JSON_PROPERTY_3_ARGS,                               \
                                               STATUS_READ_NLOHMAN_JSON_PROPERTY_2_ARGS,                               \
                                               STATUS_READ_NLOHMAN_JSON_PROPERTY_1_ARGS)(__VA_ARGS__))
