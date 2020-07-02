import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
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

        StyledText {
            text: "Select a chat to start messaging"
            anchors.horizontalCenter: parent.horizontalCenter
            font.weight: Font.DemiBold
            font.pixelSize: 15
            color: Style.current.darkGrey
        }
    }
}
/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
