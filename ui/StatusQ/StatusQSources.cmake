set(STATUSQ_DIR ${CMAKE_CURRENT_LIST_DIR})

set(STATUSQ_HEADERS
    ${STATUSQ_DIR}/include/StatusQ/statuswindow.h
    ${STATUSQ_DIR}/include/StatusQ/typesregistration.h
    ${STATUSQ_DIR}/include/StatusQ/QClipboardProxy.h
    ${STATUSQ_DIR}/include/StatusQ/statussyntaxhighlighter.h
    ${STATUSQ_DIR}/include/StatusQ/rxvalidator.h
)

set(STATUSQ_SOURCES
    ${STATUSQ_DIR}/src/statuswindow.cpp
    ${STATUSQ_DIR}/src/typesregistration.cpp
    ${STATUSQ_DIR}/src/QClipboardProxy.cpp
    ${STATUSQ_DIR}/src/statussyntaxhighlighter.cpp
    ${STATUSQ_DIR}/src/rxvalidator.cpp
)

if(APPLE)
    list(APPEND STATUSQ_SOURCES
        ${STATUSQ_DIR}/src/statuswindow_osx.mm
    )
else()
    list(APPEND STATUSQ_SOURCES
        ${STATUSQ_DIR}/src/statuswindow_other.cpp
    )
endif()
