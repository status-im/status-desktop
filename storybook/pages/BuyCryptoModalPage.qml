import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Storybook 1.0
import Models 1.0

import StatusQ.Core.Backpressure 0.1

import AppLayouts.Wallet.popups.buy 1.0
import AppLayouts.Wallet.stores 1.0

import shared.stores 1.0

SplitView {
    id: root

    orientation: Qt.Horizontal

    QtObject {
        id: d
        property string uuid
        property var debounceFetchProviderUrl: Backpressure.debounce(root, 500, function() {
            d.buyCryptoStore.providerUrlReady(d.uuid, "xxxx")
        })
        property var debounceFetchProvidersList: Backpressure.debounce(root, 500, function() {
            d.buyCryptoStore.areProvidersLoading = false
        })
        readonly property var buyCryptoStore: BuyCryptoStore {
            readonly property var providersModel: OnRampProvidersModel{}
            property bool areProvidersLoading
            signal providerUrlReady(string uuid , string url)

            function fetchProviders() {
                console.warn("fetchProviders called >>")
                areProvidersLoading = true
                d.debounceFetchProvidersList()
            }

            function fetchProviderUrl(uuid, providerID,
                                      isRecurrent, accountAddress = "",
                                      chainID = 0, symbol = "") {
                console.warn("fetchProviderUrl called >> uuid: ", uuid, "providerID: ",providerID
                             , "isRecurrent: ", isRecurrent, "accountAddress: ", accountAddress,
                             "chainID: ", chainID, "symbol: ", symbol)
                d.uuid = uuid
                d.debounceFetchProviderUrl()
            }
        }
    }

    PopupBackground {
        id: popupBg

        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Button {
            id: reopenButton
            anchors.centerIn: parent
            text: "Reopen"
            enabled: !buySellModal.visible

            onClicked: buySellModal.open()
        }

        BuyCryptoModal {
            id: buySellModal
            anchors.centerIn: parent
            visible: true
            modal: false
            closePolicy: Popup.CloseOnEscape
            buyCryptoAdaptor: BuyCryptoModalAdaptor {
                buyCryptoStore: d.buyCryptoStore
                readonly property var currencyStore: CurrenciesStore {}
                readonly property var assetsStore: WalletAssetsStore {
                    id: thisWalletAssetStore
                    walletTokensStore: TokensStore {
                        plainTokensBySymbolModel: TokensBySymbolModel {}
                    }
                    readonly property var baseGroupedAccountAssetModel: GroupedAccountsAssetsModel {}
                    assetsWithFilteredBalances: thisWalletAssetStore.groupedAccountsAssetsModel
                }
                buyCryptoFormData: buySellModal.buyCryptoInputParamsForm
                walletAccountsModel: WalletAccountsModel{}
                networksModel: NetworksModel.flatNetworks
                areTestNetworksEnabled: true
                groupedAccountAssetsModel: assetsStore.groupedAccountAssetsModel
                plainTokensBySymbolModel: assetsStore.walletTokensStore.plainTokensBySymbolModel
                currentCurrency: currencyStore.currentCurrency
            }
            buyCryptoInputParamsForm: BuyCryptoParamsForm{
                selectedWalletAddress: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240"
                selectedNetworkChainId: 11155111
                selectedTokenKey: "ETH"
            }
        }
    }
}

// category: Popups
