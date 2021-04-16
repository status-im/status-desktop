pragma Singleton

import QtQuick 2.13
import QtQuick.Controls.Universal 2.12
import "./Themes"

QtObject {
    property Theme current: lightTheme
    property Theme lightTheme: LightTheme {}
    property Theme darkTheme: DarkTheme {}

    property var changeTheme: function (theme) {
        switch (theme) {
            case Universal.Light: current = lightTheme; break;
            case Universal.Dark: current = darkTheme; break;
            default: current = lightTheme; console.log('Unknown theme. Valid themes are "light" and "dark"')
        }
    }

    property var changeFontSize: function (fontSize) {
        current.updateFontSize(fontSize)
    }
}
