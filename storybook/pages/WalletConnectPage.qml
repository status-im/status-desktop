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

Item {
    id: root

    // qml Splitter
    SplitView {
        anchors.fill: parent

        WalletConnect {
            id: walletConnect

            SplitView.preferredWidth: 400

            projectId: SystemUtils.getEnvVar("WALLET_CONNECT_PROJECT_ID")
            backgroundColor: Theme.palette.statusAppLayout.backgroundColor

            clip: true
        }

        ColumnLayout {
            id: optionsSpace

            RowLayout {
                id: optionsHeader

                Text { text: "projectId" }
                Text {
                    text: walletConnect.projectId.substring(0, 3) + "..." + walletConnect.projectId.substring(walletConnect.projectId.length - 3)
                    font.bold: true
                }
            }
            // spacer
            ColumnLayout {}
        }
    }
}

// category: Popups
