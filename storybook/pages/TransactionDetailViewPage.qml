import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Storybook 1.0

import AppLayouts.Wallet 1.0
import AppLayouts.Wallet.stores 1.0 as WalletStores

import "../../ui/app/AppLayouts/Wallet/views" // NOTE - there is no AppLayout.Wallet.views
import shared.controls 1.0
import shared.stores 1.0

import utils 1.0

SplitView {
    id: root

    property bool globalUtilsReady: false
    property bool mainModuleReady: false
    property bool rootStoreReady: false

    property bool isIncoming: false

    Component.onCompleted: {
        RootStore.getFiatValue = (cryptoValue, symbol, currentCurrency) => { return (cryptoValue * 1800).toPrecision(2) }
        RootStore.getNetworkIcon = (chainId) => { return "tiny/network/Network=Ethereum" }
        RootStore.getLatestBlockNumber = () => { return 4 }
        RootStore.hex2Dec = (number) => { return 10 }
        RootStore.getNetworkColor = (number) => { return "blue" }
        RootStore.getNetworkFullName = (chainId) => { return "Ethereum Mainnet" }
        RootStore.getNetworkShortName = (chainId) => { return "eth" }
        RootStore.formatCurrencyAmount = (value, symbol) => { return value + " " + symbol }
        RootStore.getNameForSavedWalletAddress = (address) => { return "Saved Wallet Name" }
        RootStore.getNameForAddress = (address) => { return "Address Name" }
        RootStore.getEnsForSavedWalletAddress = (address) => { return "123" }
        RootStore.getChainShortNamesForSavedWalletAddress = (address) => { return "" }
        RootStore.getGasEthValue = (gasAmount, gasPrice) => { return (gasAmount * Math.pow(10, -9)).toPrecision(5) }
        RootStore.getNetworkLayer = (chainId) => { return 1 }
        RootStore.currentCurrency = "USD"

        root.rootStoreReady = true
    }

    // globalUtilsInst mock
    QtObject {
        function getCompressedPk(publicKey) { return "zx3sh" + publicKey }
        function getColorHashAsJson(publicKey) {
            return JSON.stringify([{"segmentLength":1,"colorId":12},{"segmentLength":5,"colorId":18},
                                   {"segmentLength":3,"colorId":25},{"segmentLength":3,"colorId":23},
                                   {"segmentLength":1,"colorId":10},{"segmentLength":3,"colorId":26},
                                   {"segmentLength":2,"colorId":30},{"segmentLength":1,"colorId":18},
                                   {"segmentLength":4,"colorId":28},{"segmentLength":1,"colorId":17},
                                   {"segmentLength":2,"colorId":2}])
        }
        function isCompressedPubKey(publicKey) { return true }
        function getColorId(publicKey) { return Math.floor(Math.random() * 10) }

        Component.onCompleted: {
            Utils.globalUtilsInst = this
            root.globalUtilsReady = true
        }
        Component.onDestruction: {
            root.globalUtilsReady = false
            Utils.globalUtilsInst = {}
        }
    }

    // mainModuleInst mock
    QtObject {
        function getContactDetailsAsJson(publicKey, getVerification) {
            return JSON.stringify({
                displayName: "ArianaP",
                displayIcon: "",
                publicKey: publicKey,
                name: "",
                alias: "",
                localNickname: "",
                isContact: true
            })
        }
        function isEnsVerified(publicKey) { return false }

        Component.onCompleted: {
            Utils.mainModuleInst = this
            root.mainModuleReady = true
        }
        Component.onDestruction: {
            root.mainModuleReady = false
            Utils.mainModuleInst = {}
        }
    }

    QtObject {
        id: contactsStoreMockup
        readonly property var myContactsModel: QtObject {
            signal itemChanged(address: string)
        }

        function getContactPublicKeyByAddress(address) {
            return ""
        }
    }

    QtObject {
        id: transactionData

        property int chainId: 1
        property string blockNumber: "0x124"
        property int timestamp: Date.now() / 1000
        property int txStatus: 0
        property string type: "eth"
        property string nonce: "0x123"
        property string from: "0x29D7d1dd5B6f9C864d9db560D72a247c178aE86B"
        property string to: "0x4de3f6278C0DdFd3F29df9DcD979038F5c7bbc35"
        property string contract: "0x4de3f6278C0DdFd3F29df9DcD979038F5c7bbc35"
        property bool isNFT: false
        property string input: "0xdasdja214i12r0uf0jh013rfj01rfj12-09fuj12f012fuj0-129fuj012ujf1209u120912er902iue30912e"
        property string tokenID: "4981676894159712808201908443964193325271219637660871887967796332739046670337"
        property string nftName: "Happy Meow"
        property string nftImageUrl: Style.png("collectibles/HappyMeow")
        property string symbol: "ETH"
        property string txHash: "0x4de3f6278C0DdFd3F29df9DcD979038F5c7bbc35"

        readonly property var value: QtObject {
            property real amount: amountSpinbox.realValue
            property string symbol: "ETH"
            property int displayDecimals: 5
            property bool stripTrailingZeroes: true
        }

        readonly property var totalFees: QtObject {
            property real amount: (transactionData.value.amount / 15) * Math.pow(10, 9)
            property string symbol: "Gwei"
            property int displayDecimals: 8
            property bool stripTrailingZeroes: true
        }

        readonly property var gasPrice: QtObject {
            property real amount: 0.0000005
            property string symbol: "ETH"
        }
    }

    QtObject {
        id: overviewMockup

        property var mixedcaseAddress: root.isIncoming ? transactionData.to : transactionData.from
    }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true
        Item {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            Rectangle {
                anchors.fill: viewLoader
                anchors.margins: -1
                color: "transparent"
                border.width: 1
                border.color: "#808080"
            }

            Loader {
                id: viewLoader
                anchors.centerIn: parent
                width: 800
                height: 500

                active: root.globalUtilsReady && root.mainModuleReady && root.rootStoreReady
                sourceComponent: TransactionDetailView {
                    contactsStore: contactsStoreMockup
                    transaction: transactionData
                    overview: overviewMockup
                }
            }
        }

        LogsAndControlsPanel {
            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 150

            SplitView.fillWidth: true
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        ColumnLayout {
            Label {
                text: "Amount:"
            }
            SpinBox {
                id: amountSpinbox
                from: 0
                to: 999999999
                value: 12345
                stepSize: 1
                editable: true

                readonly property int multiplier: Math.pow(10, decimals)
                property int decimals: 5
                property real realValue: value / multiplier
                validator: DoubleValidator { bottom: 0.0 }
                textFromValue: function(value, locale) { return Number(value / amountSpinbox.multiplier).toLocaleString(locale, 'f', amountSpinbox.decimals) }
                valueFromText: function(text, locale) { return Number.fromLocaleString(locale, text) * amountSpinbox.multiplier }
            }
            CheckBox {
                text: "is NFT"
                checked:  transactionData.isNFT
                onCheckedChanged: transactionData.isNFT = checked
            }
            CheckBox {
                text: "is incoming"
                checked:  root.isIncoming
                onCheckedChanged: root.isIncoming = checked
            }
        }
    }
}
