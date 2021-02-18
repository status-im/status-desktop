import QtQuick 2.13
import "../"

QtObject {
    property QtObject fontMedium: FontLoader { id: _fontMedium; source: "../../fonts/Inter/Inter-Medium.otf"; }
    property QtObject fontBold: FontLoader { id: _fontBold; source: "../../fonts/Inter/Inter-Bold.otf"; }
    property QtObject fontLight: FontLoader { id: _fontLight; source: "../../fonts/Inter/Inter-Light.otf"; }
    property QtObject fontRegular: FontLoader { id: _fontRegular; source: "../../fonts/Inter/Inter-Regular.otf"; }

    property QtObject fontHexMedium: FontLoader { id: _fontHexMedium; source: "../../fonts/InterStatus/InterStatus-Medium.otf"; }
    property QtObject fontHexBold: FontLoader { id: _fontHexBold; source: "../../fonts/InterStatus/InterStatus-Bold.otf"; }
    property QtObject fontHexLight: FontLoader { id: _fontHexLight; source: "../../fonts/InterStatus/InterStatus-Light.otf"; }
    property QtObject fontHexRegular: FontLoader { id: _fontHexRegular; source: "../../fonts/InterStatus/InterStatus-Regular.otf"; }

    property color white
    property color white2
    property color black
    property color grey
    property color lightBlue
    property color blue
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
    property color backgroundHover
    property color backgroundHoverLight
    property color border
    property color textColor
    property color secondaryText
    property color currentUserTextColor
    property color secondaryBackground
    property color modalBackground
    property color codeBackground
    property color primarySelectioncolor
    property color emojiReactionBackground
    property color emojiReactionBackgroundHovered
    property color emojiReactionActiveBackgroundHovered
    property color mentionColor
    property color mentionBgColor
    property color mentionMessageColor
    property color mentionMessageHoverColor

    property color buttonForegroundColor
    property color buttonBackgroundColor
    property color buttonSecondaryColor
    property color buttonDisabledForegroundColor
    property color buttonDisabledBackgroundColor
    property color buttonWarnBackgroundColor
    property color roundedButtonForegroundColor
    property color roundedButtonBackgroundColor
    property color roundedButtonSecondaryBackgroundColor
    property color tooltipBackgroundColor
    property color tooltipForegroundColor

    property int xlPadding: 32
    property int bigPadding: 24
    property int padding: 16
    property int halfPadding: 8
    property int smallPadding: 10
    property int radius: 8

    property int leftTabPrefferedSize: 340
    property int leftTabMinimumWidth: 300
    property int leftTabMaximumWidth: 500

    property int primaryTextFontSize: 15
    property int secondaryTextFontSize: 14
    property int tertiaryTextFontSize: 12
    property int asideTextFontSize: 10

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
