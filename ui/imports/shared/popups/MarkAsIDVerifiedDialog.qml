import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1

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
