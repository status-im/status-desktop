import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Models 1.0
import Storybook 1.0
import utils 1.0

import shared.popups.send 1.0
import shared.stores 1.0
import shared.stores.send 1.0

import StatusQ.Core.Utils 0.1

SplitView {
    id: root

    orientation: Qt.Vertical

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Rectangle {
            anchors.fill: parent
            color: "lightgray"
        }

        Loader {
            id: loader

            active: false

            sourceComponent: SendModal {
                visible: true
                modal: false
                closePolicy: Popup.NoAutoClose
                onlyAssets: false

                store: TransactionStore {
                    readonly property QtObject selectedSenderAccount: QtObject {
                        readonly property var assets: WalletAssetsModel {}
                    }
                    readonly property QtObject collectiblesModel: WalletCollectiblesModel {}
                    readonly property QtObject nestedCollectiblesModel: WalletNestedCollectiblesModel {}

                    readonly property QtObject walletSectionSendInst: QtObject {}
                    readonly property QtObject mainModuleInst: QtObject {}

                    readonly property var savedAddressesModel: ListModel {
                        Component.onCompleted: {
                            for (let i = 0; i < 10; i++)
                                append({
                                    name: "some saved addr name " + i,
                                    ens: [],
                                    address: "0x2B748A02e06B159C7C3E98F5064577B96E55A7b4",
                                    chainShortNames: "eth:arb"
                                })
                        }
                    }

                    function splitAndFormatAddressPrefix(textAddrss, updateInStore) {
                        return textAddrss
                    }

                    function resolveENS() {
                        return ""
                    }

                    function getAsset(assetsList, symbol) {
                        const idx = ModelUtils.indexOf(assetsList, "symbol", symbol)
                        if (idx < 0) {
                            return {}
                        }
                        return ModelUtils.get(assetsList, idx)
                    }

                    function getCollectible(uid) {
                        const idx = ModelUtils.indexOf(collectiblesModel, "uid", uid)
                        if (idx < 0) {
                            return {}
                        }
                        return ModelUtils.get(collectiblesModel, idx)
                    }

                    function getSelectorCollectible(uid) {
                        const idx = ModelUtils.indexOf(nestedCollectiblesModel, "uid", uid)
                        if (idx < 0) {
                            return {}
                        }
                        return ModelUtils.get(nestedCollectiblesModel, idx)
                    }

                    function getHolding(holdingId, holdingType) {
                        if (holdingType === Constants.HoldingType.Asset) {
                            return getAsset(selectedSenderAccount.assets, holdingId)
                        } else if (holdingType === Constants.HoldingType.Collectible) {
                            return getCollectible(holdingId)
                        } else {
                            return {}
                        }
                    }

                    function getSelectorHolding(holdingId, holdingType) {
                        if (holdingType === Constants.HoldingType.Asset) {
                            return getAsset(selectedSenderAccount.assets, holdingId)
                        } else if (holdingType === Constants.HoldingType.Collectible) {
                            return getSelectorCollectible(holdingId)
                        } else {
                            return {}
                        }
                    }

                    function assetToSelectorAsset(asset) {
                        return asset
                    }

                    function collectibleToSelectorCollectible(collectible) {
                        return {
                            uid: collectible.uid,
                            chainId: collectible.chainId,
                            name: collectible.name,
                            iconUrl: collectible.imageUrl,
                            collectionUid: collectible.collectionUid,
                            collectionName: collectible.collectionName,
                            isCollection: false
                        }
                    }

                    function holdingToSelectorHolding(holding, holdingType) {
                        if (holdingType === Constants.HoldingType.Asset) {
                            return assetToSelectorAsset(holding)
                        } else if (holdingType === Constants.HoldingType.Collectible) {
                            return collectibleToSelectorCollectible(holding)
                        } else {
                            return {}
                        }
                    }

                    readonly property string currentCurrency: "USD"

                    readonly property QtObject currencyStore: QtObject {
                        readonly property string currentCurrency: "USD"

                        function formatCurrencyAmount() {
                            return "42"
                        }

                        function getFiatValue() {
                            return "42.42"
                        }
                    }

                    function getAllNetworksSupportedString() {
                        return "OPT"
                    }

                    function plainText(text) {
                        return text
                    }

                    function prepareTransactionsForAddress(address) {
                        console.log("prepareTransactionsForAddress:", address)
                    }

                    function getTransactions() {
                        return transactions
                    }

                    readonly property var transactions_: ListModel {
                        id: transactions

                        Component.onCompleted: {
                            for (let i = 0; i < 10; i++)
                                append({
                                    to: "to",
                                    loadingTransaction: false,
                                    value: {
                                               displayDecimals: true,
                                               stripTrailingZeroes: true,
                                               amount: 3.234
                                           },
                                    timestamp: new Date()
                                })
                        }
                    }

                    function findTokenSymbolByAddress() {
                        return "ETH"
                    }
                }
            }

            Component.onCompleted: {
                RootStore.currencyStore = {
                    currentCurrencySymbol: "USD"
                }

                RootStore.getNetworkIcon = () => "network/Network=Optimism"

                loader.active = true
            }
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 100

        SplitView.fillWidth: true
    }
}

// category: Popups
