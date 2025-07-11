import QtQuick
import QtQuick.Layouts
import QtQml.Models

import utils

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls

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
