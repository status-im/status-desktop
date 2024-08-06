import QtQuick 2.14
import QtQuick.Layouts 1.0
import QtQml.Models 2.14
import SortFilterProxyModel 0.2

import StatusQ.Popups 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ 0.1

import utils 1.0

import AppLayouts.Wallet.controls 1.0
import AppLayouts.Wallet.adaptors 1.0
import AppLayouts.Wallet.panels 1.0

StatusStackModal {
    id: root

    required property BuyCryptoParamsForm buyCryptoInputParamsForm
    required property BuyCryptoModalAdaptor buyCryptoAdaptor
    
    QtObject {
        id: d
        readonly property var buyButton: StatusButton {
            height: root.finishButton.height
            visible: !!root.replaceItem
            borderColor: "transparent"
            text: qsTr("Buy via %1").arg(!!root.buyCryptoAdaptor.selectedProvider ? root.buyCryptoAdaptor.selectedProvider.name: "")
            loading: root.buyCryptoAdaptor.urlIsBeingFetched
            onClicked: {
                if(!!root.buyCryptoAdaptor.selectedProvider && !!root.buyCryptoAdaptor.selectedToken) {
                    root.buyCryptoAdaptor.fetchProviderUrl(
                                root.buyCryptoInputParamsForm.selectedProviderId,
                                buyCryptoProvidersListPanel.currentTabIndex,
                                root.buyCryptoInputParamsForm.selectedWalletAddress,
                                root.buyCryptoInputParamsForm.selectedNetworkChainId,
                                root.buyCryptoAdaptor.selectedToken.symbol
                                )
                }
            }
            enabled: root.buyCryptoInputParamsForm.filledCorrectly
        }
    }

    width: 560
    height: 515
    padding: Style.current.xlPadding
    stackTitle: qsTr("Buy assets for %1").arg(!!buyCryptoAdaptor.selectedAccount ? buyCryptoAdaptor.selectedAccount.name: "")
    rightButtons: [d.buyButton, finishButton]
    finishButton: StatusButton {
        text: qsTr("Done")
        onClicked: root.close()
    }

    Connections {
        target: root.buyCryptoAdaptor
        function onProviderUrlReady(url) {
            if (!!root.buyCryptoAdaptor.selectedProvider && !!url)
                Global.openLinkWithConfirmation(url, root.buyCryptoAdaptor.selectedProvider.hostname)
            root.close()
        }
    }

    onOpened: root.buyCryptoAdaptor.fetchProviders()
    onClosed: {
        // reset the view
        root.replaceItem = undefined
        buyCryptoProvidersListPanel.currentTabIndex = 0
        root.buyCryptoAdaptor.reset()
        root.buyCryptoInputParamsForm.resetFormData()
    }

    stackItems: [
        BuyCryptoProvidersListPanel {
            id: buyCryptoProvidersListPanel
            providersLoading: root.buyCryptoAdaptor.providersLoading
            providersModel: root.buyCryptoAdaptor.providersModel
            selectedProviderId: root.buyCryptoInputParamsForm.selectedProviderId
            isUrlBeingFetched: root.buyCryptoAdaptor.urlIsBeingFetched
            onProviderSelected: {
                root.buyCryptoInputParamsForm.selectedProviderId = id
                if(!!root.buyCryptoAdaptor.selectedProvider) {
                    if(root.buyCryptoAdaptor.selectedProvider.urlsNeedParameters) {
                        root.replace(selectParamsPanel)
                    } else {
                        root.buyCryptoAdaptor.fetchProviderUrl(root.buyCryptoAdaptor.selectedProvider.id, currentTabIndex)
                    }
                }
            }
        }
    ]

    Component {
        id: selectParamsPanel
        SelectParamsForBuyCryptoPanel {
            id: selectParamsPanelInst
            adaptor: TokenSelectorViewAdaptor {
                /* TODO these should be hadbled and perhaps improved under
                https://github.com/status-im/status-desktop/issues/16025 */
                assetsModel: SortFilterProxyModel {
                    sourceModel: root.buyCryptoAdaptor.groupedAccountAssetsModelWithKey
                    filters: FastExpressionFilter {
                        expression: model.addressPerChain.rowCount() > 0
                        expectedRoles: ["addressPerChain"]
                    }
                }
                plainTokensBySymbolModel: SortFilterProxyModel {
                    sourceModel: root.buyCryptoAdaptor.plainTokensBySymbolModelWithKey
                    filters: FastExpressionFilter {
                        expression: model.addressPerChain.rowCount() > 0
                        expectedRoles: ["addressPerChain"]
                    }
                }
                flatNetworksModel: root.buyCryptoAdaptor.networksModel
                currentCurrency: root.buyCryptoAdaptor.currentCurrency

                showAllTokens: true
                enabledChainIds: root.buyCryptoInputParamsForm.selectedNetworkChainId !== -1 ? [root.buyCryptoInputParamsForm.selectedNetworkChainId] : []
                accountAddress: root.buyCryptoInputParamsForm.selectedWalletAddress
                searchString: selectParamsPanelInst.searchString
            }
            selectedProvider: root.buyCryptoAdaptor.selectedProvider
            selectedTokenKey: root.buyCryptoInputParamsForm.selectedTokenKey
            selectedNetworkChainId: root.buyCryptoInputParamsForm.selectedNetworkChainId
            filteredFlatNetworksModel: root.buyCryptoAdaptor.filteredFlatNetworksModel
            onNetworkSelected: {
                if (root.buyCryptoInputParamsForm.selectedNetworkChainId !== chainId) {
                    root.buyCryptoInputParamsForm.selectedNetworkChainId = chainId
                }
            }
            onTokenSelected: {
                if (root.buyCryptoInputParamsForm.selectedTokenKey !== tokensKey) {
                    root.buyCryptoInputParamsForm.selectedTokenKey = tokensKey
                }
            }
        }
    }
}
