import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Controls 0.1

CommonContactDialog {
    id: root

    title: qsTr("Unblock user")

    StatusBaseText {
        objectName: "unblockingText"
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        text: qsTr("Unblocking %1 will allow new messages you receive from %1 to reach you.").arg(mainDisplayName)
    }

    rightButtons: ObjectModel {
        StatusFlatButton {
            objectName: "cancelButton"
            text: qsTr("Cancel")
            onClicked: root.close()
        }
        StatusButton {
            objectName: "unblockUserButton"
            type: StatusBaseButton.Type.Danger
            text: qsTr("Unblock")
            onClicked: root.accepted()
        }
    }
}
