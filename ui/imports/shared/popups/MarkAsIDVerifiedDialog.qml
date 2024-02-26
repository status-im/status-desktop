import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Controls 0.1

CommonContactDialog {
    id: root

    title: qsTr("Mark as ID verified")

    StatusBaseText {
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        text: qsTr("Mark users as ID verified only if you’re 100% sure who they are. Otherwise, it’s safer to send %1 an ID verification request.").arg(mainDisplayName)
    }

    rightButtons: ObjectModel {
        StatusFlatButton {
            text: qsTr("Cancel")
            onClicked: root.close()
        }
        StatusButton {
            text: qsTr("Mark as ID verified")
            onClicked: root.accepted()
        }
    }
}
