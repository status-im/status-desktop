pragma Singleton

import QtQml
import QtQuick
import QtQuick.Window

import StatusQ.Core.Theme

QtObject {
    enum Style {
        Light,
        Dark,
        System
    }

    enum FontSize {
        FontSizeXS,
        FontSizeS,
        FontSizeM,
        FontSizeL,
        FontSizeXL,
        FontSizeXXL
    }

    enum PaddingFactor {
        PaddingXXS,
        PaddingXS,
        PaddingS,
        PaddingM,
        PaddingL
    }

    enum AnimationDuration {
        Fast = 100,
        Default = 250, // https://doc.qt.io/qt-5/qml-qtquick-propertyanimation.html#duration-prop
        Slow = 400
    }

    readonly property size portraitBreakpoint: Qt.size(1200, 680)
    readonly property real disabledOpacity: 0.3
    readonly property real pressedOpacity: 0.7

    function setTheme(target: QtObject, theme: int) {
        switch (theme) {
        case ThemeUtils.Style.Light:
            target.Theme.style = Theme.Style.Light
            break
        case ThemeUtils.Style.Dark:
            target.Theme.style = Theme.Style.Dark
            break
        case ThemeUtils.Style.System:
            target.Theme.style = Qt.binding(() => Application.styleHints.colorScheme === Qt.ColorScheme.Dark
                                            ? Theme.Style.Dark : Theme.Style.Light)
            break
        default:
            console.warn('Unknown theme. Valid themes are "light" and "dark"')
        }
    }

    function setFontSize(target: QtObject, fontSize: int) {
        switch (fontSize) {
            case ThemeUtils.FontSizeXS:
                target.Theme.fontSizeOffset = -2
                break
            case ThemeUtils.FontSizeS:
                target.Theme.fontSizeOffset = -1
                break
            case ThemeUtils.FontSizeM:
                target.Theme.fontSizeOffset = 0
                break
            case ThemeUtils.FontSizeL:
                target.Theme.fontSizeOffset = 1
                break
            case ThemeUtils.FontSizeXL:
                target.Theme.fontSizeOffset = 2
                break
            case ThemeUtils.FontSizeXXL:
                target.Theme.fontSizeOffset = 3
                break
        }
    }

    function setPaddingFactor(target: QtObject, paddingFactor: int) {
        switch (paddingFactor) {
        case ThemeUtils.PaddingXXS:
            target.Theme.padding = target.Theme.defaultPadding * 0.4
            break
        case ThemeUtils.PaddingXS:
            target.Theme.padding = target.Theme.defaultPadding * 0.6
            break
        case ThemeUtils.PaddingS:
            target.Theme.padding = target.Theme.defaultPadding * 0.8
            break
        case ThemeUtils.PaddingM:
            target.Theme.padding = target.Theme.defaultPadding
            break
        case ThemeUtils.PaddingL:
            target.Theme.padding = target.Theme.defaultPadding * 1.2
            break
        }
    }
}
