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
    padding: 8
    header.title: qsTr("Waku nodes")

    property var messagingStore
    property var advancedStore

    onClosed: {
        destroy()
    }

    onOpened: {
        nameInput.text = "";
        enodeInput.text = "";
    }
    
    StatusScrollView {
        id: scrollView
        anchors.fill: parent
        contentWidth: availableWidth

        Column {
            id: nodesColumn
            width: scrollView.availableWidth
            StatusInput {
                id: nameInput
                width: parent.width
                label: qsTr("Name")
                placeholderText: qsTr("Specify a name")
                validators: [StatusMinLengthValidator {
                    minLength: 1
                    errorMessage: qsTr("You need to enter a name")
                }]
                validationMode: StatusInput.ValidationMode.Always
            }

            StatusInput {
                id: enodeInput
                width: parent.width
                label: popup.advancedStore.isWakuV2 ? qsTr("Storenode multiaddress") : qsTr("History node address")
                placeholderText: popup.advancedStore.isWakuV2 ? "/ip4/0.0.0.0/tcp/123/..." : "enode://{enode-id}:{password}@{ip-address}:{port-number}"
                validators: [
                StatusMinLengthValidator {
                    minLength: 1
                    errorMessage: popup.advancedStore.isWakuV2 ? qsTr("You need to enter the storenode multiaddress") : qsTr("You need to enter the enode address")
                },
                StatusRegularExpressionValidator {
                    errorMessage: popup.advancedStore.isWakuV2 ? qsTr('Multiaddress must start with a "/"') : qsTr("The format must be: enode://{enode-id}:{password}@{ip-address}:{port}")
                    regularExpression: popup.advancedStore.isWakuV2 ? /\/.+/ : /enode:\/\/[a-z0-9]+:[a-z0-9]+@(\b25[0-5]|\b2[0-4][0-9]|\b[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}:[0-9]+/
                }]
                validationMode: StatusInput.ValidationMode.Always
            }
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
