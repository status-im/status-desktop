import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15
import Qt.labs.settings 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups.Dialog 0.1

import Models 1.0
import Storybook 1.0

import AppLayouts.Wallet.views.walletconnect 1.0

import SortFilterProxyModel 0.2

import utils 1.0

import nim 1.0

Item {
    id: root

    WalletConnect {
        id: wc

        anchors.top: parent.bottom
        anchors.left: parent.left
        url: `${pagesFolder}/../stubs/AppLayouts/Wallet/views/walletconnect/src/index.html`

        controller: WalletConnectController {
            pairSessionProposal: function(sessionProposalJson) {
                proposeUserPair(sessionProposalJson, `{"eip155":{"methods":[
                    "personal_sign",
                    "eth_sendTransaction",
                    "eth_signTransaction",
                    "eth_sign",
                    "eth_signTypedData",
                    "eth_signTypedData_v4"
                ],
                 "chains":["eip155:5"],
                 "events":[
                    "chainChanged",
                    "accountsChanged"
                 ],
                 "accounts":["eip155:5:0xBd54A96c0Ae19a220C8E1234f54c940DFAB34639"]}}`)
            }

            recordSuccessfulPairing: function(sessionProposalJson) {
                const sessionProposal = JSON.parse(sessionProposalJson)

                pairingsModel.append({
                    topic: sessionProposal.params.pairingTopic,
                    expiry: sessionProposal.params.expiry,
                    active: true,
                })
                root.saveListModel(pairingsModel)
            }
            deletePairing: function(pairingTopic) {
                var found = false
                for (var i = 0; i < pairingsModel.count; i++) {
                    if (pairingsModel.get(i).topic === pairingTopic) {
                        pairingsModel.get.active = false
                        found = true
                        break;
                    }
                }
                if (!found) {
                    console.error("Mock Controller: pairing not found", pairingTopic)
                }
                root.saveListModel(pairingsModel)
            }
            sessionRequest: function(sessionRequestJson, password) {
                const signedJson = "0x1234567890"
                this.respondSessionRequest(sessionRequestJson, signedJson, respondError.checked)
            }

            hasActivePairings: settings.hasActivePairings
            projectId: "87815d72a81d739d2a7ce15c2cfdefb3"
        }

        clip: true
    }

    // qml Splitter
    SplitView {
        anchors.fill: parent

        ColumnLayout {
            SplitView.fillWidth: true

            StatusButton {
                id: openModalButton
                text: "OpenModal"
                onClicked: {
                    wc.modal.open()
                }
            }
            ColumnLayout {}
        }

        ColumnLayout {
            id: optionsSpace

            StatusRadioButton {
                text: "WebEngine running"
                checked: wc.sdk.webEngineLoader.active
                enabled: false
            }

            RowLayout {
                id: optionsHeader

                Text { text: "projectId" }
                Text {
                    readonly property string projectId: wc.controller.projectId
                    text: projectId.substring(0, 3) + "..." + projectId.substring(projectId.length - 3)
                    font.bold: true
                }
            }
            StatusCheckBox {
                id: hasActivePairingsCheckBox
                text: "Has active pairings"
                checked: settings.hasActivePairings
            }
            StatusCheckBox {
                id: respondError
                text: "Respond Error"
                checked: false
            }

            StatusBaseText { text: "Pairings History"; font.bold: true }
            StatusButton {
                text: "Clear"
                onClicked: { pairingsModel.clear(); root.saveListModel(pairingsModel); }
            }
            Pairings {
                id: pairingsView

                Layout.fillWidth: true
                Layout.minimumWidth: count > 0 ? 400 : 0
                Layout.preferredHeight: contentHeight
                Layout.maximumHeight: 300

                onDisconnect: function(pairingTopic) {
                    wc.sdk.disconnectPairing(pairingTopic)
                }

                model: ListModel {
                    id: pairingsModel
                }
                clip: true
            }

            // spacer
            ColumnLayout {}
        }
    }



    Settings {
        id: settings

        property bool hasActivePairings: hasActivePairingsCheckBox.checked
        property string pairingsHistory: ""
    }

    Component.onCompleted: {
        loadListModel(pairingsModel)
    }

    function saveListModel(model) {
        var listArray = [];
        for (var i = 0; i < model.count; i++) {
            listArray.push(model.get(i));
        }
        settings.pairingsHistory = JSON.stringify(listArray);
    }

    function loadListModel(model) {
        pairingsModel.clear();
        if (!settings.pairingsHistory) {
            return;
        }
        var listArray = JSON.parse(settings.pairingsHistory);
        listArray.forEach(function(entry) {
            pairingsModel.append(entry);
        });
    }
}

// category: Popups
