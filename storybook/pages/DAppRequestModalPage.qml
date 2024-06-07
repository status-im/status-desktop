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
        modal.openWith()
    }

    // qml Splitter
    SplitView {
        anchors.fill: parent

        ColumnLayout {
            SplitView.fillWidth: true

            Component.onCompleted: root.openModal()

            DAppRequestModal {
                id: modal

                anchors.centerIn: parent

                spacing: 8

                dappName: settings.dappName
                dappUrl: settings.dappUrl
                dappIcon: settings.dappIcon
                signContent: JSON.stringify(d.signTestContent, null, 2)
                maxFeesText: "1.82 EUR"
                estimatedTimeText: "3-5 mins"

                account: d.selectedAccount
                network: d.selectedNetwork

                onSign: {
                    console.log("Sign button clicked")
                }
                onReject: {
                    console.log("Reject button clicked")
                }
            }

            StatusButton {
                id: openButton

                Layout.alignment: Qt.AlignHCenter
                Layout.margins: 20

                text: "Open DAppRequestModal"

                onClicked: root.openModal()
            }

            ColumnLayout {}
        }

        ColumnLayout {
            id: optionsSpace

            TextField {
                id: dappNameTextField

                text: settings.dappName
                onTextChanged: settings.dappName = text
            }
            TextField {
                id: dappUrlTextField

                text: settings.dappUrl
                onTextChanged: settings.dappUrl = text
            }
            TextField {
                id: dappIconTextField

                text: settings.dappIcon
                onTextChanged: settings.dappIcon = text
            }
            TextField {
                id: accountDisplayTextField

                text: settings.accountDisplay
                onTextChanged: settings.accountDisplay = text
            }

            Item { Layout.fillHeight: true }
        }
    }

    Settings {
        id: settings

        property string dappName: "OpenSea"
        property string dappUrl: "opensea.io"
        property string dappIcon: "https://opensea.io/static/images/logos/opensea-logo.svg"
        property string accountDisplay: "helloworld"
    }

    QtObject {
        id: d

        readonly property var accountsModel: WalletAccountsModel{}
        readonly property var selectedAccount: accountsModel.data[0]

        readonly property var selectedNetwork: NetworksModel.flatNetworks.get(0)

        readonly property var signTestContent: {
            "id": 1714038548266495,
            "params": {
                "chainld": "eip155:11155111",
                "request": {
                    "expiryTimestamp": 1714038848,
                    "method": "eth_signTransaction",
                    "params": [
                        {
                        "data": "0x",
                        "from": "0xE2d622C817878dA5143bBE06866ca8E35273Ba8",
                        "gasLimit": "0x5208",
                        "gasPrice": "0xa677ef31",
                        "nonce": "0x27",
                        "to": "0xE2d622C817878dA5143bBE06866ca8E35273Ba8a",
                        "value": "0x00"
                        }
                    ]
                }
            },
            "topic": "a0f85b23a1f3a540d85760a523963165fb92169d57320c",
            "verifyContext": {
                "verified": {
                    "isScam": false,
                    "origin": "https://react-app.walletconnect.com/",
                    "validation": "VALID",
                    "verifyUrl": "https://verify.walletconnect.com/"
                }
            }
        }
    }
}

// category: Wallet
