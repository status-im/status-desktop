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

    property var messagingStore
    property var advancedStore

    anchors.centerIn: parent
    height: 560
    padding: 8
    header.title: qsTr("Waku nodes")

    onClosed: {
        destroy()
    }

    onOpened: {
        addrInput.text = "";
    }

    StatusScrollView {
        id: scrollView
        anchors.fill: parent
        contentWidth: availableWidth

        Column {
            id: nodesColumn
            width: scrollView.availableWidth

            StatusInput {
                id: addrInput
                width: parent.width
                label: qsTr("Node multiaddress or DNS Discovery address")
                placeholderText: "/ipv4/0.0.0.0/tcp/123/..."
                validators: [
                StatusMinLengthValidator {
                    minLength: 1
                    errorMessage: qsTr("You need to enter a value")
                },
                StatusRegularExpressionValidator {
                    errorMessage: qsTr("Value should start with '/' or 'enr:'")
                    regularExpression: /(\/|enr:).+/
                }]
                validationMode: StatusInput.ValidationMode.Always
            }
        }
    }

    rightButtons: [
       StatusButton {
            text: qsTr("Save")
            enabled: addrInput.valid
            onClicked: {
                root.messagingStore.saveNewWakuNode(addrInput.text)
                popup.close()
            }
        }
    ]
}
