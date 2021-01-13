import QtQuick 2.13
import "."

Theme {
    property color white: "#FFFFFF"
    property color white2: "#FCFCFC"
    property color black: "#000000"
    property color almostBlack: "#141414"
    property color grey: "#EEF2F5"
    property color lightGrey: "#ccd0d4"
    property color lightBlue: "#ECEFFC"
    property color cyan: "#00FFFF"
    property color blue: "#758EF0"
    property color darkAccentBlue: "#2946C4"
    property color transparent: "#00000000"
    property color darkGrey: "#838C91"
    property color evenDarkerGrey: "#252528"
    property color lightBlueText: "#8f9fec"
    property color darkBlue: "#3c55c9"
    property color darkBlueBtn: "#5a70dd"
    property color red: "#FC5F5F"
    property color lightRed: "#FFEAEE"
    property color green: "#4EBC60"
    property color turquoise: "#007b7d"
    property color tenPercentWhite: Qt.rgba(255, 255, 255, 0.1)
    property color tenPercentBlue: Qt.rgba(67, 96, 223, 0.1)

    property color background: almostBlack
    property color border: evenDarkerGrey
    property color borderSecondary: tenPercentWhite
    property color borderTertiary: blue
    property color textColor: white
    property color textColorTertiary: blue
    property color currentUserTextColor: white
    property color secondaryBackground: "#23252F"
    property color inputBackground: secondaryBackground
    property color inputBorderFocus: blue
    property color inputColor: darkGrey
    property color modalBackground: background
    property color backgroundHover: evenDarkerGrey
    property color secondaryText: darkGrey
    property color secondaryHover: tenPercentWhite
    property color primary: blue
    property color danger: red
    property color success: green
    property color primaryMenuItemHover: blue
    property color primaryMenuItemTextHover: almostBlack
    property color backgroundTertiary: tenPercentBlue
    property color pillButtonTextColor: almostBlack
    property color chatReplyCurrentUser: lightGrey
    property color topBarChatInfoColor: evenDarkerGrey
    property color codeBackground: "#2E386B"
    property color primarySelectionColor: "#b4c8ff"

    property color buttonForegroundColor: blue
    property color buttonBackgroundColor: secondaryBackground
    property color buttonSecondaryColor: darkGrey
    property color buttonDisabledForegroundColor: buttonSecondaryColor
    property color buttonDisabledBackgroundColor: evenDarkerGrey
    property color buttonWarnBackgroundColor: "#FFEAEE"

    property color roundedButtonForegroundColor: white
    property color roundedButtonBackgroundColor: secondaryBackground
    property color roundedButtonSecondaryForegroundColor: white
    property color roundedButtonSecondaryBackgroundColor: buttonForegroundColor
    property color roundedButtonSecondaryHoveredBackgroundColor: darkAccentBlue
    property color roundedButtonDisabledForegroundColor: buttonDisabledForegroundColor
    property color roundedButtonDisabledBackgroundColor: buttonDisabledBackgroundColor
    property color roundedButtonSecondaryDisabledForegroundColor: roundedButtonForegroundColor
    property color roundedButtonSecondaryDisabledBackgroundColor: buttonDisabledForegroundColor
}
