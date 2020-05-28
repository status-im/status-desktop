import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Controls 2.12 as QQC2
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "../../../../shared"
import "../../../../imports"

Item {
    Layout.fillHeight: true
    Layout.fillWidth: true
    Item {
        id: walkieTalkieContainer
        anchors.left: parent.left
        anchors.leftMargin: 200
        anchors.right: parent.right
        anchors.rightMargin: 200
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 200
        anchors.top: parent.top
        anchors.topMargin: 100
        Image {
            source: "../../../../onboarding/img/chat@2x.jpg"
        }

        Text {
            text: "Select a chat to start messaging"
            anchors.horizontalCenter: parent.horizontalCenter
            font.weight: Font.DemiBold
            font.pixelSize: 15
            color: Theme.darkGrey
        }
    }
}