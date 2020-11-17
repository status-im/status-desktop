pragma Singleton

import QtQuick 2.13

QtObject {
    property QtObject fontMedium: FontLoader { id: _fontMedium; source: "../fonts/InterStatus/InterStatus-Medium.otf"; }
    property QtObject fontBold: FontLoader { id: _fontBold; source: "../fonts/InterStatus/InterStatus-Bold.otf"; }
    property QtObject fontLight: FontLoader { id: _fontLight; source: "../fonts/InterStatus/InterStatus-Light.otf"; }
    property QtObject fontRegular: FontLoader { id: _fontRegular; source: "../fonts/InterStatus/InterStatus-Regular.otf"; }
    

    readonly property color white: "#FFFFFF"
    readonly property color white2: "#FCFCFC"
    readonly property color black: "#000000"
    readonly property color grey: "#EEF2F5"
    readonly property color lightBlue: "#ECEFFC"
    readonly property color cyan: "#00FFFF"
    readonly property color blue: "#4360DF"
    readonly property color transparent: "#00000000"
    readonly property color darkGrey: "#939BA1"
    readonly property color darkerGrey: "#717171"
    readonly property color evenDarkerGrey: "#4C4C4C"
    readonly property color lightBlueText: "#8f9fec"
    readonly property color darkBlue: "#3c55c9"
    readonly property color darkBlueBtn: "#5a70dd"
    readonly property color red: "#FF2D55"
    readonly property color lightRed: "#FFEAEE"
    readonly property color green: "#4EBC60"
    readonly property color turquoise: "#007b7d"

    readonly property int xlPadding: 32
    readonly property int bigPadding: 24
    readonly property int padding: 16
    readonly property int smallPadding: 10
    readonly property int radius: 8

    readonly property int leftTabPrefferedSize: 340
    readonly property int leftTabMinimumWidth: 300
    readonly property int leftTabMaximumWidth: 500
}
