prefix=@CMAKE_INSTALL_PREFIX@
exec_prefix=@CMAKE_INSTALL_PREFIX@
libdir=@CMAKE_INSTALL_FULL_LIBDIR@
sharedlibdir=@CMAKE_INSTALL_FULL_LIBDIR@
includedir=@CMAKE_INSTALL_FULL_INCLUDEDIR@

Name: @PROJECT_NAME@
Description: C language library for creating bindings for the Qt QML language
Version: @DOTHERSIDE_VERSION@

Requires: @PC_REQUIRES@
Libs: -L${libdir} -lDOtherSide
Cflags: -I${includedir}

