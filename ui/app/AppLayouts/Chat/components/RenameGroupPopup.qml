import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "./"

Popup {
    function doRename(){
        chatsModel.renameGroup(groupName.text)
        popup.close();
    }

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
        StyledText {
            id: groupTitleLabel
            text: qsTr("Group name")
            anchors.top: parent.top
            anchors.left: parent.left
            font.pixelSize: 13
            anchors.leftMargin: 16
            anchors.topMargin: Theme.padding
            anchors.bottomMargin: Theme.padding
        }

        Input {
            id: groupName
            anchors.top: groupTitleLabel.bottom
            anchors.topMargin: 7
            anchors.left: parent.left
            anchors.leftMargin: Theme.padding
            anchors.right: parent.right
            anchors.rightMargin: Theme.padding
            placeholderText: qsTr("Group Name")
            Keys.onEnterPressed: doRename()
            Keys.onReturnPressed: doRename()
        }

        StyledButton {
            id: saveBtn
            anchors.top: groupName.bottom
            anchors.topMargin: 22
            anchors.right: parent.right
            anchors.rightMargin: Theme.padding
            label: qsTr("Save")
            onClicked : doRename()
        }
  }
}
