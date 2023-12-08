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
    headerSettings.title: qsTr("Waku nodes")

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
                label: qsTr("Storenode multiaddress")
                placeholderText: "/ip4/0.0.0.0/tcp/123/..."
                validators: [
                StatusMinLengthValidator {
                    minLength: 1
                    errorMessage: qsTr("You need to enter the storenode multiaddress")
                },
                StatusRegularExpressionValidator {
                    errorMessage: qsTr('Multiaddress must start with a "/"')
                    regularExpression: /\/.+/
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
