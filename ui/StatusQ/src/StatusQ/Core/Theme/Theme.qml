pragma Singleton

import QtQuick 2.13

QtObject {
    id: appTheme

    enum FontSize {
        FontSizeXS,
        FontSizeS,
        FontSizeM,
        FontSizeL,
        FontSizeXL,
        FontSizeXXL
    }

    property ThemePalette palette: StatusLightTheme {}

    property int primaryTextFontSize: 15
    property int secondaryTextFontSize: 14
    property int tertiaryTextFontSize: 12
    property int asideTextFontSize: 10

    function setTheme(theme) {
        palette = theme
    }

    function updateFontSize(fontSize) {
        switch (fontSize) {
            case Theme.FontSizeXS:
                primaryTextFontSize = 13
                secondaryTextFontSize = 12
                tertiaryTextFontSize = 10
                asideTextFontSize = 8
                break;

            case Theme.FontSizeS:
                primaryTextFontSize = 14
                secondaryTextFontSize = 13
                tertiaryTextFontSize = 11
                asideTextFontSize = 9
                break;

            case Theme.FontSizeM:
                primaryTextFontSize = 15
                secondaryTextFontSize = 14
                tertiaryTextFontSize = 12
                asideTextFontSize = 10
                break;

            case Theme.FontSizeL:
                primaryTextFontSize = 16
                secondaryTextFontSize = 15
                tertiaryTextFontSize = 13
                asideTextFontSize = 11
                break;

            case Theme.FontSizeXL:
                primaryTextFontSize = 17
                secondaryTextFontSize = 16
                tertiaryTextFontSize = 14
                asideTextFontSize = 12
                break;

            case Theme.FontSizeXXL:
                primaryTextFontSize = 18
                secondaryTextFontSize = 17
                tertiaryTextFontSize = 15
                asideTextFontSize = 13
                break;
        }
    }
}
