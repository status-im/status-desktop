pragma Singleton

import QtQuick 2.13
import QtQuick.Controls.Universal 2.12
import "../Themes" as Legacy

import StatusQ.Core.Theme 0.1

QtObject {
    property Legacy.Theme current: lightTheme
    property Legacy.Theme lightTheme: Legacy.LightTheme {}
    property Legacy.Theme darkTheme: Legacy.DarkTheme {}


    property ThemePalette statusQLightTheme: StatusLightTheme {}
    property ThemePalette statusQDarkTheme: StatusDarkTheme {}

    readonly property int screenWidth: 1400
    readonly property int screenHeight: 840
    readonly property int minimumScreenWidth: 900
    readonly property int minimumScreenHeight: 600
    property real scaleFactor: 1.0

    function dp(value) {
        return (value * scaleFactor);
    }

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

    property string assetPath: Qt.resolvedUrl("./../assets/")
    function png(name) {
        return assetPath + "png/" + name + ".png";
    }
    function svg(name) {
        return assetPath + "icons/" + name + ".svg";
    }
    function emoji(name) {
        return "qrc:/StatusQ/src/assets/twemoji/svg/" + name + ".svg";
    }
    function lottie(name) {
        return assetPath + "lottie/" + name + ".json";
    }
    function gif(name) {
        return assetPath + "gif/" + name + ".gif";
    }
}
