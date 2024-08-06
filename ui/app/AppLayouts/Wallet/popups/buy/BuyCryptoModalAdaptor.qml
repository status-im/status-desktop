import QtQml 2.15
import SortFilterProxyModel 0.2

import StatusQ 0.1
import StatusQ.Core.Utils 0.1

import utils 1.0

import shared.stores 1.0
import AppLayouts.Wallet 1.0
import AppLayouts.Wallet.stores 1.0 as WalletStore

QObject {
    id: root

    required property WalletStore.BuyCryptoStore buyCryptoStore
    required property BuyCryptoParamsForm buyCryptoFormData
    required property var walletAccountsModel
    required property var networksModel
    required property bool areTestNetworksEnabled
    required property var groupedAccountAssetsModel
    required property var plainTokensBySymbolModel
    required property string currentCurrency

    QtObject {
        id: d
        property string uuid
        property bool urlIsBeingFetched
        readonly property var selectedProviderSupportedArray: !!selectedProvider && !!selectedProvider.supportedAssets ? ModelUtils.modelToFlatArray(selectedProvider.supportedAssets, "key"): null
    }

    signal providerUrlReady(string url)

    readonly property bool providersLoading: root.buyCryptoStore.areProvidersLoading
    readonly property var providersModel: root.buyCryptoStore.providersModel

    readonly property bool urlIsBeingFetched: d.urlIsBeingFetched

    readonly property var selectedAccount: selectedAccountEntry.item
    readonly property var selectedToken: selectedTokenEntry.item
    readonly property var selectedProvider: selectedProviderEntry.item

    readonly property SortFilterProxyModel filteredFlatNetworksModel: SortFilterProxyModel {
        sourceModel: root.networksModel
        filters: ValueFilter { roleName: "isTest"; value: root.areTestNetworksEnabled }
    }

    /* TODO evaluate if this is still needed after
    https://github.com/status-im/status-desktop/issues/16025 */
    readonly property ObjectProxyModel plainTokensBySymbolModelWithKey: ObjectProxyModel {
        sourceModel: root.plainTokensBySymbolModel
        delegate: SortFilterProxyModel {
            id: delegateRoot
            readonly property var addressPerChain: this
            sourceModel: model.addressPerChain
            proxyRoles: JoinRole {
                name: "key"
                roleNames: ["chainId", "address"]
                separator: ""
            }
            filters: FastExpressionFilter {
                expression:  !!d.selectedProviderSupportedArray ? d.selectedProviderSupportedArray.includes(model.key) : true
                expectedRoles: ["key"]
            }
        }

        exposedRoles: ["addressPerChain"]
        expectedRoles: ["addressPerChain"]
    }

    /* TODO evaluate if this is still needed after
    https://github.com/status-im/status-desktop/issues/16025 */
    readonly property ObjectProxyModel groupedAccountAssetsModelWithKey: ObjectProxyModel {
        sourceModel: root.groupedAccountAssetsModel
        delegate: SortFilterProxyModel {
            id: delegateRoot1
            readonly property var addressPerChain: this
            sourceModel: model.addressPerChain
            proxyRoles: JoinRole {
                name: "key"
                roleNames: ["chainId", "address"]
                separator: ""
            }
            filters: FastExpressionFilter {
                expression:  !!d.selectedProviderSupportedArray ? d.selectedProviderSupportedArray.includes(model.key) : true
                expectedRoles: ["key"]
            }
        }

        exposedRoles: ["addressPerChain"]
        expectedRoles: ["addressPerChain"]
    }

    function reset() {
        d.uuid = ""
        d.urlIsBeingFetched = false
    }

    function fetchProviders() {
        root.buyCryptoStore.fetchProviders()
    }

    function fetchProviderUrl(
        providerID,
        isRecurrent,
        accountAddress = "",
        chainID = 0,
        symbol = "") {
        // Identify new search with a different uuid
        d.uuid = Utils.uuid()
        d.urlIsBeingFetched = true
        buyCryptoStore.fetchProviderUrl(d.uuid, providerID, isRecurrent,
                                        accountAddress, chainID,symbol)
    }

    Connections {
        target: root.buyCryptoStore
        function onProviderUrlReady(uuid, url) {
           if(uuid === d.uuid) {
               d.urlIsBeingFetched = false
               root.providerUrlReady(url)
           }
        }
    }

    ModelEntry {
        id: selectedAccountEntry
        sourceModel: root.walletAccountsModel
        key: "address"
        value: root.buyCryptoFormData.selectedWalletAddress
    }

    ModelEntry {
        id: selectedTokenEntry
        sourceModel: root.plainTokensBySymbolModel
        key: "key"
        value: root.buyCryptoFormData.selectedTokenKey
    }

    ModelEntry {
        id: selectedProviderEntry
        sourceModel: root.providersModel
        key: "id"
        value: root.buyCryptoFormData.selectedProviderId
    }
}
