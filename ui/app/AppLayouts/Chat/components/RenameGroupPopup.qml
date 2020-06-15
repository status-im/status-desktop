import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "../../../../imports"
import "../../../../shared"
import "./"

Popup {
    id: popup
    modal: true

    Overlay.modal: Rectangle {
        color: "#60000000"
    }

    onOpened: {
        groupName.forceActiveFocus(Qt.MouseFocusReason)
        groupName.text = chatsModel.activeChannel.name
    }

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    parent: Overlay.overlay
    x: Math.round((parent.width - width) / 2)
    y: Math.round((parent.height - height) / 2)
    width: 480
    height: 159
    background: Rectangle {
        color: Theme.white
        radius: 8
    }
    padding: 0

    contentItem: Item {
        Text {
            id: groupTitleLabel
            text: qsTr("Group name")
            anchors.top: parent.top
            anchors.left: parent.left
            font.pixelSize: 13
            anchors.leftMargin: 16
            anchors.topMargin: Theme.padding
            anchors.bottomMargin: Theme.padding
        }

        Rectangle {
            id: groupNameBox
            height: 44
            color: Theme.grey
            anchors.top: groupTitleLabel.bottom
            radius: 8
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.leftMargin: Theme.padding
            anchors.rightMargin: Theme.padding
            anchors.topMargin: 7

            TextField {
                id: groupName
                placeholderText: qsTr("Group Name")
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 15
                background: Rectangle {
                    color: "#00000000"
                }
                width: groupNameBox.width - 32
                selectByMouse: true
            }
        }

        StyledButton {
            id: saveBtn
            anchors.top: groupNameBox.bottom
            anchors.topMargin: 22
            anchors.right: parent.right
            anchors.rightMargin: Theme.padding
            label: qsTr("Save")
            onClicked : {
                chatsModel.renameGroup(groupName.text)
                popup.close();
            }
        }
  }
}
