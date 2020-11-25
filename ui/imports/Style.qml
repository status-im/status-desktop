pragma Singleton

import QtQuick 2.13
import "./Themes"

QtObject {
    property Theme current: lightTheme
    property Theme lightTheme: LightTheme {}
    property Theme darkTheme: DarkTheme {}

    property var changeTheme: function (theme) {
        switch (theme) {
            case "light": current = lightTheme; break;
            case "dark": current = darkTheme; break;
            default: current = lightTheme; console.log('Unknown theme. Valid themes are "light" and "dark"')
        }

    }

    property var changeFontSize: function (fontSize) {
        current.updateFontSize(fontSize)
    }
}
