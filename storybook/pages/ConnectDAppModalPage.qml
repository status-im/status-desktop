import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15
import Qt.labs.settings 1.0
import QtTest 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups.Dialog 0.1

import Models 1.0
import Storybook 1.0

import shared.popups.walletconnect 1.0

import SortFilterProxyModel 0.2

import AppLayouts.Wallet.panels 1.0

import utils 1.0
import shared.stores 1.0

Item {
    id: root

    function openModal() {
        modal.openWithFilter([1, 42161], JSON.parse(`{
            "metadata": {
                "description": "React App for WalletConnect",
                "icons": [
                    "https://avatars.githubusercontent.com/u/37784886"
                ],
                "name": "React App",
                "url": "https://react-app.walletconnect.com",
                "verifyUrl": "https://verify.walletconnect.com"
            },
            "publicKey": "300a6a1df4cb0cd73eb652f11845f35a318541eb18ab369860be85c0c2ada54a"
        }`))
        if (pairedCheckbox.checked) {
            pairedResultTimer.restart()
        }
    }

    // qml Splitter
    SplitView {
        anchors.fill: parent

        ColumnLayout {
            SplitView.fillWidth: true

            Component.onCompleted: root.openModal()

            StatusButton {
                id: openButton

                Layout.alignment: Qt.AlignHCenter
                Layout.margins: 20

                text: "Open ConnectDAppModal"

                onClicked: root.openModal()
            }

            ConnectDAppModal {
                id: modal

                anchors.centerIn: parent

                spacing: 8

                accounts: d.selectedAccount

                flatNetworks: SortFilterProxyModel {
                    sourceModel: NetworksModel.flatNetworks
                    filters: ValueFilter { roleName: "isTest"; value: false; }
                }
            }

            ColumnLayout {}
        }

        ColumnLayout {
            id: optionsSpace

            CheckBox {
                id: pairedCheckbox

                text: "Report Paired"

                checked: true
            }
            CheckBox {
                id: pairedStatusCheckbox

                text: "Paired Successful"

                checked: true
            }
            Item { Layout.fillHeight: true }
        }
    }

    Timer {
        id: pairedResultTimer

        interval: 1000
        running: false
        repeat: false
        onTriggered: {
            if (pairedCheckbox.checked) {
                if (pairedStatusCheckbox.checked) {
                    modal.pairSuccessful(null)
                } else {
                    modal.pairFailed(null, "Pairing failed")
                }
            }
        }
    }
}

// category: Wallet
