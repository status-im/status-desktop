import QtQuick
import QtQuick.Layouts
import QtQml.Models

import StatusQ
import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls

import utils

CommonContactDialog {
    id: root

    readonly property bool removeIDVerification: ctrlRemoveIDVerification.checked
    readonly property bool removeContact: ctrlRemoveContact.checked

    title: qsTr("Mark as untrusted")

    StatusBaseText {
        Layout.fillWidth: true
        Layout.bottomMargin: Theme.halfPadding
        text: qsTr("%1 will be marked as untrusted. This mark will only be visible to you.").arg(mainDisplayName)
        wrapMode: Text.WordWrap
    }

    StatusCheckBox {
        id: ctrlRemoveIDVerification
        visible: contactDetails.trustStatus === Constants.trustStatus.trusted
        checked: visible
        enabled: false
        text: qsTr("Remove trust mark")
    }

    StatusCheckBox {
        id: ctrlRemoveContact
        visible: contactDetails.isContact
        text: qsTr("Remove contact")
    }

    rightButtons: ObjectModel {
        StatusFlatButton {
            text: qsTr("Cancel")
            onClicked: root.close()
        }
        StatusButton {
            type: StatusBaseButton.Type.Danger
            text: qsTr("Mark as untrusted")
            onClicked: root.accepted()
        }
    }
}
