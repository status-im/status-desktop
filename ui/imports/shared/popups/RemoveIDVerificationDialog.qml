import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

CommonContactDialog {
    id: root

    readonly property bool markAsUntrusted: ctrlMarkAsUntrusted.checked
    readonly property bool removeContact: ctrlRemoveContact.checked

    title: qsTr("Remove trust mark")

    StatusBaseText {
        Layout.fillWidth: true
        Layout.bottomMargin: Theme.halfPadding
        wrapMode: Text.WordWrap
        text: qsTr("%1 will no longer be marked as trusted. This is only visible to you.").arg(mainDisplayName)
    }

    StatusCheckBox {
        id: ctrlMarkAsUntrusted
        text: qsTr("Mark %1 as untrusted").arg(mainDisplayName)
    }

    StatusCheckBox {
        id: ctrlRemoveContact
        text: qsTr("Remove contact")
    }

    rightButtons: ObjectModel {
        StatusFlatButton {
            text: qsTr("Cancel")
            onClicked: root.close()
        }
        StatusButton {
            type: StatusBaseButton.Type.Danger
            text: qsTr("Remove trust mark")
            onClicked: root.accepted()
        }
    }
}
