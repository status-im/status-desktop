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

import AppLayouts.Wallet.controls 1.0
import AppLayouts.Wallet.services.dapps 1.0

import SortFilterProxyModel 0.2

import shared.popups.walletconnect 1.0

import utils 1.0
import shared.stores 1.0

Item {
    id: root

    // qml Splitter
    SplitView {
        anchors.fill: parent

        ColumnLayout {
            SplitView.fillWidth: true

            Rectangle {
                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: dappsButton.implicitHeight + 20
                Layout.preferredHeight: dappsButton.implicitHeight + 20

                border.color: "blue"
                border.width: 1

                ConnectedDappsButton {
                    id: dappsButton

                    anchors.centerIn: parent

                    spacing: 8

                    onConnectDapp: {
                        console.warn("TODO: run ConnectDappModal...")
                    }
                }
            }
            ColumnLayout {}
        }

        ColumnLayout {
            id: optionsSpace

            RowLayout {
                Text { text: "projectId" }
                Text {
                    id: projectIdText
                    readonly property string projectId: SystemUtils.getEnvVar("WALLET_CONNECT_PROJECT_ID")
                    text: projectId.substring(0, 3) + "..." + projectId.substring(projectId.length - 3)
                    font.bold: true
                }
            }

            // spacer
            ColumnLayout {}
        }
    }

    DAppsStore {
        wCSDK: WalletConnectSDK {
            active: true

            projectId: projectIdText.projectId

            onSessionRequestEvent: (details) => {
                // TODO #14556
                console.debug(`@dd onSessionRequestEvent: ${JSON.stringify(details)}`)
            }
        }
    }
}

// category: Popups
