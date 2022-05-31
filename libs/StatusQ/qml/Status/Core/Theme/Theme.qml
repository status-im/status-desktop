pragma Singleton

import QtQuick

import QtQuick.Controls.Universal 2.12

/*!
  Convenience type for easy access to StatusTheme
 */
QtObject {
    property StatusTheme current: lightTheme
    property bool isLightTheme: current === lightTheme
    readonly property StatusTheme lightTheme: StatusLightTheme {}
    readonly property StatusTheme darkTheme: StatusDarkTheme {}

    property QtObject baseFont: FontLoader {
        source: "qrc:/Status/FontsAssets/Inter/Inter-Regular.otf"
    }

    property StatusPalette palette: current.palette

    property var changeTheme: function (universalTheme, isCurrentSystemThemeDark) {
        switch (universalTheme) {
            case Universal.Light:
              current = lightTheme;
              break;
            case Universal.Dark:
              current = darkTheme;
              break;
            case Universal.System:
              current = isCurrentSystemThemeDark? darkTheme : lightTheme;
              break;
            default:
              console.warning('Unknown theme. Valid themes are "light" and "dark"')
        }
    }
}
