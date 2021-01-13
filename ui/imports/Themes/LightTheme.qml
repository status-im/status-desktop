import QtQuick 2.13
import "."

Theme {
    property color white: "#FFFFFF"
    property color white2: "#FCFCFC"
    property color black: "#000000"
    property color grey: "#EEF2F5"
    property color lightGrey: "#ccd0d4"
    property color lightBlue: "#ECEFFC"
    property color cyan: "#00FFFF"
    property color blue: "#4360DF"
    property color darkAccentBlue: "#2946C4"
    property color transparent: "#00000000"
    property color darkGrey: "#939BA1"
    property color lighterDarkGrey: "#b3bec6"
    property color lightBlueText: "#8f9fec"
    property color darkBlue: "#3c55c9"
    property color darkBlueBtn: "#5a70dd"
    property color red: "#FF2D55"
    property color lightRed: "#FFEAEE"
    property color green: "#4EBC60"
    property color turquoise: "#007b7d"
    property color tenPercentBlack: Qt.rgba(0, 0, 0, 0.1)
    property color tenPercentBlue: Qt.rgba(67, 96, 223, 0.1)

    property color background: white
    property color border: grey
    property color borderSecondary: tenPercentBlack
    property color borderTertiary: blue
    property color textColor: black
    property color textColorTertiary: blue
    property color currentUserTextColor: white
    property color secondaryBackground: lightBlue
    property color inputBackground: grey
    property color inputBorderFocus: blue
    property color inputColor: black
    property color modalBackground: white2
    property color backgroundHover: grey
    property color secondaryText: darkGrey
    property color secondaryHover: tenPercentBlack
    property color primary: blue
    property color danger: red
    property color success: green
    property color primaryMenuItemHover: blue
    property color primaryMenuItemTextHover: white
    property color backgroundTertiary: tenPercentBlue
    property color pillButtonTextColor: white
    property color chatReplyCurrentUser: darkGrey
    property color topBarChatInfoColor: grey
    property color codeBackground: "#2E386B"
    property color primarySelectionColor: "#b4c8ff"

    property color buttonForegroundColor: blue
    property color buttonBackgroundColor: secondaryBackground
    property color buttonSecondaryColor: darkGrey
    property color buttonDisabledForegroundColor: buttonSecondaryColor
    property color buttonDisabledBackgroundColor: grey
    property color buttonWarnBackgroundColor: "#FFEAEE"

    property color roundedButtonForegroundColor: buttonForegroundColor
    property color roundedButtonBackgroundColor: secondaryBackground
    property color roundedButtonSecondaryForegroundColor: white
    property color roundedButtonSecondaryBackgroundColor: buttonForegroundColor
    property color roundedButtonSecondaryHoveredBackgroundColor: darkAccentBlue
    property color roundedButtonDisabledForegroundColor: buttonDisabledForegroundColor
    property color roundedButtonDisabledBackgroundColor: buttonDisabledBackgroundColor
    property color roundedButtonSecondaryDisabledForegroundColor: white
    property color roundedButtonSecondaryDisabledBackgroundColor: buttonDisabledForegroundColor
}
