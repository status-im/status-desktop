pragma Singleton

import QtQml
import QtQuick.Window

import StatusQ.Theme

QtObject {
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
