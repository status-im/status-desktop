import QtQuick 2.12
import QtQuick.Dialogs 1.3
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"
import "../ContactsColumn"

Item {
        id: blockedContactsButton
        anchors.top: addNewContact.bottom
        anchors.topMargin: Style.current.bigPadding
        width: blockButton.width + blockButtonLabel.width + Style.current.padding
        height: addButton.height

        StatusRoundButton {
            id: blockButton
            anchors.verticalCenter: parent.verticalCenter
            icon.name: "block-icon"
            icon.color: Style.current.lightBlue
            width: 40
            height: 40
        }

        StyledText {
            id: blockButtonLabel
            //% "Blocked contacts"
            text: qsTrId("blocked-contacts")
            color: Style.current.blue
            anchors.left: blockButton.right
            anchors.leftMargin: Style.current.padding
            anchors.verticalCenter: blockButton.verticalCenter
            font.pixelSize: 15
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                blockedContactsModal.open()
            }
        }
    }