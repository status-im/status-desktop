import QtQuick 2.13
import "."

Theme {
    property color white: "#FFFFFF"
    property color white2: "#FCFCFC"
    property color black: "#000000"
    property color almostBlack: "#141414"
    property color grey: "#EEF2F5"
    property color lightBlue: "#ECEFFC"
    property color cyan: "#00FFFF"
    property color blue: "#758EF0"
    property color transparent: "#00000000"
    property color darkGrey: "#838C91"
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
    property color border: "#252528"
    property color borderSecondary: tenPercentWhite
    property color borderTertiary: blue
    property color textColor: white
    property color textColorTertiary: blue
    property color currentUserTextColor: white
    property color secondaryBackground: "#23252F"
    property color inputBackground: secondaryBackground
    property color inputColor: darkGrey
    property color modalBackground: background
    property color backgroundHover: "#252528"
    property color secondaryText: darkGrey
    property color secondaryHover: tenPercentWhite
    property color danger: red
    property color primaryMenuItemHover: blue
    property color primaryMenuItemTextHover: almostBlack
    property color backgroundTertiary: tenPercentBlue
}
