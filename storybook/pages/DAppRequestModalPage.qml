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
        modal.open()
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
                payloadData: d.currentPayload ? d.currentPayload.payloadData : null
                method: d.currentPayload ? d.currentPayload.method : ""
                maxFeesText: d.currentPayload ? d.currentPayload.maxFeesText : ""
                estimatedTimeText: d.currentPayload ? d.currentPayload.estimatedTimeText : ""

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
            StatusComboBox {
                id: methodsComboBox

                model: d.methodsModel
                control.textRole: "method"
                currentIndex: settings.payloadMethod
                onCurrentIndexChanged: {
                    d.currentPayload = null
                    settings.payloadMethod = currentIndex
                    d.currentPayload = d.payloadOptions[currentIndex]
                }
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
        property int payloadMethod: 0
    }

    QtObject {
        id: d

        Component.onCompleted: methodsModel.append(payloadOptions)

        readonly property var accountsModel: WalletAccountsModel{}
        readonly property var selectedAccount: accountsModel.data[0]

        readonly property var selectedNetwork: NetworksModel.flatNetworks.get(0)

        readonly property ListModel methodsModel: ListModel {}
        property var currentPayload: payloadOptions[settings.payloadMethod]
        property string maxFeesText: ""
        property string estimatedTimeText: ""

        readonly property var payloadOptions: [
            {
                payloadData: {"message":"This is a message to sign.\nSigning this will prove ownership of the account."},
                method: "personal_sign",
                maxFeesText: "",
                estimatedTimeText: ""
            },
            {
                payloadData: {"message": "{\"types\":{\"EIP712Domain\":[{\"name\":\"name\",\"type\":\"string\"},{\"name\":\"version\",\"type\":\"string\"},{\"name\":\"chainId\",\"type\":\"uint256\"},{\"name\":\"verifyingContract\",\"type\":\"address\"}],\"Person\":[{\"name\":\"name\",\"type\":\"string\"},{\"name\":\"wallet\",\"type\":\"address\"}],\"Mail\":[{\"name\":\"from\",\"type\":\"Person\"},{\"name\":\"to\",\"type\":\"Person\"},{\"name\":\"contents\",\"type\":\"string\"}]},\"primaryType\":\"Mail\",\"domain\":{\"name\":\"Ether Mail\",\"version\":\"1\",\"chainId\":1,\"verifyingContract\":\"0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC\"},\"message\":{\"from\":{\"name\":\"Cow\",\"wallet\":\"0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826\"},\"to\":{\"name\":\"Bob\",\"wallet\":\"0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB\"},\"contents\":\"Hello, Bob!\"}}"},
                method: "eth_signTypedData_v4",
                maxFeesText: "",
                estimatedTimeText: ""
            },
            {
                payloadData: {"tx":{"data":"0x","from":"0xE2d622C817878dA5143bBE06866ca8E35273Ba8a","gasLimit":"0x5208","gasPrice":"0x048ddbc5","nonce":"0x2a","to":"0xE2d622C817878dA5143bBE06866ca8E35273Ba8a","value":"0x00"}},
                method: "eth_signTransaction",
                maxFeesText: "1.82 EUR",
                estimatedTimeText: "3-5 mins"
            }
        ]
    }
}

// category: Wallet
