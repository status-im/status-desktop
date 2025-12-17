import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ
import StatusQ.Core
import StatusQ.Core.Utils
import StatusQ.Controls

import utils

import shared.popups.send
import shared.stores
import shared.stores.send

import SortFilterProxyModel
import AppLayouts.Wallet.stores

import Storybook
import Models
import Mocks

SplitView {
    id: root

    orientation: Qt.Horizontal

    property WalletAssetsStoreMock walletAssetStore: WalletAssetsStoreMock {


        property var groupedAccountAssetsModel: ListModel {
            Component.onCompleted: {
                const data = [
                    {
                        tokensKey: "key_eth",
                        name: "Ethereum",
                        symbol: "ETH",
                        decimals: 18,
                        communityId: "",
                        balances: [
                            {
                                chainId: "1",
                                balance: "122082928968121891",
                                account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240",
                            },
                            {
                              chainId: "11155420",
                              balance: "559133758939097000",
                              account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240"
                            }
                        ],
                        currentCurrencyBalance: 234.234,
                        marketDetails: {
                            currencyPrice: {
                                amount: 12234.23,
                                displayDecimals: true
                            }
                        }
                    },
                    {
                        tokensKey: "key_dai",
                        name: "DAI",
                        symbol: "DAI",
                        decimals: 18,
                        communityId: "",
                        balances: [
                            {
                                chainId: "11155420",
                                balance: "1142155111",
                                account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240"
                            },
                            {
                                chainId: "1",
                                balance: "4411211243121551121",
                                account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240"
                            }
                        ],
                        currentCurrencyBalance: 234.234,
                        marketDetails: {
                            currencyPrice: {
                                amount: 234.23,
                                displayDecimals: true
                            }
                        }
                    }
                ]

                append(data)
            }
        }
    }

    TransactionStore {
        id: txStore

        property bool areTestNetworksEnabled: true

        function resetData() {}

        walletAssetStore: root.walletAssetStore
        Component.onCompleted: {
            if (tokensStore) {
                tokensStore.showCommunityAssetsInSend = showCommunityAssetsCheckBox.checked
                tokensStore.displayAssetsBelowBalance = balanceThresholdCheckbox.checked
                tokensStore._displayAssetsBelowBalanceThresholdDisplayAmountFunc = () => Number(balanceThresholdValue.text)
            }
        }
    }

    Connections {
        target: showCommunityAssetsCheckBox
        function onCheckedChanged() {
            if (txStore.tokensStore) {
                txStore.tokensStore.showCommunityAssetsInSend = showCommunityAssetsCheckBox.checked
            }
        }
    }

    Connections {
        target: balanceThresholdCheckbox
        function onCheckedChanged() {
            if (txStore.tokensStore) {
                txStore.tokensStore.displayAssetsBelowBalance = balanceThresholdCheckbox.checked
            }
        }
    }

    NetworksStore {
        id: networkStore
    }

    QtObject {
        id: dummyEventData

        property ListModel toModel: ListModel {
            ListElement {
                chainId: 11155420
                amountOut: "3003845308235848343"
            }
            ListElement {
                chainId: 1
                amountOut: "30038453082358483445"
            }
        }
        property var suggestesRoutes: [{
                bridgeName:"Hop",
                fromNetwork: 1,
                toNetwork: 10,
                maxAmountIn:"2649485258572837546",
                amountIn:"200000000000000000",
                amountOut:"200000000000000000",
                gasAmount:501000,
                gasFees: {
                    gasPrice:1.7e-08,
                    baseFee:1.0,
                    maxPriorityFeePerGas:2e-09,
                    maxFeePerGasL:1.1e-08,
                    maxFeePerGasM:1.0,
                    maxFeePerGasH:2.0,
                    eip1559Enabled:true
                },
                tokenFees:-0.004508663259772343,
                cost:-6.39534887667951,
                estimatedTime:1,
                isFirstSimpleTx:true,
                isFirstBridgeTx:true,
                approvalRequired:false,
                approvalGasFees:0.0,
                approvalAmountRequired:"0",
                approvalContractAddress:""
            },
            {
                bridgeName:"Transfer",
                fromNetwork: 10,
                toNetwork:10,
                maxAmountIn:"443890157817650036",
                amountIn:"200000000000000000",
                amountOut:"200000000000000000",
                gasAmount:22000,
                gasFees:{
                    gasPrice:0.10000005,
                    baseFee:4.4e-08,
                    maxPriorityFeePerGas:0.1,
                    maxFeePerGasL:5e-08,
                    maxFeePerGasM:0.1,
                    maxFeePerGasH:0.2,
                    eip1559Enabled:true
                },
                tokenFees:0.0,
                bonderFees:"0x0",
                cost:0.003510716,
                estimatedTime:1,
                isFirstSimpleTx:false,
                isFirstBridgeTx:false,
                approvalRequired:false,
                approvalGasFees:0.0,
                approvalAmountRequired:"0",
                approvalContractAddress:""
            }]
    }

    Item {
        anchors.left: parent.left
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Rectangle {
            anchors.fill: parent
            color: "lightgray"
        }

        Loader {
            id: loader

            property var preSelectedAccount: txStore.accounts.get(0)
            property string preSelectedHoldingID
            property int preSelectedHoldingType: Constants.TokenType.Unknown
            property int preSelectedSendType: Constants.SendType.Unknown
            property bool onlyAssets: false
            property string preDefinedAmountToSend
            property string preSelectedRecipient

            active: false

            sourceComponent: SendModal {
                visible: true
                modal: false
                closePolicy: Popup.NoAutoClose
                onlyAssets: loader.onlyAssets
                store: txStore
                networksStore: networkStore
                preSelectedAccountAddress: loader.preSelectedAccount.address
                preDefinedAmountToSend: loader.preDefinedAmountToSend
                preSelectedRecipient: loader.preSelectedRecipient
                preSelectedSendType: loader.preSelectedSendType
                preSelectedHoldingID: loader.preSelectedHoldingID
                preSelectedHoldingType: loader.preSelectedHoldingType
                sendTransaction: () => {
                                    if (!showSendErrorCheckBox.checked)
                                         return

                                    txStore.walletSectionSendInst.transactionSent(1, "0x123", uuid, "Send error, please ignore")
                                 }
            }
            Component.onCompleted: loader.active = true
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 100


        ColumnLayout {
            width: parent.width
            spacing: 10

            ColumnLayout {
                spacing: 0
                Layout.topMargin: 20
                width: parent.width
                StatusBaseText {
                    Layout.maximumWidth: parent.width
                    text: "This button can be used as response to the suggestedRoutes API called once a token and its amount is selected along with a valid recipient."
                    color: "orange"
                    wrapMode: Text.WrapAnywhere
                }
                StatusButton {
                    enabled: txStore.suggestedRoutesCalled
                    text: "emit suggestedRoutesReady"
                    onClicked: {
                        let txRoutes = {
                            suggestedRoutes: dummyEventData.suggestesRoutes,
                            gasTimeEstimate:{
                                totalFeesInNativeCrypto:0.0005032000000000001,
                                totalTokenFees:-0.004508663259772343,
                                totalTime:2
                            },
                            amountToReceive: txStore.amountToSend - (txStore.amountToSend*5/100),
                            toNetworksRouteModel: dummyEventData.toModel
                        }
                        let errCode = ""
                        let errDescription = ""
                        txStore.fromNetworksRouteModel.updateFromNetworks(dummyEventData.suggestesRoutes)
                        txStore.toNetworksRouteModel.updateToNetworks(dummyEventData.suggestesRoutes)
                        txStore.walletSectionSendInst.suggestedRoutesReady(txRoutes, errCode, errDescription)
                        txStore.suggestedRoutesCalled = false
                    }
                }
            }

            Rectangle {
                Layout.fillWidth:  true
                Layout.preferredHeight: 1
                color: "grey"
            }

            StatusBaseText {
                Layout.maximumWidth: parent.width
                text: "Note: After filling in the preSelected inputs you need to reload the SendModal as per current implementation"
                color: "orange"
                wrapMode: Text.WrapAnywhere
            }

            ColumnLayout {
                spacing: 0
                StatusBaseText {
                    text:"preSelectedAccount"
                }
                ComboBox {
                    textRole: "name"
                    model: SortFilterProxyModel {
                        sourceModel: txStore.accounts
                        filters: ValueFilter {
                            roleName: "canSend"
                            value: true
                        }
                    }
                    onCurrentIndexChanged: loader.preSelectedAccount = txStore.accounts.get(currentIndex)
                }
            }

            ColumnLayout {
                spacing: 0
                StatusBaseText {
                    text:"preSelectedHoldingType"
                }
                ComboBox {
                    id: tokenType
                    model: ["Native", "Asset", "Collectible", "Fungible Token", "Unknown", "ENS"]
                    currentIndex: 4
                    onCurrentIndexChanged: {
                        loader.preSelectedHoldingType = currentIndex
                    }
                }
            }

            StatusInput {
                enabled: tokenType.currentIndex > 0 && tokenType.currentIndex < 3
                label: "preSelectedHoldingID (case sensitive)"
                onTextChanged: loader.preSelectedHoldingID = text
            }

            StatusInput {
                label: "preDefinedAmountToSend"
                onTextChanged: loader.preDefinedAmountToSend = text
            }

            ColumnLayout {
                spacing: 0
                StatusBaseText {
                    text:"preSelectedSendType"
                }
                ComboBox {
                    model: ["Transfer",
                        "ENSRegister",
                        "ENSRelease",
                        "ENSSetPubKey",
                        "StickersBuy",
                        "Bridge",
                        "ERC721Transfer",
                        "Unknown"]
                    onCurrentIndexChanged: loader.preSelectedSendType = currentIndex
                }
            }

            StatusInput {
                label: "preSelectedRecipient"
                onTextChanged: loader.preSelectedRecipient = text
            }

            StatusButton {
                text: "Reload popup"
                onClicked: {
                    loader.item.close()
                    loader.item.open()
                }
            }

            CheckBox {
                id: ctrlShowCustomMode
                text: "Show custom network routing panel"
                checked: true
            }

            CheckBox {
                id: showSendErrorCheckBox
                text: "Show send error"
                checked: false
            }

            CheckBox {
                id: showCommunityAssetsCheckBox
                text: "Show community assets when sending tokens"
                checked: true
            }

            CheckBox {
                id: balanceThresholdCheckbox
                text: "Turn on balance threshold"
                checked: false
            }

            Rectangle {
                border.width: 1
                Layout.preferredWidth: 100
                Layout.preferredHeight: 50
                color: "lightgrey"
                TextInput {
                    id: balanceThresholdValue
                    anchors.fill: parent
                    enabled: balanceThresholdCheckbox.checked
                    text: "0.10"
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                }
            }
        }
    }
}

// category: Popups
