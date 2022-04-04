import QtQuick 2.3

import shared 1.0
import shared.panels 1.0
import utils 1.0

StyledText {
    id: retryLbl
    color: Style.current.red
    text: qsTr("Resend")
    font.pixelSize: Style.current.tertiaryTextFontSize
    visible: isCurrentUser && (timeout || isExpired)
    property bool isCurrentUser: false
    property bool isExpired: false
    property bool timeout: false
    signal clicked()
    MouseArea {
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        onClicked: {
            retryLbl.clicked();
        }
    }
}
