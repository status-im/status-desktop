import QtQuick 2.14

import utils 1.0

QtObject {
    readonly property FontLoader baseFont: FontLoader { source: "../../fonts/Inter/Inter-Regular.otf" }
    readonly property FontLoader monoFont: FontLoader { source: "../../fonts/InterStatus/InterStatus-Regular.otf" }
    readonly property FontLoader codeFont: FontLoader { source: "../../fonts/RobotoMono/RobotoMono-Regular.ttf" }

    readonly property QtObject _d: QtObject {
        readonly property FontLoader baseFontMedium: FontLoader { source: "../../fonts/Inter/Inter-Medium.otf" }
        readonly property FontLoader baseFontBold: FontLoader { source: "../../fonts/Inter/Inter-Bold.otf" }
        readonly property FontLoader baseFontLight: FontLoader { source: "../../fonts/Inter/Inter-Light.otf" }

        readonly property FontLoader monoFontMedium: FontLoader { source: "../../fonts/InterStatus/InterStatus-Medium.otf" }
        readonly property FontLoader monoFontBold: FontLoader { source: "../../fonts/InterStatus/InterStatus-Bold.otf" }
        readonly property FontLoader monoFontLight: FontLoader { source: "../../fonts/InterStatus/InterStatus-Light.otf" }
    }

    property string name

    property color white
    property color white2
    property color black
    property color grey1
    property color lightBlue
    property color blue
    property color translucentBlue
    property color transparent
    property color darkGrey
    property color darkerGrey
    property color evenDarkerGrey
    property color lightBlueText
    property color darkBlue
    property color darkBlueBtn
    property color red
    property color purple: "#887AF9"
    property color orange: "#FE8F59"

    property color background
    property color dropShadow
    property color backgroundHover
    property color backgroundHoverLight
    property color border
    property color textColor
    property color linkColor
    property color secondaryText
    property color currentUserTextColor
    property color secondaryBackground
    property color secondaryMenuBorder
    property color menuBackgroundActive
    property color menuBackgroundHover
    property color modalBackground
    property color codeBackground
    property color primarySelectioncolor
    property color emojiReactionBackground
    property color emojiReactionBackgroundHovered
    property color emojiReactionActiveBackgroundHovered
    property color mentionColor
    property color mentionBgColor
    property color mentionBgHoverColor
    property color mentionMessageColor
    property color mentionMessageHoverColor
    property color mainMenuBackground
    property color secondaryMenuBackground
    property color tabButtonBg

    property color buttonForegroundColor
    property color buttonBackgroundColor
    property color buttonBackgroundColorHover
    property color buttonSecondaryColor
    property color buttonDisabledForegroundColor
    property color buttonDisabledBackgroundColor
    property color buttonWarnBackgroundColor
    property color roundedButtonForegroundColor
    property color roundedButtonBackgroundColor
    property color roundedButtonSecondaryBackgroundColor
    property color tooltipBackgroundColor
    property color tooltipForegroundColor

    property color pinnedMessageBorder
    property color pinnedMessageBackground
    property color pinnedMessageBackgroundHovered
    property color pinnedRectangleBackground

    property int xlPadding: 32
    property int bigPadding: 24
    property int padding: 16
    property int halfPadding: 8
    property int smallPadding: 10
    property int radius: 8

    property int leftTabPreferredSize: 304

    property int additionalTextSize: 13

    property int primaryTextFontSize: 15
    property int secondaryTextFontSize: 14
    property int tertiaryTextFontSize: 12
    property int asideTextFontSize: 10

    property var accountColors

    function updateFontSize(fontSize) {
        switch (fontSize) {
            case Constants.fontSizeXS:
                primaryTextFontSize = 13
                secondaryTextFontSize = 12
                tertiaryTextFontSize = 10
                asideTextFontSize = 8
                break;

            case Constants.fontSizeS:
                primaryTextFontSize = 14
                secondaryTextFontSize = 13
                tertiaryTextFontSize = 11
                asideTextFontSize = 9
                break;

            case Constants.fontSizeM:
                primaryTextFontSize = 15
                secondaryTextFontSize = 14
                tertiaryTextFontSize = 12
                asideTextFontSize = 10
                break;

            case Constants.fontSizeL:
                primaryTextFontSize = 16
                secondaryTextFontSize = 15
                tertiaryTextFontSize = 13
                asideTextFontSize = 11
                break;

            case Constants.fontSizeXL:
                primaryTextFontSize = 17
                secondaryTextFontSize = 16
                tertiaryTextFontSize = 14
                asideTextFontSize = 12
                break;

            case Constants.fontSizeXXL:
                primaryTextFontSize = 18
                secondaryTextFontSize = 17
                tertiaryTextFontSize = 15
                asideTextFontSize = 13
                break;
        }
    }
}
