import QtQuick
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components
import StatusQ.Controls
import StatusQ.Controls.Validators
import StatusQ.Popups

import utils

import AppLayouts.Profile.stores

StatusModal {
    id: root

    property MessagingStore messagingStore
    property AdvancedStore advancedStore

    height: 560
    padding: 8
    headerSettings.title: qsTr("Waku nodes")

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
                root.close()
            }
        }
    ]
}
