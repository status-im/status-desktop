import QtQuick 2.13

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
    property color lightBlueText
    property color darkBlue
    property color darkBlueBtn
    property color red
    property color purple: "#887AF9"
    property color orange: "#FE8F59"

    property color background
    property color border
    property color textColor
    property color currentUserTextColor
    property color secondaryBackground
    property color modalBackground

    property color buttonForegroundColor
    property color buttonBackgroundColor
    property color buttonDisabledForegroundColor
    property color buttonDisabledBackgroundColor
    property color roundedButtonForegroundColor
    property color roundedButtonBackgroundColor
    property color roundedButtonSecondaryBackgroundColor

    property int xlPadding: 32
    property int bigPadding: 24
    property int padding: 16
    property int halfPadding: 8
    property int smallPadding: 10
    property int radius: 8

    property int leftTabPrefferedSize: 340
    property int leftTabMinimumWidth: 300
    property int leftTabMaximumWidth: 500
}
