import QtQuick 2.15
import QtQuick.Layouts 1.15
import Qt.labs.settings 1.1

import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Popups.Dialog 0.1

import AppLayouts.Wallet.controls 1.0

import utils 1.0
import shared.controls 1.0
import shared.views 1.0
import shared.stores 1.0 as SharedStores
import shared.panels 1.0

import "./"
import "../stores"
import "../panels"
import "../views/collectibles"

RightTabBaseView {
    id: root

    enum TabIndex {
        Assets = 0,
        Collectibles = 1,
        Activity = 2
    }

    property SharedStores.RootStore sharedRootStore

    property alias currentTabIndex: walletTabBar.currentIndex

    signal launchShareAddressModal()
    signal launchBuyCryptoModal()
    signal launchSwapModal(string tokensKey)
    signal sendTokenRequested(string senderAddress, string tokenId, int tokenType)


    function resetView() {
        resetStack()
        root.currentTabIndex = 0
    }

    function resetStack() {
        stack.currentIndex = 0;
        RootStore.backButtonName = d.getBackButtonText(stack.currentIndex);
    }

    headerButton.onClicked: {
        root.launchShareAddressModal()
    }
    header.visible: stack.currentIndex === 0

    StackLayout {
        id: stack
        anchors.fill: parent

        onCurrentIndexChanged: {
            RootStore.backButtonName = d.getBackButtonText(currentIndex)
        }

        QtObject {
            id: d
            function getBackButtonText(index) {
                switch(index) {
                case 1:
                    return qsTr("Collectibles")
                case 2:
                    return qsTr("Assets")
                case 3:
                    return qsTr("Activity")
                default:
                    return ""
                }
            }

            readonly property var detailedCollectibleActivityController: RootStore.tmpActivityController0
        }

        Settings {
            id: walletSettings
            category: "walletSettings-" + root.contactsStore.myPublicKey
            property real collectiblesViewCustomOrderApplyTimestamp: 0
            property bool buyBannerEnabled: true
            property bool receiveBannerEnabled: true
        }

        Component {
            id: buyReceiveBannerComponent
            BuyReceiveBanner {
                id: banner
                topPadding: anyVisibleItems ? 8 : 0
                bottomPadding: anyVisibleItems ? 20 : 0

                onBuyClicked: root.launchBuyCryptoModal()
                onReceiveClicked: root.launchShareAddressModal()
                buyEnabled: walletSettings.buyBannerEnabled
                receiveEnabled: walletSettings.receiveBannerEnabled
                onCloseBuy: walletSettings.buyBannerEnabled = false
                onCloseReceive: walletSettings.receiveBannerEnabled = false
            }
        }

        Component {
            id: confirmHideCommunityAssetsPopup

            ConfirmHideCommunityAssetsPopup {
                destroyOnClose: true

                required property string communityId

                onConfirmButtonClicked: {
                    RootStore.walletAssetsStore.assetsController.showHideGroup(communityId, false /*hide*/)
                    close();
                }
            }
        }

        // StackLayout.currentIndex === 0
        ColumnLayout {
            spacing: 0

            ImportKeypairInfo {
                Layout.fillWidth: true
                Layout.topMargin: Theme.bigPadding
                Layout.preferredHeight: childrenRect.height
                visible: root.store.walletSectionInst.hasPairedDevices && root.store.walletSectionInst.keypairOperabilityForObservedAccount === Constants.keypair.operability.nonOperable

                onRunImport: {
                    root.store.walletSectionInst.runKeypairImportPopup()
                }
            }

            RowLayout {
                Layout.fillWidth: true
                StatusTabBar {
                    id: walletTabBar
                    objectName: "rightSideWalletTabBar"
                    Layout.fillWidth: true
                    Layout.topMargin: Theme.padding

                    StatusTabButton {
                        objectName: "assetsTabButton"
                        width: implicitWidth
                        text: qsTr("Assets")
                    }
                    StatusTabButton {
                        objectName: "collectiblesTabButton"
                        width: implicitWidth
                        text: qsTr("Collectibles")
                    }
                    StatusTabButton {
                        objectName: "activityTabButton"
                        rightPadding: 0
                        width: implicitWidth
                        text: qsTr("Activity")

                        StatusBetaTag {
                            // TODO remove me when Activity is no longer experimental
                            // Keep Activity as the last tab for now as the Experimental tag don't flow 
                            anchors.top: parent.top
                            anchors.topMargin: 6
                            anchors.left: parent.right
                            anchors.leftMargin: 5
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                    onCurrentIndexChanged: {
                        RootStore.setCurrentViewedHoldingType(walletTabBar.currentIndex === 1 ? Constants.TokenType.ERC721 : Constants.TokenType.ERC20)
                    }
                }
                StatusFlatButton {
                    id: filterButton
                    objectName: "filterButton"
                    icon.name: "filter"
                    checkable: true
                    icon.color: checked ? Theme.palette.primaryColor1 : Theme.palette.baseColor1
                    Behavior on icon.color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
                    highlighted: checked
                    visible: walletTabBar.currentIndex !== RightTabView.TabIndex.Activity // TODO #16761: Re-enable filter for activity when implemented
                }
            }

            Loader {
                id: mainViewLoader
                Layout.fillWidth: true
                Layout.fillHeight: true
                sourceComponent: {
                    switch (walletTabBar.currentIndex) {
                        case RightTabView.TabIndex.Assets: return assetsView
                        case RightTabView.TabIndex.Collectibles: return collectiblesView
                        case RightTabView.TabIndex.Activity: return historyView
                    }
                }

                Component {
                    id: assetsView

                    AssetsView {
                        AssetsViewAdaptor {
                            id: assetsViewAdaptor

                            accounts: RootStore.addressFilters
                            chains: RootStore.networkFiltersArray

                            marketValueThreshold:
                                RootStore.tokensStore.displayAssetsBelowBalance
                                ? RootStore.tokensStore.getDisplayAssetsBelowBalanceThresholdDisplayAmount()
                                : 0

                            Connections {
                                target: RootStore.tokensStore

                                function displayAssetsBelowBalanceThresholdChanged() {
                                    assetsViewAdaptor.marketValueThresholdChanged()
                                }
                            }

                            tokensModel: RootStore.walletAssetsStore.groupedAccountAssetsModel

                            formatBalance: (balance, symbol) => {
                                return LocaleUtils.currencyAmountToLocaleString(
                                                   RootStore.currencyStore.getCurrencyAmount(balance, symbol))
                            }

                            chainsError: (chains) => {
                                if (!root.networkConnectionStore)
                                    return ""
                                return root.networkConnectionStore.getBlockchainNetworkDownText(chains)
                            }
                        }

                        function refreshSortSettings() {
                            settings.category = settingsCategoryName
                            walletSettings.sync()
                            settings.sync()
                            let value = SortOrderComboBox.TokenOrderBalance
                            if (walletSettings.assetsViewCustomOrderApplyTimestamp > settings.sortOrderUpdateTimestamp && customOrderAvailable) {
                                value = SortOrderComboBox.TokenOrderCustom
                            } else {
                                value = settings.currentSortValue
                            }
                            sortByValue(value)
                            setSortOrder(settings.currentSortOrder)
                        }

                        function saveSortSettings() {
                            settings.currentSortValue = getSortValue()
                            settings.currentSortOrder = getSortOrder()
                            settings.sortOrderUpdateTimestamp = new Date().getTime()
                            settings.sync()
                        }

                        readonly property string settingsCategoryName: {
                            const addressFilters = RootStore.addressFilters
                            return "AssetsViewSortSettings-" + (addressFilters.indexOf(':') > -1 ? "all" : addressFilters)
                        }
                        onSettingsCategoryNameChanged: {
                            saveSortSettings()
                            refreshSortSettings()
                        }

                        Component.onCompleted: refreshSortSettings()
                        Component.onDestruction: saveSortSettings()

                        readonly property Settings walletSettings: Settings {
                            id: walletSettings
                            category: "walletSettings-" + root.contactsStore.myPublicKey
                            property var assetsViewCustomOrderApplyTimestamp
                        }

                        readonly property Settings settings: Settings {
                            id: settings
                            property int currentSortValue: SortOrderComboBox.TokenOrderDateAdded
                            property var sortOrderUpdateTimestamp
                            property int currentSortOrder: Qt.DescendingOrder
                        }

                        loading: RootStore.overview.balanceLoading
                        sorterVisible: filterButton.checked
                        customOrderAvailable: RootStore.walletAssetsStore.assetsController.hasSettings
                        model: assetsViewAdaptor.model
                        bannerComponent: buyReceiveBannerComponent

                        marketDataError: !!root.networkConnectionStore
                                         ? root.networkConnectionStore.getMarketNetworkDownText()
                                         : ""
                        balanceError: {
                            if (!root.networkConnectionStore)
                                return ""

                            return (root.networkConnectionStore.noBlockchainConnectionAndNoCache
                                    && !root.networkConnectionStore.noMarketConnectionAndNoCache)
                                    ? root.networkConnectionStore.noBlockchainConnectionAndNoCacheText
                                    : ""
                        }

                        formatFiat: balance => RootStore.currencyStore.formatCurrencyAmount(
                                        balance, RootStore.currencyStore.currentCurrency)

                        sendEnabled: root.networkConnectionStore.sendBuyBridgeEnabled &&
                                     !RootStore.overview.isWatchOnlyAccount && RootStore.overview.canSend
                        communitySendEnabled: RootStore.tokensStore.showCommunityAssetsInSend
                        swapEnabled: !RootStore.overview.isWatchOnlyAccount
                        swapVisible: root.swapEnabled

                        onSendRequested: {
                            root.sendTokenRequested(RootStore.overview.mixedcaseAddress.toLowerCase(),
                                                    key, Constants.TokenType.ERC20)
                        }

                        onSwapRequested: root.launchSwapModal(key)
                        onReceiveRequested: root.launchShareAddressModal()
                        onCommunityClicked: Global.switchToCommunity(communityKey)

                        onHideRequested: (key) => {
                                             const token = ModelUtils.getByKey(model, "key", key)
                                             Global.openConfirmHideAssetPopup(token.symbol, token.name, token.icon, !!token.communityId)
                                         }
                        onHideCommunityAssetsRequested:
                            (communityKey) => {
                                const community = ModelUtils.getByKey(model, "communityId", communityKey)
                                confirmHideCommunityAssetsPopup.createObject(root, {
                                                                                 name: community.communityName,
                                                                                 icon: community.communityIcon,
                                                                                 communityId: communityKey }
                                                                             ).open()
                            }
                        onManageTokensRequested: Global.changeAppSectionBySectionType(
                                                     Constants.appSection.profile,
                                                     Constants.settingsSubsection.wallet,
                                                     Constants.walletSettingsSubsection.manageAssets)
                        onAssetClicked: (key) => {
                            const token = ModelUtils.getByKey(model, "key", key)

                            RootStore.tokensStore.getHistoricalDataForToken(
                                                token.symbol, RootStore.currencyStore.currentCurrency)

                            assetDetailView.token = token
                            RootStore.setCurrentViewedHolding(
                                                token.symbol, token.key, Constants.TokenType.ERC20, token.communityId ?? "")
                            stack.currentIndex = 2
                        }
                    }
                }

                Component {
                    id: collectiblesView
                    CollectiblesView { 
                        id: collView
                        function refreshSortSettings() {
                            settings.category = settingsCategoryName
                            walletSettings.sync()
                            settings.sync()
                            let value = SortOrderComboBox.TokenOrderBalance
                            if (walletSettings.collectiblesViewCustomOrderApplyTimestamp > settings.sortOrderUpdateTimestamp && customOrderAvailable) {
                                value = SortOrderComboBox.TokenOrderCustom
                            } else {
                                value = settings.currentSortValue
                            }
                            sortByValue(value)
                            setSortOrder(settings.currentSortOrder)
                        }

                        function saveSortSettings() {
                            settings.currentSortValue = getSortValue()
                            settings.currentSortOrder = getSortOrder()
                            settings.sortOrderUpdateTimestamp = new Date().getTime()
                            settings.sync()
                        }

                        readonly property string settingsCategoryName: "CollectiblesViewSortSettings-" + (addressFilters.indexOf(':') > -1 ? "all" : addressFilters)
                        onSettingsCategoryNameChanged: {
                            saveSortSettings()
                            refreshSortSettings()
                        }

                        Component.onCompleted: refreshSortSettings()
                        Component.onDestruction: saveSortSettings()

                        readonly property Settings settings: Settings {
                            id: settings
                            property int currentSortValue: SortOrderComboBox.TokenOrderDateAdded
                            property real sortOrderUpdateTimestamp: 0
                            property alias selectedFilterGroupIds: collView.selectedFilterGroupIds
                            property int currentSortOrder: Qt.DescendingOrder
                        }

                        ownedAccountsModel: RootStore.nonWatchAccounts
                        controller: RootStore.collectiblesStore.collectiblesController
                        networkFilters: RootStore.networkFilters
                        addressFilters: RootStore.addressFilters
                        sendEnabled: root.networkConnectionStore.sendBuyBridgeEnabled && !RootStore.overview.isWatchOnlyAccount && RootStore.overview.canSend
                        filterVisible: filterButton.checked
                        customOrderAvailable: controller.hasSettings
                        bannerComponent: buyReceiveBannerComponent
                        onCollectibleClicked: {
                            RootStore.collectiblesStore.getDetailedCollectible(chainId, contractAddress, tokenId)
                            RootStore.setCurrentViewedHolding(uid, uid, tokenType, communityId)
                            d.detailedCollectibleActivityController.resetFilter()
                            d.detailedCollectibleActivityController.setFilterAddressesJson(JSON.stringify(RootStore.addressFilters.split(":")))
                            d.detailedCollectibleActivityController.setFilterChainsJson(JSON.stringify([chainId]), false)
                            d.detailedCollectibleActivityController.setFilterCollectibles(JSON.stringify([uid]))
                            d.detailedCollectibleActivityController.updateFilter()

                            stack.currentIndex = 1
                        }
                        onSendRequested: (symbol, tokenType, fromAddress) => {
                                             const collectible = ModelUtils.getByKey(controller.sourceModel, "symbol", symbol)
                                             if (!!collectible && collectible.communityPrivilegesLevel === Constants.TokenPrivilegesLevel.Owner) {
                                                 Global.openTransferOwnershipPopup(collectible.communityId,
                                                                                   collectible.communityName,
                                                                                   collectible.communityImage,
                                                                                   {
                                                                                       key: collectible.tokenId,
                                                                                       privilegesLevel: collectible.communityPrivilegesLevel,
                                                                                       chainId: collectible.chainId,
                                                                                       name: collectible.name,
                                                                                       artworkSource: collectible.communityImage,
                                                                                       accountAddress: fromAddress,
                                                                                       tokenAddress: collectible.contractAddress
                                                                                   })
                                                 return
                                             }

                                             root.sendTokenRequested(fromAddress, symbol, tokenType)
                                         }
                        onReceiveRequested: (symbol) => root.launchShareAddressModal()
                        onSwitchToCommunityRequested: (communityId) => Global.switchToCommunity(communityId)
                        onManageTokensRequested: Global.changeAppSectionBySectionType(Constants.appSection.profile, Constants.settingsSubsection.wallet,
                                                                                      Constants.walletSettingsSubsection.manageCollectibles)
                        isFetching: RootStore.collectiblesStore.areCollectiblesFetching
                        isUpdating: RootStore.collectiblesStore.areCollectiblesUpdating
                        isError: RootStore.collectiblesStore.areCollectiblesError
                    }
                }
                Component {
                    id: historyView
                    HistoryView {
                        overview: RootStore.overview
                        walletRootStore: RootStore
                        communitiesStore: root.communitiesStore
                        currencyStore: root.sharedRootStore.currencyStore
                        showAllAccounts: RootStore.showAllAccounts
                        filterVisible: false  // TODO #16761: Re-enable filter for activity when implemented
                        bannerComponent: buyReceiveBannerComponent
                    }
                }
            }
        }
        CollectibleDetailView {
            id: collectibleDetailView

            visible : (stack.currentIndex === 1)

            collectible: RootStore.collectiblesStore.detailedCollectible
            isCollectibleLoading: RootStore.collectiblesStore.isDetailedCollectibleLoading
            activityModel: d.detailedCollectibleActivityController.model
            addressFilters: RootStore.addressFilters
            rootStore: root.sharedRootStore
            walletRootStore: RootStore
            communitiesStore: root.communitiesStore

            onVisibleChanged: {
                if (!visible) {
                    RootStore.resetCurrentViewedHolding(Constants.TokenType.ERC721)
                    RootStore.collectiblesStore.resetDetailedCollectible()
                }
            }
        }
        AssetsDetailView {
            id: assetDetailView

            visible: (stack.currentIndex === 2)

            tokensStore: RootStore.tokensStore
            allNetworksModel: RootStore.filteredFlatModel
            address: RootStore.overview.mixedcaseAddress
            currencyStore: RootStore.currencyStore
            networkFilters: RootStore.networkFilters

            networkConnectionStore: root.networkConnectionStore

            onVisibleChanged: {
                if (!visible)
                    RootStore.resetCurrentViewedHolding(Constants.TokenType.ERC20)
            }
        }
    }
}
