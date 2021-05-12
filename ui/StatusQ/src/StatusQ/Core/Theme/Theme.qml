pragma Singleton

import QtQuick 2.13

QtObject {
    id: appTheme
    // Replace it with:
    //      property QtObject palette: StatusLightTheme {}
    // for reloading
    property ThemePalette palette: StatusLightTheme {}

    function setTheme(theme) {
        palette = theme
    }
}


