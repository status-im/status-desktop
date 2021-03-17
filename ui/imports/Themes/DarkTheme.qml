import QtQuick 2.13
import "."

Theme {
    property string name: "dark"

    property color white: "#FFFFFF"
    property color white2: "#FCFCFC"
    property color black: "#000000"
    property color almostBlack: "#141414"
    property color grey: "#EEF2F5"
    property color lightGrey: "#7A7A7A"
    property color midGrey: "#7f8990"
    property color darkGrey: "#373737"
    property color evenDarkerGrey: "#4b4b4b"
    property color lightBlue: "#ECEFFC"
    property color cyan: "#00FFFF"
    property color blue: "#88B0FF"
    property color darkAccentBlue: "#2946C4"
    property color transparent: "#00000000"
    property color lightBlueText: "#8f9fec"
    property color darkBlue: "#3c55c9"
    property color darkBlueBtn: "#5a70dd"
    property color red: "#FF5C7B"
    property color lightRed: "#FFEAEE"
    property color green: "#4EBC60"
    property color turquoise: "#007b7d"
    property color tenPercentWhite: Qt.rgba(255, 255, 255, 0.1)
    property color tenPercentBlue: Qt.rgba(67, 96, 223, 0.1)

    property color background: "#212121"
    property color border: darkGrey
    property color borderSecondary: tenPercentWhite
    property color borderTertiary: blue
    property color textColor: white
    property color textColorTertiary: blue
    property color currentUserTextColor: white
    property color secondaryBackground: "#353a4d"
    property color inputBackground: darkGrey
    property color inputBorderFocus: blue
    property color inputColor: textColor
    property color modalBackground: darkGrey
    property color backgroundHover: evenDarkerGrey
    property color backgroundHoverLight: darkGrey
    property color secondaryText: lightGrey
    property color secondaryHover: tenPercentWhite
    property color primary: blue
    property color danger: red
    property color success: green
    property color primaryMenuItemHover: blue
    property color primaryMenuItemTextHover: almostBlack
    property color backgroundTertiary: tenPercentBlue
    property color pillButtonTextColor: secondaryText
    property color chatReplyCurrentUser: lightGrey
    property color codeBackground: "#2E386B"
    property color primarySelectionColor: "#b4c8ff"
    property color emojiReactionBackground: "#2d2823"
    property color emojiReactionBackgroundHovered: "#3a3632"
    property color emojiReactionActiveBackgroundHovered: "#cbd5f1"
    property color mentionColor: "#7BE5FF"
    property color mentionBgColor: "#1a0da4c9"
    property color mentionMessageColor: "#1a0da4c9"
    property color mentionMessageHoverColor: "#330da4c9"
    property color replyBackground: "#484848"
    
    property color buttonForegroundColor: blue
    property color buttonBackgroundColor: secondaryBackground
    property color buttonSecondaryColor: darkGrey
    property color buttonDisabledForegroundColor: lightGrey
    property color buttonDisabledBackgroundColor: darkGrey
    property color buttonWarnBackgroundColor: "#FFEAEE"
    property color buttonOutlineHoveredWarnBackgroundColor: "#4dff5c7b"
    property color buttonHoveredWarnBackgroundColor: red
    property color buttonHoveredBackgroundColor: blue

    property color contextMenuButtonForegroundColor: midGrey

    property color roundedButtonForegroundColor: white
    property color roundedButtonBackgroundColor: secondaryBackground
    property color roundedButtonSecondaryForegroundColor: black
    property color roundedButtonSecondaryBackgroundColor: buttonForegroundColor
    property color roundedButtonSecondaryHoveredBackgroundColor: "#AAC6FF"
    property color roundedButtonDisabledForegroundColor: buttonDisabledForegroundColor
    property color roundedButtonDisabledBackgroundColor: buttonDisabledBackgroundColor
    property color roundedButtonSecondaryDisabledForegroundColor: black
    property color roundedButtonSecondaryDisabledBackgroundColor: lightGrey
    property color tooltipBackgroundColor: white
    property color tooltipForegroundColor: black

    property var accountColors: [
        "#AAC6FF",
        "#EAD27B",
        "#E6ABFC",
        "#10A88E",
        "#FB8383",
        "#93DB33",
        "#ADA3FF",
        "#AD4343"
    ]
}
