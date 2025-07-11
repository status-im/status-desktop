import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml.Models

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Popups.Dialog
import StatusQ.Controls

import utils

import shared.controls
import shared.popups

import AppLayouts.Wallet.services.dapps.types

import "PairWCModal"

StatusDialog {
    id: root

    objectName: "pairWCModal"

    width: 480
    implicitHeight: 633

    property bool isPairing: false

    function pairingValidated(validationState) {
        uriInput.errorState = validationState
        if (validationState === Pairing.errors.uriOk) {
            d.doPair()
        }
    }

    signal pair(string uri)
    signal pairUriChanged(string uri)
    signal pairInstructionsRequested()

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    title: qsTr("Connect a dApp via WalletConnect")

    padding: 20

    contentItem: ColumnLayout {
        StatusBaseText {
            text: "WalletConnect URI"
        }

        WCUriInput {
            id: uriInput

            pending: uriInput.errorState === Pairing.errors.notChecked
                  || uriInput.errorState === Pairing.errors.uriOk

            onTextChanged: {
                root.isPairing = false
                root.pairUriChanged(uriInput.text)
            }
        }

        // Spacer
        Item { Layout.fillHeight: true }

        StatusLinkText {
            text: qsTr("How to copy the dApp URI")

            Layout.alignment: Qt.AlignHCenter
            Layout.margins: 18

            normalColor: linkColor

            onClicked: {
                root.pairInstructionsRequested()
            }
        }
    }

    footer: StatusDialogFooter {
        id: footer
        rightButtons: ObjectModel {
            StatusButton {
                height: 44
                text: qsTr("Done")

                enabled: uriInput.valid
                      && !root.isPairing
                      && uriInput.text.length > 0
                      && uriInput.errorState === Pairing.errors.uriOk

                onClicked: {
                    d.doPair()
                }
            }
        }
    }

    QtObject {
        id: d

        function doPair() {
            root.isPairing = true
            root.pair(uriInput.text)
        }
    }
}
