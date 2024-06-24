import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import utils 1.0

CommonContactDialog {
    id: root

    readonly property bool removeIDVerification: ctrlRemoveIDVerification.checked
    readonly property bool markAsUntrusted: ctrlMarkAsUntrusted.checked

    title: qsTr("Remove contact")

    readonly property var d: QtObject {
        id: d
        readonly property bool isTrusted: contactDetails.outgoingVerificationStatus === Constants.verificationStatus.trusted ||
                                          contactDetails.incomingVerificationStatus === Constants.verificationStatus.trusted
    }

    StatusBaseText {
        Layout.fillWidth: true
        Layout.bottomMargin: Style.current.halfPadding
        text: qsTr("You and %1 will no longer be contacts").arg(mainDisplayName)
        wrapMode: Text.WordWrap
    }

    StatusCheckBox {
        id: ctrlRemoveIDVerification
        visible: d.isTrusted || contactDetails.trustStatus === Constants.trustStatus.trusted
        checked: visible
        enabled: false
        text: qsTr("Remove ID verification")
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
