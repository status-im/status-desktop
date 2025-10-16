pragma Singleton

import QtQuick

import StatusQ.Core.Utils as SQUtils

SQUtils.QObject {
    enum FontSize {
        FontSizeXS,
        FontSizeS,
        FontSizeM,
        FontSizeL,
        FontSizeXL,
        FontSizeXXL
    }

    enum Style {
        Light,
        Dark,
        System
    }

    property ThemePalette palette: Application.styleHints.colorScheme === Qt.ColorScheme.Dark ? statusQDarkTheme : statusQLightTheme

    readonly property ThemePalette statusQLightTheme: StatusLightTheme {}
    readonly property ThemePalette statusQDarkTheme: StatusDarkTheme {}

    readonly property bool isDarkTheme: palette === statusQDarkTheme

    readonly property string assetPath: Qt.resolvedUrl("../../../assets/")

    function changeTheme(theme:int) {
        switch (theme) {
        case Theme.Style.Light:
            Theme.palette = statusQLightTheme
            break
        case Theme.Style.Dark:
            Theme.palette = statusQDarkTheme
            break
        case Theme.Style.System:
            Theme.palette = Application.styleHints.colorScheme === Qt.ColorScheme.Dark ? statusQDarkTheme : statusQLightTheme
            break
        default:
            console.warn('Unknown theme. Valid themes are "light" and "dark"')
        }
    }

    function changeFontSize(fontSize:int) {
        updateFontSize(fontSize)
    }

    readonly property var baseFont: FontLoader {
        source: assetPath + "fonts/Inter/Inter-Regular.otf"
    }

    readonly property var monoFont: FontLoader {
        source: assetPath + "fonts/InterStatus/InterStatus-Regular.otf"
    }

    readonly property var codeFont: FontLoader {
        source: assetPath + "fonts/RobotoMono/RobotoMono-Regular.ttf"
    }

    readonly property var _d: QtObject {
        // specific font variants should not be accessed directly

        // Inter font variants
        property var baseFontThin: FontLoader {
            source: assetPath + "fonts/Inter/Inter-Thin.otf"
        }

        property var baseFontExtraLight: FontLoader {
            source: assetPath + "fonts/Inter/Inter-ExtraLight.otf"
        }

        property var baseFontLight: FontLoader {
            source: assetPath + "fonts/Inter/Inter-Light.otf"
        }

        property var baseFontMedium: FontLoader {
            source: assetPath + "fonts/Inter/Inter-Medium.otf"
        }

        property var baseFontBold: FontLoader {
            source: assetPath + "fonts/Inter/Inter-Bold.otf"
        }

        property var baseFontExtraBold: FontLoader {
            source: assetPath + "fonts/Inter/Inter-ExtraBold.otf"
        }

        property var baseFontBlack: FontLoader {
            source: assetPath + "fonts/Inter/Inter-Black.otf"
        }

        // Inter Status font variants
        property var monoFontThin: FontLoader {
            source: assetPath + "fonts/InterStatus/InterStatus-Thin.otf"
        }

        property var monoFontExtraLight: FontLoader {
            source: assetPath + "fonts/InterStatus/InterStatus-ExtraLight.otf"
        }

        property var monoFontLight: FontLoader {
            source: assetPath + "fonts/InterStatus/InterStatus-Light.otf"
        }

        property var monoFontMedium: FontLoader {
            source: assetPath + "fonts/InterStatus/InterStatus-Medium.otf"
        }

        property var monoFontBold: FontLoader {
            source: assetPath + "fonts/InterStatus/InterStatus-Bold.otf"
        }

        property var monoFontExtraBold: FontLoader {
            source: assetPath + "fonts/InterStatus/InterStatus-ExtraBold.otf"
        }

        property var monoFontBlack: FontLoader {
            source: assetPath + "fonts/InterStatus/InterStatus-Black.otf"
        }

        // Roboto font variants
        property var codeFontThin: FontLoader {
            source: assetPath + "fonts/RobotoMono/RobotoMono-Thin.ttf"
        }

        property var codeFontExtraLight: FontLoader {
            source: assetPath + "fonts/RobotoMono/RobotoMono-ExtraLight.ttf"
        }

        property var codeFontLight: FontLoader {
            source: assetPath + "fonts/RobotoMono/RobotoMono-Light.ttf"
        }

        property var codeFontMedium: FontLoader {
            source: assetPath + "fonts/RobotoMono/RobotoMono-Medium.ttf"
        }

        property var codeFontBold: FontLoader {
            source: assetPath + "fonts/RobotoMono/RobotoMono-Bold.ttf"
        }
    }

    readonly property int secondaryAdditionalTextSize: fontSize17
    readonly property int primaryTextFontSize: fontSize15
    readonly property int secondaryTextFontSize: fontSize14
    readonly property int additionalTextSize: fontSize13
    readonly property int tertiaryTextFontSize: fontSize12
    readonly property int asideTextFontSize: fontSize10

    readonly property int fontSize9: 9 + dynamicFontUnits
    readonly property int fontSize10: 10 + dynamicFontUnits
    readonly property int fontSize11: 11 + dynamicFontUnits
    readonly property int fontSize12: 12 + dynamicFontUnits
    readonly property int fontSize13: 13 + dynamicFontUnits
    readonly property int fontSize14: 14 + dynamicFontUnits
    readonly property int fontSize15: 15 + dynamicFontUnits
    readonly property int fontSize16: 16 + dynamicFontUnits
    readonly property int fontSize17: 17 + dynamicFontUnits
    readonly property int fontSize18: 18 + dynamicFontUnits
    readonly property int fontSize19: 19 + dynamicFontUnits
    readonly property int fontSize20: 20 + dynamicFontUnits
    readonly property int fontSize21: 21 + dynamicFontUnits
    readonly property int fontSize22: 22 + dynamicFontUnits
    readonly property int fontSize23: 23 + dynamicFontUnits
    readonly property int fontSize24: 24 + dynamicFontUnits
    readonly property int fontSize25: 25 + dynamicFontUnits
    readonly property int fontSize26: 26 + dynamicFontUnits
    readonly property int fontSize27: 27 + dynamicFontUnits
    readonly property int fontSize28: 28 + dynamicFontUnits
    readonly property int fontSize29: 29 + dynamicFontUnits
    readonly property int fontSize30: 30 + dynamicFontUnits
    readonly property int fontSize34: 34 + dynamicFontUnits
    readonly property int fontSize38: 38 + dynamicFontUnits
    readonly property int fontSize40: 40 + dynamicFontUnits


    // Responsive properties used for responsive components (e.g. containers)
    property int xlPadding: defaultXlPadding
    property int bigPadding: defaultBigPadding
    property int padding: defaultPadding
    property int halfPadding: defaultHalfPadding
    property int smallPadding: defaultSmallPadding
    property int radius: defaultRadius

    // Constant properties used for non-responsive components (e.g. buttons)
    readonly property int defaultXlPadding: defaultPadding * 2
    readonly property int defaultBigPadding: defaultPadding * 1.5
    readonly property int defaultPadding: 16
    readonly property int defaultHalfPadding: defaultPadding / 2
    readonly property int defaultSmallPadding: defaultPadding * 0.625
    readonly property int defaultRadius: defaultHalfPadding

    readonly property var portraitBreakpoint: Qt.size(1200, 680)

    readonly property real disabledOpacity: 0.3
    readonly property real pressedOpacity: 0.7

    property int dynamicFontUnits: 0

    readonly property int currentFontSize: d.fontSize

    function updateFontSize(fontSize:int) {
        d.fontSize = fontSize
        switch (fontSize) {
            case Theme.FontSizeXS:
                dynamicFontUnits = -2
                break;

            case Theme.FontSizeS:
                dynamicFontUnits = -1
                break;

            case Theme.FontSizeM:
                dynamicFontUnits = 0
                break;

            case Theme.FontSizeL:
                dynamicFontUnits = 1
                break;

            case Theme.FontSizeXL:
                dynamicFontUnits = 2
                break;

            case Theme.FontSizeXXL:
                dynamicFontUnits = 3
                break;
        }
    }

    function updatePaddings(basePadding:int) {
        xlPadding = basePadding * 2
        bigPadding = basePadding * 1.5
        padding = basePadding
        halfPadding = basePadding / 2
        smallPadding = basePadding * 0.625
    }

    enum AnimationDuration {
        Fast = 100,
        Default = 250, // https://doc.qt.io/qt-5/qml-qtquick-propertyanimation.html#duration-prop
        Slow = 400
    }

    // Style compat
    function png(name) {
        return assetPath + "png/" + name + ".png"
    }
    function svg(name) {
        return assetPath + "img/icons/" + name + ".svg"
    }
    function emoji(name) {
        return assetPath + "twemoji/svg/" + name + ".svg"
    }


    QtObject {
        id: d

        property int fontSize: Theme.FontSizeM
    }
}
