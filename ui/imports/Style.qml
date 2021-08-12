pragma Singleton

import QtQuick 2.13
import QtQuick.Controls.Universal 2.12
import "./Themes" as Legacy

import StatusQ.Core.Theme 0.1

QtObject {
    property Legacy.Theme current: lightTheme
    property Legacy.Theme lightTheme: Legacy.LightTheme {}
    property Legacy.Theme darkTheme: Legacy.DarkTheme {}


    property ThemePalette statusQLightTheme: StatusLightTheme {}
    property ThemePalette statusQDarkTheme: StatusDarkTheme {}

    property var changeTheme: function (theme, isCurrentSystemThemeDark) {

        switch (theme) {
            case Universal.Light:
              current = lightTheme;
              Theme.palette = statusQLightTheme
              break;
            case Universal.Dark:
              current = darkTheme;
              Theme.palette = statusQDarkTheme
              break;
            case Universal.System:
              current = isCurrentSystemThemeDark? darkTheme : lightTheme;
              Theme.palette = isCurrentSystemThemeDark? statusQDarkTheme : statusQLightTheme
              break;
            default:
              console.log('Unknown theme. Valid themes are "light" and "dark"')
        }
    }

    property var changeFontSize: function (fontSize) {
        current.updateFontSize(fontSize)
    }
}
