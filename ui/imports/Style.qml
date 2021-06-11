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


    property var changeTheme: function (theme) {
        switch (theme) {
            case Universal.Light:
              current = lightTheme; 
              Theme.palette = statusQLightTheme
              break;
            case Universal.Dark:
              current = darkTheme; 
              Theme.palette = statusQDarkTheme
              break;
            default: 
              current = lightTheme; 
              Theme.palette = statusQLightTheme
              console.log('Unknown theme. Valid themes are "light" and "dark"')
        }
    }

    property var changeFontSize: function (fontSize) {
        current.updateFontSize(fontSize)
    }
}
