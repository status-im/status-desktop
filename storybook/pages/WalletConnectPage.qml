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
                proposeUserPair(sessionProposalJson, `{"eip155":{"methods":["eth_sendTransaction","personal_sign"],"chains":["eip155:5"],"events":["accountsChanged","chainChanged"],"accounts":["eip155:5:0x53780d79E83876dAA21beB8AFa87fd64CC29990b","eip155:5:0xBd54A96c0Ae19a220C8E1234f54c940DFAB34639","eip155:5:0x5D7905390b77A937Ae8c444aA8BF7Fa9a6A7DBA0"]}}`)
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

            // spacer
            ColumnLayout {}
        }
    }

    Settings {
        id: settings
        property bool hasActivePairings: hasActivePairingsCheckBox.checked
    }
}

// category: Popups
