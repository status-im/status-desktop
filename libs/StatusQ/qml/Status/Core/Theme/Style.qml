pragma Singleton

import QtQuick

/*!
  The main entry point into presentation layer customization
 */
Item {
    readonly property StatusPalette palette: Theme.palette
    readonly property StatusTheme theme: Theme.current

    readonly property alias geometry: geometryObject

    StatusLayouting {
        id: geometryObject
    }
}
