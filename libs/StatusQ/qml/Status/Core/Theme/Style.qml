pragma Singleton

import QtQuick
//import QtQuick.Controls.Universal

QtObject {
    property StatusTheme theme: lightTheme
    property StatusPalette palette: theme.palette
    readonly property StatusTheme lightTheme: StatusLightTheme {}
    readonly property StatusTheme darkTheme: StatusDarkTheme {}

    property var changeTheme: function (palette, isCurrentSystemThemeDark) {
        switch (theme) {
            case Universal.Light:
              theme = lightTheme;
              break;
            case Universal.Dark:
              theme = darkTheme;
              break;
            case Universal.System:
              current = isCurrentSystemThemeDark? darkTheme : lightTheme;
              break;
            default:
              console.warning('Unknown theme. Valid themes are "light" and "dark"')
        }
    }
}
