import QtQuick
import QtQuick.Layouts
import QtQml.Models

import StatusQ.Core
import StatusQ.Controls

CommonContactDialog {
    id: root

    title: qsTr("Mark as trusted")

    StatusBaseText {
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        text: qsTr("Mark users as trusted only if you're 100% sure who they are.")
    }

    rightButtons: ObjectModel {
        StatusFlatButton {
            text: qsTr("Cancel")
            onClicked: root.close()
        }
        StatusButton {
            text: qsTr("Mark as trusted")
            onClicked: root.accepted()
        }
    }
}
