import QtQuick 2.13
import utils 1.0

QtObject {
    property QtObject fontMedium: FontLoader { id: _fontMedium; source: "../../fonts/Inter/Inter-Medium.otf"; }
    property QtObject fontBold: FontLoader { id: _fontBold; source: "../../fonts/Inter/Inter-Bold.otf"; }
    property QtObject fontLight: FontLoader { id: _fontLight; source: "../../fonts/Inter/Inter-Light.otf"; }
    property QtObject fontRegular: FontLoader { id: _fontRegular; source: "../../fonts/Inter/Inter-Regular.otf"; }

    property QtObject fontHexMedium: FontLoader { id: _fontHexMedium; source: "../../fonts/InterStatus/InterStatus-Medium.otf"; }
    property QtObject fontHexBold: FontLoader { id: _fontHexBold; source: "../../fonts/InterStatus/InterStatus-Bold.otf"; }
    property QtObject fontHexLight: FontLoader { id: _fontHexLight; source: "../../fonts/InterStatus/InterStatus-Light.otf"; }
    property QtObject fontHexRegular: FontLoader { id: _fontHexRegular; source: "../../fonts/InterStatus/InterStatus-Regular.otf"; }

    property QtObject fontCodeRegular: FontLoader { id: _fontCodeRegular; source: "../../fonts/RobotoMono/RobotoMono-Regular.ttf"; }

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

    property int xlPadding: Style.dp(32)
    property int bigPadding: Style.dp(24)
    property int padding: Style.dp(16)
    property int halfPadding: Style.dp(8)
    property int smallPadding: Style.dp(10)
    property int radius: Style.dp(8)

    property int leftTabPreferredSize: Style.dp(304)

    property int additionalTextSize: Style.dp(13)

    property int primaryTextFontSize: Style.dp(15)
    property int secondaryTextFontSize: Style.dp(14)
    property int tertiaryTextFontSize: Style.dp(12)
    property int asideTextFontSize: Style.dp(10)

    property var accountColors

    function updateFontSize(fontSize) {
        switch (fontSize) {
            case Constants.fontSizeXS:
                primaryTextFontSize = Style.dp(13)
                secondaryTextFontSize = Style.dp(12)
                tertiaryTextFontSize = Style.dp(10)
                asideTextFontSize = Style.dp(8)
                break;

            case Constants.fontSizeS:
                primaryTextFontSize = Style.dp(14)
                secondaryTextFontSize = Style.dp(13)
                tertiaryTextFontSize = Style.dp(11)
                asideTextFontSize = Style.dp(9)
                break;

            case Constants.fontSizeM:
                primaryTextFontSize = Style.dp(15)
                secondaryTextFontSize = Style.dp(14)
                tertiaryTextFontSize = Style.dp(12)
                asideTextFontSize = Style.dp(10)
                break;

            case Constants.fontSizeL:
                primaryTextFontSize = Style.dp(16)
                secondaryTextFontSize = Style.dp(15)
                tertiaryTextFontSize = Style.dp(13)
                asideTextFontSize = Style.dp(11)
                break;

            case Constants.fontSizeXL:
                primaryTextFontSize = Style.dp(17)
                secondaryTextFontSize = Style.dp(16)
                tertiaryTextFontSize = Style.dp(14)
                asideTextFontSize = Style.dp(12)
                break;

            case Constants.fontSizeXXL:
                primaryTextFontSize = Style.dp(18)
                secondaryTextFontSize = Style.dp(17)
                tertiaryTextFontSize = Style.dp(15)
                asideTextFontSize = Style.dp(13)
                break;
        }
    }
}
