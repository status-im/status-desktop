import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQml.Models 2.3

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.controls 1.0
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Controls.Validators 0.1

StatusModal {
    id: root
    property var profileStore

    width: 420
    height: 250
    closePolicy: Popup.NoAutoClose
    headerSettings.title: qsTr("Edit")
    contentItem: Item {
        StatusInput {
            id: displayNameInput
            input.edit.objectName: "DisplayNamePopup_displayNameInput"
            width: parent.width - Style.current.padding
            anchors.top: parent.top
            anchors.topMargin: Style.current.padding
            anchors.horizontalCenter: parent.horizontalCenter
            placeholderText: qsTr("Display Name")
            input.text: root.profileStore.displayName
            validators: Constants.validators.displayName
        }
    }

    rightButtons: [
        StatusButton {
            id: okBtn
            objectName: "DisplayNamePopup_okButton"
            text: qsTr("OK")
            enabled: !!displayNameInput.text && displayNameInput.valid
            onClicked: {
                root.profileStore.setDisplayName(displayNameInput.text)
                root.close()
            }
        }
    ]

    onOpened: { displayNameInput.input.edit.forceActiveFocus() }
}

