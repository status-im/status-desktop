import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ 0.1
import StatusQ.Layout 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import utils 1.0
import shared.controls 1.0
import shared.popups.keypairimport 1.0

import shared.stores 1.0 as SharedStores
import shared.stores.send 1.0

import AppLayouts.stores 1.0 as AppLayoutsStores
import AppLayouts.Communities.stores 1.0
import AppLayouts.Profile.stores 1.0 as ProfileStores

import "popups"
import "panels"
import "views"
import "stores"
import "controls"
import "popups/swap"
import "popups/buy"

Item {
    id: root

    property bool hideSignPhraseModal: false

    property SharedStores.RootStore sharedRootStore
    property AppLayoutsStores.RootStore store
    property ProfileStores.ContactsStore contactsStore
    property CommunitiesStore communitiesStore
    required property TransactionStore transactionStore

    property var emojiPopup: null
    property var sendModalPopup
    property SharedStores.NetworkConnectionStore networkConnectionStore
    property bool appMainVisible

    property bool dappsEnabled
    property bool swapEnabled

    onAppMainVisibleChanged: {
        resetView()
    }

    onVisibleChanged: {
        resetView()
    }

    Connections {
        target: walletSection

        function onFilterChanged(address) {
            RootStore.selectedAddress = address === "" ? "" : address
        }

        function onDisplayKeypairImportPopup() {
            keypairImport.active = true
        }

        function onDestroyKeypairImportPopup() {
            keypairImport.active = false
        }
    }

    enum LeftPanelSelection {
        AllAddresses,
        Address,
        SavedAddresses
    }

    enum RightPanelSelection {
        Assets,
        Collectibles,
        Activity
    }

    function resetView() {
        if (!visible || !appMainVisible) {
            return
        }

        d.displayAllAddresses()

        d.resetRightPanelStackView()

        if(!hideSignPhraseModal && !RootStore.hideSignPhraseModal){
            signPhrasePopup.open();
        }
    }

    function openDesiredView(leftPanelSelection, rightPanelSelection, data) {
        if (leftPanelSelection !== WalletLayout.LeftPanelSelection.AllAddresses &&
                leftPanelSelection !== WalletLayout.LeftPanelSelection.SavedAddresses &&
                leftPanelSelection !== WalletLayout.LeftPanelSelection.Address) {
            console.warn("not supported left selection", leftPanelSelection)
            return
        }

        if (leftPanelSelection === WalletLayout.LeftPanelSelection.SavedAddresses) {
            d.displaySavedAddresses()
        } else {
            let address = data.address ?? ""
            if (leftPanelSelection === WalletLayout.LeftPanelSelection.AllAddresses) {
                d.displayAllAddresses()
            } else if (leftPanelSelection === WalletLayout.LeftPanelSelection.Address) {
                if (!!address) {
                    d.displayAddress(address)
                } else {
                    d.displayAllAddresses()
                }
            }

            if (rightPanelSelection !== WalletLayout.RightPanelSelection.Collectibles &&
                    rightPanelSelection !== WalletLayout.RightPanelSelection.Assets &&
                    rightPanelSelection !== WalletLayout.RightPanelSelection.Activity) {
                console.warn("not supported right selection", rightPanelSelection)
                return
            }

            rightPanelStackView.currentItem.resetView()
            rightPanelStackView.currentItem.currentTabIndex = rightPanelSelection

            let savedAddress = data.savedAddress?? ""
            if (!!savedAddress) {
                RootStore.currentActivityFiltersStore.resetAllFilters()
                RootStore.currentActivityFiltersStore.toggleSavedAddress(savedAddress)
            }
        }
    }

    QtObject {
        id: d

        readonly property bool showSavedAddresses: RootStore.showSavedAddresses
        onShowSavedAddressesChanged: {
            if(showSavedAddresses) {
                rightPanelStackView.replace(cmpSavedAddresses)
            } else {
                rightPanelStackView.replace(walletContainer)
            }
            RootStore.backButtonName = ""
        }

        property SwapInputParamsForm swapFormData: SwapInputParamsForm {
            selectedAccountAddress: RootStore.selectedAddress
        }

        property BuyCryptoParamsForm buyFormData: BuyCryptoParamsForm {
            selectedWalletAddress: RootStore.selectedAddress
        }

        function displayAllAddresses() {
            RootStore.showSavedAddresses = false
            RootStore.selectedAddress = ""
            RootStore.setFilterAllAddresses()
        }

        function displayAddress(address) {
            RootStore.showSavedAddresses = false
            RootStore.selectedAddress = address
            d.resetRightPanelStackView() // Avoids crashing on asset items being destroyed while in signal handler
            RootStore.setFilterAddress(address)
        }

        function displaySavedAddresses() {
            RootStore.showSavedAddresses = true
            RootStore.selectedAddress = ""
        }

        function resetRightPanelStackView() {
            if (rightPanelStackView.currentItem && !!rightPanelStackView.currentItem.resetView) {
                rightPanelStackView.currentItem.resetView()
            }
        }

        function getSelectedOrFirstNonWatchedAddress() {
            return !!RootStore.selectedAddress ?
                    RootStore.selectedAddress :
                    StatusQUtils.ModelUtils.get(RootStore.nonWatchAccounts, 0, "address")
        }
    }

    SignPhraseModal {
        id: signPhrasePopup
        onRemindLaterClicked: hideSignPhraseModal = true
        onAcceptClicked: { RootStore.setHideSignPhraseModal(true); }
    }

    SeedPhraseBackupWarning {
        id: seedPhraseWarning
        width: parent.width
        anchors.top: parent.top
    }

    Component {
        id: cmpSavedAddresses
        SavedAddressesView {
            store: root.store
            contactsStore: root.contactsStore
            networkConnectionStore: root.networkConnectionStore
            sendModal: root.sendModalPopup

            networkFilter.visible: false
            headerButton.text: qsTr("Add new address")
            headerButton.onClicked: {
                Global.openAddEditSavedAddressesPopup({})
            }
        }
    }

    Component {
        id: walletContainer
        RightTabView {
            sharedRootStore: root.sharedRootStore
            store: root.store
            contactsStore: root.contactsStore
            communitiesStore: root.communitiesStore
            sendModal: root.sendModalPopup
            networkConnectionStore: root.networkConnectionStore

            dappsEnabled: root.dappsEnabled
            swapEnabled: root.swapEnabled

            headerButton.text: RootStore.overview.ens || StatusQUtils.Utils.elideAndFormatWalletAddress(RootStore.overview.mixedcaseAddress)
            headerButton.visible: !RootStore.overview.isAllAccounts
            onLaunchShareAddressModal: Global.openShowQRPopup({
                                                                  switchingAccounsEnabled: true,
                                                                  hasFloatingButtons: true
                                                              })
            onLaunchSwapModal: {
                d.swapFormData.selectedAccountAddress = d.getSelectedOrFirstNonWatchedAddress()
                d.swapFormData.selectedNetworkChainId = StatusQUtils.ModelUtils.getByKey(RootStore.filteredFlatModel, "layer", 1, "chainId")
                d.swapFormData.fromTokensKey = tokensKey
                d.swapFormData.defaultToTokenKey = RootStore.areTestNetworksEnabled ? Constants.swap.testStatusTokenKey : Constants.swap.mainnetStatusTokenKey
                Global.openSwapModalRequested(d.swapFormData)
            }
        }
    }

    StatusSectionLayout {
        anchors.top: seedPhraseWarning.bottom
        height: root.height - seedPhraseWarning.height
        width: root.width
        backButtonName: RootStore.backButtonName
        notificationCount: activityCenterStore.unreadNotificationsCount
        hasUnseenNotifications: activityCenterStore.hasUnseenNotifications

        onNotificationButtonClicked: Global.openActivityCenterPopup()
        onBackButtonClicked: {
            rightPanelStackView.currentItem.resetStack();
        }

        leftPanel: LeftTabView {
            id: leftTab
            anchors.fill: parent
            emojiPopup: root.emojiPopup
            networkConnectionStore: root.networkConnectionStore

            changeSelectedAccount: function(address) {
                d.displayAddress(address)
            }
            selectAllAccounts: function() {
                d.displayAllAddresses()
            }
            selectSavedAddresses: function() {
                d.displaySavedAddresses()
            }
        }

        centerPanel: StackView {
            id: rightPanelStackView
            anchors.fill: parent
            anchors.leftMargin: 64
            anchors.rightMargin: 64
            initialItem: walletContainer
            replaceEnter: Transition {
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 400; easing.type: Easing.OutCubic }
            }
            replaceExit: Transition {
                NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 400; easing.type: Easing.OutCubic }
            }
        }
        headerBackground: AccountHeaderGradient {
            width: parent.width
            overview: RootStore.overview
        }

        footer: WalletFooter {
            id: footer

            readonly property bool isHoldingSelected: {
                if (!rightPanelStackView.currentItem || rightPanelStackView.currentItem.currentTabIndex !== WalletLayout.RightPanelSelection.Collectibles) {
                    return false
                }
                return !!walletStore.currentViewedCollectible && walletStore.currentViewedHoldingID !== ""
            }
            readonly property bool isCommunityCollectible: !!walletStore.currentViewedCollectible ? walletStore.currentViewedCollectible.communityId !== "" : false
            readonly property bool isOwnerCommunityCollectible: isCommunityCollectible ? (walletStore.currentViewedCollectible.communityPrivilegesLevel === Constants.TokenPrivilegesLevel.Owner) : false

            visible: anyActionAvailable
            width: parent.width
            height: visible ? 61: implicitHeight
            walletStore: RootStore
            transactionStore: root.transactionStore
            swapEnabled: root.swapEnabled
            networkConnectionStore: root.networkConnectionStore
            isCommunityOwnershipTransfer: footer.isHoldingSelected && footer.isOwnerCommunityCollectible
            communityName: {
                if (selectedCommunityForCollectible.available)
                    return selectedCommunityForCollectible.item.name
                if (isCommunityCollectible)
                    return Utils.compactAddress(walletStore.currentViewedCollectible.communityId, 4)
                return ""
            }

            onLaunchShareAddressModal: Global.openShowQRPopup({
                                                                  switchingAccounsEnabled: true,
                                                                  hasFloatingButtons: true
                                                              })
            onLaunchSendModal: (fromAddress) => {
                if(isCommunityOwnershipTransfer) {
                    const tokenItem = walletStore.currentViewedCollectible
                    const ownership = StatusQUtils.ModelUtils.get(tokenItem.ownership, 0)

                    Global.openTransferOwnershipPopup(tokenItem.communityId,
                                                      footer.communityName,
                                                      tokenItem.communityImage,
                                                      {
                                                          key: tokenItem.tokenId,
                                                          privilegesLevel: tokenItem.communityPrivilegesLevel,
                                                          chainId: tokenItem.chainId,
                                                          name: tokenItem.name,
                                                          artworkSource: tokenItem.artworkSource,
                                                          accountAddress: fromAddress,
                                                          tokenAddress: tokenItem.contractAddress
                                                      },
                                                      root.sendModalPopup)
                    return
                }

                // Common send modal popup:
                root.sendModalPopup.preSelectedAccountAddress = fromAddress
                root.sendModalPopup.preSelectedSendType = Constants.SendType.Transfer
                root.sendModalPopup.preSelectedHoldingID = walletStore.currentViewedHoldingTokensKey
                root.sendModalPopup.preSelectedHoldingType = walletStore.currentViewedHoldingType
                root.sendModalPopup.onlyAssets = false
                root.sendModalPopup.open()
            }
            onLaunchBridgeModal: {
                root.sendModalPopup.preSelectedSendType = Constants.SendType.Bridge
                root.sendModalPopup.preSelectedHoldingID = walletStore.currentViewedHoldingID
                root.sendModalPopup.preSelectedHoldingType = walletStore.currentViewedHoldingType
                root.sendModalPopup.onlyAssets = true
                root.sendModalPopup.open()
            }
            onLaunchSwapModal: {
                d.swapFormData.fromTokensKey =  ""
                d.swapFormData.selectedAccountAddress = d.getSelectedOrFirstNonWatchedAddress()
                d.swapFormData.selectedNetworkChainId = StatusQUtils.ModelUtils.getByKey(RootStore.filteredFlatModel, "layer", 1, "chainId")
                if(!!walletStore.currentViewedHoldingTokensKey && walletStore.currentViewedHoldingType === Constants.TokenType.ERC20) {
                    d.swapFormData.fromTokensKey =  walletStore.currentViewedHoldingTokensKey
                }
                d.swapFormData.defaultToTokenKey = RootStore.areTestNetworksEnabled ? Constants.swap.testStatusTokenKey : Constants.swap.mainnetStatusTokenKey
                Global.openSwapModalRequested(d.swapFormData)
            }
            onLaunchBuyCryptoModal: {
                d.buyFormData.selectedWalletAddress = d.getSelectedOrFirstNonWatchedAddress()
                d.buyFormData.selectedNetworkChainId = StatusQUtils.ModelUtils.getByKey(RootStore.filteredFlatModel, "layer", 1, "chainId")
                d.buyFormData.selectedTokenKey = Constants.ethToken
                if(!!walletStore.currentViewedHoldingTokensKey && walletStore.currentViewedHoldingType === Constants.TokenType.ERC20) {
                    d.buyFormData.selectedTokenKey =  walletStore.currentViewedHoldingTokensKey
                }
                Global.openBuyCryptoModalRequested(d.buyFormData)
            }

            ModelEntry {
                id: selectedCommunityForCollectible
                sourceModel: !!footer.walletStore.currentViewedCollectible && footer.isCommunityCollectible ? root.communitiesStore.communitiesList : null
                key: "id"
                value: footer.walletStore.currentViewedCollectible.communityId
            }
        }
    }

    Loader {
        id: keypairImport
        active: false
        asynchronous: true

        sourceComponent: KeypairImportPopup {
            store.keypairImportModule: RootStore.keypairImportModule
        }

        onLoaded: {
            keypairImport.item.open()
        }
    }
}
