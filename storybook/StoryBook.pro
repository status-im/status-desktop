QT += core \
    quick \
    quickcontrols2 \
    svg \ #
    xml \ # svg, xml and gui modules are needed to render .svg files
    gui \ #

CONFIG += c++17 \
        qtquickcompiler \ #enable Qt Qtuick compiler by default
        import_plugins    #Run qmlimportscanner on current folder and on the folders defined in QMLPATHS

#Add storybook qml code
storybook_resources.files += $$files("$$PWD/*.qml", true)
storybook_resources.files += $$files("$$PWD/*.js", true)
storybook_resources.files += $$files("$$PWD/*qmldir", true)
storybook_resources.files += $$files("$$PWD/*.json", true)
#Adding storybook prefix to match the folder structure
storybook_resources.prefix = storybook

#Add status desktop qml code
ui_resources.files += $$files("$$PWD/../ui/*.qml", true)
ui_resources.files += $$files("$$PWD/../ui/*.js", true)
ui_resources.files += $$files("$$PWD/../ui/*qmldir", true)
ui_resources.files += $$files("$$PWD/../ui/*.json", true)
#Add status desktop assets
ui_resources.files += $$files("$$PWD/../ui/*.svg", true)
ui_resources.files += $$files("$$PWD/../ui/*.png", true)
ui_resources.files += $$files("$$PWD/../ui/*.ico", true)
ui_resources.files += $$files("$$PWD/../ui/*.icns", true)
ui_resources.files += $$files("$$PWD/../ui/*.mp3", true)
ui_resources.files += $$files("$$PWD/../ui/*.wav", true)
ui_resources.files += $$files("$$PWD/../ui/*.otf", true)
ui_resources.files += $$files("$$PWD/../ui/*.ttf", true)
ui_resources.files += $$files("$$PWD/../ui/*.webm", true)
ui_resources.files += $$files("$$PWD/../ui/*.qm", true)
ui_resources.files += $$files("$$PWD/../ui/*.txt", true)
ui_resources.files += $$files("$$PWD/../ui/*.gif", true)

RESOURCES += \
        storybook_resources \   #Storybook qrc file
        ui_resources \          #Status desktop qrc file

#Get all header files recursively
HEADERS += $$files("$$PWD/*.h", true)
HEADERS -= $$files("$$PWD/tests/*.h", true)
#Get all cpp files recursively
SOURCES += $$files("$$PWD/*.cpp", true)
SOURCES -= $$files("$$PWD/tests/*.cpp", true)

#Hint qmlimportscanner where to look for dependencies
QMLPATHS += "$$PWD/../ui" \
            "$$PWD/../ui/imports" \
            "$$PWD/../ui/app" \
            "$$PWD/../ui/StatusQ" \
            "$$PWD/../ui/StatusQ/src" \
            "$$PWD/../ui/StatusQ/src/StatusQ"

#Hint Qt Creator what qml modules will be using
QML_IMPORT_PATH += "$$QMLPATHS"

#QML_IMPORT_ROOT is used to compose the qml import paths set in the qmlEngine
DEFINES += QML_IMPORT_ROOT=\\\"qrc:/storybook\\\"

#Include SortFilterProxyModel plugin
include(../ui/StatusQ/vendor/SortFilterProxyModel/SortFilterProxyModel.pri)

#We need to explicitly set -s TOTAL_MEMORY at least to the linker, otherwise the linking step will fail
#while validating the resulted .js file
#1Gb is probably the max amount of memory the browser will allow
QMAKE_WASM_TOTAL_MEMORY=1GB

#In case we might use threads
QMAKE_WASM_PTHREAD_POOL_SIZE = 4
