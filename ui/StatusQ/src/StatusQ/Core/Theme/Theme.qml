pragma Singleton

import QtQuick 2.15

QtObject {
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

    property ThemePalette palette: StatusLightTheme {}

    readonly property ThemePalette statusQLightTheme: StatusLightTheme {}
    readonly property ThemePalette statusQDarkTheme: StatusDarkTheme {}

    readonly property string assetPath: Qt.resolvedUrl("../../../assets/")

    function changeTheme(theme:int, isCurrentSystemThemeDark:bool) {
        switch (theme) {
        case Theme.Style.Light:
            Theme.palette = statusQLightTheme
            break
        case Theme.Style.Dark:
            Theme.palette = statusQDarkTheme
            break
        case Theme.Style.System:
            Theme.palette = isCurrentSystemThemeDark ? statusQDarkTheme : statusQLightTheme
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

    property int secondaryAdditionalTextSize: 17
    property int primaryTextFontSize: 15
    property int secondaryTextFontSize: 14
    property int additionalTextSize: 13
    property int tertiaryTextFontSize: 12
    property int asideTextFontSize: 10

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
    readonly property int defaultSmallPadding: defaultPadding * 0.75
    readonly property int defaultRadius: defaultHalfPadding

    readonly property real disabledOpacity: 0.3
    readonly property real pressedOpacity: 0.7

    function updateFontSize(fontSize:int) {
        switch (fontSize) {
            case Theme.FontSizeXS:
                secondaryAdditionalTextSize = 15
                primaryTextFontSize = 13
                secondaryTextFontSize = 12
                additionalTextSize = 11
                tertiaryTextFontSize = 10
                asideTextFontSize = 8
                break;

            case Theme.FontSizeS:
                secondaryAdditionalTextSize = 16
                primaryTextFontSize = 14
                secondaryTextFontSize = 13
                additionalTextSize = 12
                tertiaryTextFontSize = 11
                asideTextFontSize = 9
                break;

            case Theme.FontSizeM:
                secondaryAdditionalTextSize = 17
                primaryTextFontSize = 15
                secondaryTextFontSize = 14
                additionalTextSize = 13
                tertiaryTextFontSize = 12
                asideTextFontSize = 10
                break;

            case Theme.FontSizeL:
                secondaryAdditionalTextSize = 18
                primaryTextFontSize = 16
                secondaryTextFontSize = 15
                additionalTextSize = 14
                tertiaryTextFontSize = 13
                asideTextFontSize = 11
                break;

            case Theme.FontSizeXL:
                secondaryAdditionalTextSize = 19
                primaryTextFontSize = 17
                secondaryTextFontSize = 16
                additionalTextSize = 15
                tertiaryTextFontSize = 14
                asideTextFontSize = 12
                break;

            case Theme.FontSizeXXL:
                secondaryAdditionalTextSize = 20
                primaryTextFontSize = 18
                secondaryTextFontSize = 17
                additionalTextSize = 16
                tertiaryTextFontSize = 15
                asideTextFontSize = 13
                break;
        }
    }

    function updatePaddings(basePadding:int) {
        xlPadding = basePadding * 2
        bigPadding = basePadding * 1.5
        padding = basePadding
        halfPadding = basePadding / 2
        smallPadding = basePadding * 0.75
        radius = basePadding
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
}
