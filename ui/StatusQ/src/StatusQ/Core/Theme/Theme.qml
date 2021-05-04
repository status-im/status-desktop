pragma Singleton

import QtQuick 2.13

QtObject {
    id: appTheme
    property ThemePalette palette: StatusLightTheme {}

    function setTheme(theme) {
        palette = theme
    }
}


