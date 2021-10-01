import QtQuick 2.3

import "../../../../shared"
import "../../../../shared/panels"

import utils 1.0

StyledText {
    id: retryLbl
    color: Style.current.red
    //% "Resend"
    text: qsTrId("resend-message")
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
