INCLUDEPATH += \
    $$PWD/../app/include \
    $$PWD/../app/boot \
    $$PWD/../app/modules/shared \
    $$PWD/../app/modules/main \
    $$PWD/../app/modules/startup

LIBS += -L$$PWD/../build_ios/app -lapp
