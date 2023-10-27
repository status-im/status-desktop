import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15

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

    // qml Splitter
    SplitView {
        anchors.fill: parent

        WalletConnect {
            id: walletConnect

            SplitView.fillWidth: true

            backgroundColor: Theme.palette.statusAppLayout.backgroundColor

            controller: WalletConnectController {
                pairSessionProposal: function(sessionProposalJson) {
                    proposeUserPair(sessionProposalJson, `{"eip155":{"methods":["eth_sendTransaction","personal_sign"],"chains":["eip155:5"],"events":["accountsChanged","chainChanged"],"accounts":["eip155:5:0x53780d79E83876dAA21beB8AFa87fd64CC29990b","eip155:5:0xBd54A96c0Ae19a220C8E1234f54c940DFAB34639","eip155:5:0x5D7905390b77A937Ae8c444aA8BF7Fa9a6A7DBA0"]}}`)
                }
                projectId: SystemUtils.getEnvVar("STATUS_BUILD_WALLET_CONNECT_PROJECT_ID")
            }

            clip: true
        }

        ColumnLayout {
            id: optionsSpace

            RowLayout {
                id: optionsHeader

                Text { text: "projectId" }
                Text {
                    readonly property string projectId: walletConnect.controller.projectId
                    text: projectId.substring(0, 3) + "..." + projectId.substring(projectId.length - 3)
                    font.bold: true
                }
            }
            // spacer
            ColumnLayout {}
        }
    }
}

// category: Popups
