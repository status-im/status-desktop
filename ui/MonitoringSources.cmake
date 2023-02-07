set(MONITORING_INCLUDE_PATH ${CMAKE_CURRENT_LIST_DIR}/include)

set(MONITORING_HEADERS
    ${MONITORING_INCLUDE_PATH}/StatusDesktop/Monitoring/Monitor.h
    ${MONITORING_INCLUDE_PATH}/StatusDesktop/Monitoring/ContextPropertiesModel.h
)

set(MONITORING_SOURCES
    ${CMAKE_CURRENT_LIST_DIR}/src/StatusDesktop/Monitoring/Monitor.cpp
    ${CMAKE_CURRENT_LIST_DIR}/src/StatusDesktop/Monitoring/ContextPropertiesModel.cpp
)
