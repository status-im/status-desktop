import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import utils 1.0

CommonContactDialog {
    id: root

    readonly property bool removeIDVerification: ctrlRemoveIDVerification.checked
    readonly property bool removeContact: ctrlRemoveContact.checked

    title: qsTr("Block user")

    StatusBaseText {
        objectName: "youWillNotSeeText"
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        lineHeight: 22
        lineHeightMode: Text.FixedHeight
        text: qsTr("You will not see %1’s messages but %1 can still see your messages in mutual group chats and communities. %1 will be unable to message you.").arg(mainDisplayName)
    }

    StatusWarningBox {
        objectName: "blockWarningBox"
        Layout.fillWidth: true
        Layout.topMargin: Theme.padding
        icon: "warning"
        iconColor: Theme.palette.dangerColor1
        bgColor: Theme.palette.dangerColor1
        borderColor: Theme.palette.dangerColor2
        textColor: Theme.palette.directColor1
        textSize: Theme.secondaryTextFontSize
        text: qsTr("Blocking a user purges the database of all messages that you’ve previously received from %1 in all contexts. This can take a moment.").arg(mainDisplayName)
    }

    StatusCheckBox {
        Layout.topMargin: Theme.halfPadding
        objectName: "removeContactCheckbox"
        id: ctrlRemoveContact
        visible: contactDetails.isContact
        checked: visible
        enabled: false
        text: qsTr("Remove contact")
    }

    StatusCheckBox {
        id: ctrlRemoveIDVerification
        visible: contactDetails.trustStatus === Constants.trustStatus.trusted
        checked: visible
        enabled: false
        text: qsTr("Remove trust mark")
    }

    rightButtons: ObjectModel {
        StatusFlatButton {
            objectName: "cancelButton"
            text: qsTr("Cancel")
            onClicked: root.close()
        }
        StatusButton {
            objectName: "blockButton"
            type: StatusBaseButton.Type.Danger
            text: qsTr("Block")
            onClicked: root.accepted()
        }
    }
}
