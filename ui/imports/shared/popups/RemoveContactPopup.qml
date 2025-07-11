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
    readonly property bool markAsUntrusted: ctrlMarkAsUntrusted.checked

    title: qsTr("Remove contact")

    StatusBaseText {
        Layout.fillWidth: true
        Layout.bottomMargin: Theme.halfPadding
        text: qsTr("You and %1 will no longer be contacts").arg(mainDisplayName)
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
        id: ctrlMarkAsUntrusted
        visible: contactDetails.trustStatus !== Constants.trustStatus.untrustworthy
        text: qsTr("Mark %1 as untrusted").arg(mainDisplayName)
    }

    rightButtons: ObjectModel {
        StatusFlatButton {
            text: qsTr("Cancel")
            onClicked: root.close()
        }
        StatusButton {
            type: StatusBaseButton.Type.Danger
            text: qsTr("Remove contact")
            objectName: "removeContactButton"
            onClicked: root.accepted()
        }
    }
}
