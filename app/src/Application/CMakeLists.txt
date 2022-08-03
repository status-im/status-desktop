# Required by QML_ELEMENT
target_include_directories(${PROJECT_NAME}
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}
)

target_sources(${PROJECT_NAME}
    PRIVATE
        ApplicationController.h
        ApplicationController.cpp
        DataProvider.h
        DataProvider.cpp
        DbSettingsObj.h
        DbSettingsObj.cpp

        CMakeLists.txt
)
