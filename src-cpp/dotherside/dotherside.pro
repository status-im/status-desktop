include(../common/common.pri)

TEMPLATE = lib
QT += gui core quick
CONFIG += static c++17

TARGET = dotherside

SOURCES += \
   DOtherSide.cpp \
   SpellChecker.cpp \
   StatusWindow.cpp \
   StatusSyntaxHighlighter.cpp

HEADERS += \
   DOtherSide.h \
   SpellChecker.h \
   StatusWindow.h \
   StatusSyntaxHighlighter.h

ios {
   OBJECTIVE_SOURCES += \
       StatusWindow_osx.mm
}
