# Keycard
# TODO: create a PR in that project to build it like we do with status-go ^
set(KEYCARD_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/vendor/status-lib/vendor/nim-keycard-go)
set(KEYCARD_LIB_DIR ${KEYCARD_ROOT}/go/keycard/build/libkeycard)
ExternalProject_Add(libkeycard
  PREFIX ${KEYCARD_ROOT}
  SOURCE_DIR ${KEYCARD_ROOT}
  UPDATE_COMMAND ""
  PATCH_COMMAND ""
  CONFIGURE_COMMAND ""
  INSTALL_COMMAND ""
  BUILD_IN_SOURCE 1
  BUILD_COMMAND make build-keycard-go V=1
  BUILD_BYPRODUCTS ${KEYCARD_LIB_DIR}/libkeycard${CMAKE_SHARED_LIBRARY_SUFFIX}
)
ExternalProject_Get_Property(libkeycard SOURCE_DIR)
add_library(keycard SHARED IMPORTED)
set_property(TARGET keycard PROPERTY IMPORTED_LOCATION ${KEYCARD_LIB_DIR}/libkeycard${CMAKE_SHARED_LIBRARY_SUFFIX})
add_dependencies(keycard libkeycard)
include_directories(${KEYCARD_LIB_DIR})
