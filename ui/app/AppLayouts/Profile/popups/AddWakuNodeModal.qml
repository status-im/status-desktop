import QtQuick 2.12
import QtQuick.Controls 2.3

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Popups 0.1


import utils 1.0

StatusModal {
    id: popup

    anchors.centerIn: parent
    height: 560
    header.title: qsTr("Waku nodes")

    property var messagingStore

    onClosed: {
        destroy()
    }

    onOpened: {
        nameInput.text = "";
        enodeInput.text = "";
    }
    
    contentItem: Item {
        width: parent.width
        height: parent.height

        StatusInput {
            id: nameInput
            label: qsTr("Name")
            input.placeholderText: qsTr("Specify a name")
            validators: [StatusMinLengthValidator {
                minLength: 1
                errorMessage: qsTr("You need to enter a name")
            }]
            validationMode: StatusInput.ValidationMode.OnlyWhenDirty
        }

        StatusInput {
            id: enodeInput
            label: qsTr("History node address")
            input.placeholderText:  "enode://{enode-id}:{password}@{ip-address}:{port-number}"
            validators: [StatusMinLengthValidator {
                minLength: 1
                errorMessage: qsTr("You need to enter the enode address")
            },
            StatusRegularExpressionValidator {
                errorMessage: qsTr("The format must be: enode://{enode-id}:{password}@{ip-address}:{port}")
                regularExpression: /enode:\/\/[a-z0-9]+:[a-z0-9]+@(\b25[0-5]|\b2[0-4][0-9]|\b[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}:[0-9]+/
            }]
            validationMode: StatusInput.ValidationMode.OnlyWhenDirty
            anchors.top: nameInput.bottom
            anchors.topMargin: Style.current.bigPadding
        }
    }

    rightButtons: [
       StatusButton {
            text: qsTr("Save")
            enabled: nameInput.valid && enodeInput.valid
            // enabled: nameInput.text !== "" && enodeInput.text !== ""
            onClicked: {
                root.messagingStore.saveNewMailserver(nameInput.text, enodeInput.text)
                popup.close()
            }
        }
    ]
}
