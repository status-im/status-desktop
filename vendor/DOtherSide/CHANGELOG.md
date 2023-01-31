# Version 0.6.4
* Added support for QCoreApplication::processEvents
* Added support for QObject::deleteLater
* Added support for QObject::readProperty and QObject::writeProperty
* Added support for QPixmap::isNull and QPixmap:: assign functions
* Added optional support for QtQuickControls2 and setting style

# Version 0.6.3
* Added soversion and version to CMake
* Fixed #57: Added support for QModelIndex internal pointer
* Added support for QAbstractItemModel::hasIndex

# Version 0.6.2
* Updated appveyor packages by adding 5.8 and removing 5.5 and 5.7

# Version 0.6.1
* Fixed compilation on windows with Visual studio 2013 and 2015

# Version 0.6.0
* Fixed #48: Added support QAbstractItemModel and QAbstractTableModels
* Added missing canFetchMore, fetchMore, hasChildren callbacks
* Fixed #46: Added support for index, createIndex
* Fixed #45: Added support for setting the qml signal names (old behaviour was arg0, arg1..)
* Added support

# Version 0.5.2
* Added support qmlRegisterType
* Added support qmlRegisterSingletonType
* Added support for creating QObject in the binded language
* Added support for using signal arguments from qml with names arg0, arg1 etc
* Introduced the concept of QMetaObject in the binded language
* Greatly reduced memory consumption of QObject by using QMetaObjects
* Greatly improved creation speed of QObjects
* Removed undefined behaviour when casting to void*
* Lots of refactoring and code cleanups
* New architecture for slots and signal invokation
* Added support for building the project with meson build system
* Added appveyor for creating pre built binaries for windows
* Improved the test suite

# Version 0.4.5
* Removed the D bindings
* Removed the Nim bindings

# Version 0.4.2
* [DOtherSide] Code cleanup and little refactoring
* [NimQml] Made nim compiles with the "cpp" option by default. This should fix C/C++ interop problems

# Version 0.4.1
* [DQml] Added support for code generation of slots, signals and properties by using custom UDAs
* [DQml] Updated the examples with the new attributes for code generation
* [NimQml] Little fix for adding fixing compilation with Nim 0.11.0

# Version 0.4.0
* [DQml] Inheritance of slots and signals is now supported
* [DQml] Added support for QAbstractListModel subclasses
* [DQml] Put on par the examples for matching those in NimQml
* [NimQml] Fixed AbstractItemModel example
* [NimQml] Initial support for windows builds with Visual Studio community edition
* [DOtherSide] Initial support for windows build
* [DOtherSide] Removed most warnings and code cleanup

# Version 0.3.0
* [NimQml] Added support for QAbstractListModel subclasses
* [NimQml] Fixed QtObject macro wrong reorder of the methods and proc declaration (thanks to Will)
* [NimQml] Added new ContactApp example
* [NimQml] Added optional support for finalizers
* [DOtherSide] Added support for injecting the DynamicQObject as behaviour to QObject subclasses
* [DotherSide] Added support for QAbstractListModel subclasses

# Version 0.2.0
* [DQml] Initial support for properties creation
* [NimQml] Added new macro syntax for creating QObject derived object (thanks to Will)

# Version 0.1.0
* [DOtherSide] Initial version with support for QObject Slot, Signal and Properties creation
* [DQml] Initial support for Slot and Signal creation
* [NimQml] Initial support for Slot, Signal and Properties creation
