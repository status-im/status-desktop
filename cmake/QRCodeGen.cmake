# QR-Code-generator
# TODO: create a PR in that project to build it like we do with status-go ^
set(QRCODE_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/vendor/QR-Code-generator)
set(QRCODE_LIB_DIR ${QRCODE_ROOT}/cpp)
ExternalProject_Add(libqrcodegen
  PREFIX ${QRCODE_ROOT}
  SOURCE_DIR ${QRCODE_ROOT}
  UPDATE_COMMAND ""
  PATCH_COMMAND ""
  CONFIGURE_COMMAND ""
  INSTALL_COMMAND ""
  BUILD_IN_SOURCE 1
  BUILD_COMMAND make -C cpp libqrcodegen.a V=1
  BUILD_BYPRODUCTS ${QRCODE_LIB_DIR}/libqrcodegen.a
)
ExternalProject_Get_Property(libqrcodegen SOURCE_DIR)
add_library(qrcodegen STATIC IMPORTED)
set_property(TARGET qrcodegen PROPERTY IMPORTED_LOCATION ${QRCODE_LIB_DIR}/libqrcodegen.a)
add_dependencies(qrcodegen libqrcodegen)
include_directories(${QRCODE_LIB_DIR})
