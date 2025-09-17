import QtCore
import QtQml
import QtQuick

import Qt5Compat.GraphicalEffects
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Controls
import StatusQ.Components
import StatusQ.Core.Theme
import StatusQ.Core.Utils

import utils
import shared
import shared.panels
import shared.popups
import shared.popups.keypairimport
import shared.status
import shared.stores as SharedStores

import "../stores"
import "../controls"
import "../popups"
import "../panels"

import AppLayouts.Profile.views.wallet
import AppLayouts.Wallet.stores
import AppLayouts.Wallet.controls
import AppLayouts.Wallet
import AppLayouts.stores as AppLayoutStores

SettingsContentBase {
    id: root

    property var emojiPopup
    property string myPublicKey: ""
    property alias currencySymbol: manageTokensView.currencySymbol

    property int settingsSubSubsection
    readonly property alias backButtonName: priv.backButtonName

    property WalletStore walletStore
    property KeycardStore keycardStore
    property AppLayoutStores.ContactsStore contactsStore
    required property TokensStore tokensStore
    property SharedStores.NetworkConnectionStore networkConnectionStore
    required property WalletAssetsStore assetsStore
    required property CollectiblesStore collectiblesStore
    required property SharedStores.NetworksStore networksStore

    readonly property int mainViewIndex: 0
    readonly property int networksViewIndex: 1
    readonly property int editNetworksViewIndex: 2
    readonly property int accountOrderViewIndex: 3
    readonly property int accountViewIndex: 4
    readonly property int manageTokensViewIndex: 5
    readonly property int savedAddressesViewIndex: 6

    readonly property string walletSectionTitle: qsTr("Wallet")
    readonly property string networksSectionTitle: qsTr("Networks")

    property bool isKeycardEnabled: true

    signal addressWasShownRequested(string address)

    function resetStack() {
        if(stackContainer.currentIndex === root.editNetworksViewIndex) {
            networksView.overrideInitialTabIndex(editNetwork.network.isTest ? networksView.testnetTabIndex : networksView.mainnetTabIndex)
            stackContainer.currentIndex = root.networksViewIndex
        }
        else {
            stackContainer.currentIndex = mainViewIndex;
        }
    }

    // Dirty state will be just ignored when user leaves manage tokens settings (excluding advanced settings that needs user action)
    ignoreDirty: stackContainer.currentIndex === manageTokensViewIndex && !manageTokensView.advancedTabVisible
    dirty: manageTokensView.dirty
    saveChangesButtonEnabled: dirty
    toast.type: SettingsDirtyToastMessage.Type.Info
    toast.cancelButtonVisible: manageTokensView.advancedTabVisible
    toast.saveForLaterButtonVisible: !manageTokensView.advancedTabVisible
    toast.saveForLaterText: qsTr("Save")
    toast.saveChangesText: manageTokensView.advancedTabVisible ? toast.defaultSaveChangesText : qsTr("Save and apply")
    toast.changesDetectedText: manageTokensView.advancedTabVisible ? toast.defaultChangesDetectedText : qsTr("New custom sort order created")

    onSaveForLaterClicked: {
        manageTokensView.saveChanges(false /* update */)
    }
    onSaveChangesClicked: {
        manageTokensView.saveChanges(true /* update */)

        if (manageTokensView.advancedTabVisible) {
            // don't emit toasts when the Advanced tab is visible
            return
        }

        let sectionLink = "%1/%2/".arg(Constants.appSection.wallet).arg(WalletLayout.LeftPanelSelection.AllAddresses)
        if (manageTokensView.assetsPanelVisible) {
            sectionLink += WalletLayout.RightPanelSelection.Assets
            priv.walletSettings.setValue("assetsViewCustomOrderApplyTimestamp", new Date().getTime())
            priv.walletSettings.sync()
        } else if (manageTokensView.collectiblesPanelVisible) {
            sectionLink += WalletLayout.RightPanelSelection.Collectibles
            priv.walletSettings.setValue("collectiblesViewCustomOrderApplyTimestamp", new Date().getTime())
            priv.walletSettings.sync()
        }

        Global.displayToastMessage(
            qsTr("Your new custom token order has been applied to your %1", "Go to Wallet")
                    .arg(`<a style="text-decoration:none" href="#${sectionLink}">` + qsTr("Wallet", "Go to Wallet") + "</a>"),
            "",
            "checkmark-circle",
            false,
            Constants.ephemeralNotificationType.success,
            ""
        )
    }
    onResetChangesClicked: {
        manageTokensView.resetChanges()
    }

    readonly property var priv: QtObject {
        id: priv

        readonly property string removeKeypairIdentifier: "profile-remove-keypair"

        readonly property bool isManageTokensSubsection: root.settingsSubSubsection === Constants.walletSettingsSubsection.manageAssets ||
                                                         root.settingsSubSubsection === Constants.walletSettingsSubsection.manageCollectibles ||
                                                         root.settingsSubSubsection === Constants.walletSettingsSubsection.manageHidden ||
                                                         root.settingsSubSubsection === Constants.walletSettingsSubsection.manageAdvanced

        readonly property bool isManageNetworksSubsection: root.settingsSubSubsection === Constants.walletSettingsSubsection.manageNetworks

        readonly property var walletSettings: Settings {
            category: "walletSettings-" + root.myPublicKey
        }

        property string backButtonName: ""
    }

    StackLayout {
        id: stackContainer

        width: root.contentWidth
        height: stackContainer.currentIndex === root.mainViewIndex ? main.height:
                stackContainer.currentIndex === root.networksViewIndex ? networksView.height:
                stackContainer.currentIndex === root.editNetworksViewIndex ? editNetwork.height:
                stackContainer.currentIndex === root.accountOrderViewIndex ? accountOrderView.height:
                stackContainer.currentIndex === root.manageTokensViewIndex ? manageTokensView.implicitHeight :
                stackContainer.currentIndex === root.savedAddressesViewIndex ? savedAddressesView.height:
                                                                             accountView.height
        currentIndex: mainViewIndex

        Binding on currentIndex {
            value: root.manageTokensViewIndex
            when: priv.isManageTokensSubsection
            restoreMode: Binding.RestoreNone
        }

        Binding on currentIndex {
            value: root.networksViewIndex
            when: root.settingsSubSubsection === Constants.walletSettingsSubsection.manageNetworks
            restoreMode: Binding.RestoreNone
        }

        onCurrentIndexChanged: {
            priv.backButtonName = ""
            root.sectionTitle = root.walletSectionTitle
            root.titleRowComponentLoader.sourceComponent = undefined
            root.titleRowLeftComponentLoader.sourceComponent = undefined
            root.titleRowLeftComponentLoader.visible = false
            root.stickTitleRowComponentLoader = false
            root.titleLayout.spacing = 5

            if (currentIndex == root.mainViewIndex) {
                root.titleRowComponentLoader.sourceComponent = addNewAccountButtonComponent
            }

            if(currentIndex == root.networksViewIndex) {
                priv.backButtonName = root.walletSectionTitle
                root.sectionTitle = root.networksSectionTitle

                root.titleRowComponentLoader.sourceComponent = toggleTestnetModeSwitchComponent
            }

            if(currentIndex == root.editNetworksViewIndex) {
                priv.backButtonName = root.networksSectionTitle
                root.sectionTitle = qsTr("Edit %1").arg(!!editNetwork.network &&
                                                        !!editNetwork.network.chainName ? editNetwork.network.chainName: "")
                root.titleRowLeftComponentLoader.visible = true
                root.titleRowLeftComponentLoader.sourceComponent = networkIcon
                root.titleLayout.spacing = 12

            } else if(currentIndex == root.accountViewIndex) {
                priv.backButtonName = root.walletSectionTitle
                root.sectionTitle = ""

            } else if(currentIndex == root.accountOrderViewIndex) {
                priv.backButtonName = root.walletSectionTitle
                root.sectionTitle = qsTr("Edit account order")
                root.titleRowComponentLoader.sourceComponent = experimentalTagComponent
                root.stickTitleRowComponentLoader = true

            } else if(currentIndex == root.manageTokensViewIndex) {
                priv.backButtonName = root.walletSectionTitle
                root.titleRowLeftComponentLoader.visible = false
                root.sectionTitle = qsTr("Manage tokens")
                root.titleRowComponentLoader.sourceComponent = experimentalTagComponent
                root.stickTitleRowComponentLoader = true
            } else if(currentIndex == root.savedAddressesViewIndex) {
                priv.backButtonName = root.walletSectionTitle
                root.titleRowLeftComponentLoader.visible = false
                root.sectionTitle = qsTr("Saved addresses")

                root.titleRowComponentLoader.sourceComponent = addNewSavedAddressButtonComponent
            }
        }

        MainView {
            id: main

            Layout.fillWidth: true
            Layout.fillHeight: false

            walletStore: root.walletStore
            emojiPopup: root.emojiPopup
            isKeycardEnabled: root.isKeycardEnabled

            onGoToNetworksView: {
                stackContainer.currentIndex = networksViewIndex
            }

            onGoToAccountView: (account) => {
                if (!!account && !!account.address) {
                    root.addressWasShownRequested(account.address)
                }

                root.walletStore.setSelectedAccount(account.address)
                root.walletStore.selectedAccount = Qt.binding(function() { return root.walletStore.accountsModule.selectedAccount })
                accountView.keyPair = Qt.binding(function() { return root.walletStore.accountsModule.selectedKeyPair })
                stackContainer.currentIndex = accountViewIndex
            }

            onGoToAccountOrderView: {
                stackContainer.currentIndex = accountOrderViewIndex
            }
            onRunRenameKeypairFlow: (model) => {
                renameKeypairPopup.keyUid = model.keyPair.keyUid
                renameKeypairPopup.name = model.keyPair.name
                renameKeypairPopup.accounts = model.keyPair.accounts
                renameKeypairPopup.active = true
            }
            onRunRemoveKeypairFlow: (model) => {
                removeKeypairPopup.name = model.keyPair.name
                removeKeypairPopup.keyUid = model.keyPair.keyUid
                removeKeypairPopup.accounts= model.keyPair.accounts
                removeKeypairPopup.active = true
            }
            onRunMoveKeypairToKeycardFlow: (model) => {
                root.keycardStore.runSetupKeycardPopup(model.keyPair.keyUid)
            }
            onRunStopUsingKeycardFlow: (model) => {
                root.keycardStore.runStopUsingKeycardPopup(model.keyPair.keyUid)
            }
            onGoToManageTokensView: {
                stackContainer.currentIndex = manageTokensViewIndex
            }
            onGoToSavedAddressesView: {
                stackContainer.currentIndex = root.savedAddressesViewIndex
            }
        }

        NetworksView {
            id: networksView
            Layout.fillWidth: true
            Layout.fillHeight: false

            flatNetworks: root.networksStore.allNetworks
            areTestNetworksEnabled: root.networksStore.areTestNetworksEnabled

            onGoBack: {
                stackContainer.currentIndex = mainViewIndex
            }

            onEditNetwork: function (chainId) {
                editNetwork.network = ModelUtils.getByKey(root.networksStore.allNetworks, "chainId", chainId)
                stackContainer.currentIndex = editNetworksViewIndex
            }

            onSetNetworkActive: function (chainId, active) {
                root.networksStore.setNetworkActive(chainId, active)
            }
        }

        EditNetworkView {
            id: editNetwork
            Layout.fillHeight: true
            Layout.fillWidth: true
            networksModule: root.networksStore.networksModuleInst
            networkRPCChanged: root.networksStore.networkRPCChanged
            rpcProviders: root.networksStore.rpcProviders
            areTestNetworksEnabled: root.networksStore.areTestNetworksEnabled
            onEvaluateRpcEndPoint: root.networksStore.evaluateRpcEndPoint(url, isMainUrl)
            onUpdateNetworkValues: {
                root.networksStore.updateNetworkEndPointValues(chainId, newMainRpcInput, newFailoverRpcUrl)
            }
        }

        AccountOrderView {
            id: accountOrderView
            Layout.fillWidth: true
            Layout.leftMargin: Theme.padding
            Layout.rightMargin: Theme.padding
            walletStore: root.walletStore
            onGoBack: {
                stackContainer.currentIndex = mainViewIndex
            }
        }

        AccountView {
            id: accountView
            account: root.walletStore.selectedAccount
            walletStore: root.walletStore
            emojiPopup: root.emojiPopup
            userProfilePublicKey: walletStore.userProfilePublicKey
            activeNetworks: root.networksStore.activeNetworks
            onGoBack: stackContainer.currentIndex = mainViewIndex
            onVisibleChanged: {
                if (!visible && !!root.walletStore) {
                    root.walletStore.selectedAccount = null
                    keyPair = null
                }
            }
            onRunRenameKeypairFlow: {
                renameKeypairPopup.keyUid = keyPair.keyUid
                renameKeypairPopup.name = keyPair.name
                renameKeypairPopup.accounts = keyPair.accounts
                renameKeypairPopup.active = true
            }
            onRunRemoveKeypairFlow: {
                removeKeypairPopup.name = keyPair.name
                removeKeypairPopup.keyUid = keyPair.keyUid
                removeKeypairPopup.accounts= keyPair.accounts
                removeKeypairPopup.active = true
            }
            onRunImportMissingKeypairFlow: {
                root.walletStore.runKeypairImportPopup(keyPair.keyUid, Constants.keypairImportPopup.mode.selectImportMethod)
            }
            onRunMoveKeypairToKeycardFlow: {
                root.keycardStore.runSetupKeycardPopup(keyPair.keyUid)
            }
            onRunStopUsingKeycardFlow: {
                root.keycardStore.runStopUsingKeycardPopup(keyPair.keyUid)
            }
            onUpdateWatchAccountHiddenFromTotalBalance: (address, hideFromTotalBalance) => {
                root.walletStore.updateWatchAccountHiddenFromTotalBalance(address, hideFromTotalBalance)
            }
        }

        ManageTokensView {
            id: manageTokensView

            implicitHeight: root.availableHeight
            Layout.fillWidth: true

            tokensStore: root.tokensStore
            tokenListUpdatedAt: tokensStore.tokenListUpdatedAt
            assetsController: root.assetsStore.assetsController
            collectiblesController: root.collectiblesStore.collectiblesController
            sourcesOfTokensModel: tokensStore.sourcesOfTokensModel
            tokensListModel: tokensStore.extendedFlatTokensModel
            baseWalletAssetsModel: root.assetsStore.groupedAccountAssetsModel
            baseWalletCollectiblesModel: root.collectiblesStore.allCollectiblesModel
            getCurrencyAmount: function (balance, symbol) {
                return RootStore.currencyStore.getCurrencyAmount(balance, symbol)
            }

            getCurrentCurrencyAmount: function (balance) {
                return RootStore.currencyStore.getCurrentCurrencyAmount(balance)
            }

            Binding on currentIndex {
                value: {
                    switch (root.settingsSubSubsection) {
                    case Constants.walletSettingsSubsection.manageAssets:
                        return 0
                    case Constants.walletSettingsSubsection.manageCollectibles:
                        return 1
                    case Constants.walletSettingsSubsection.manageHidden:
                        return 2
                    case Constants.walletSettingsSubsection.manageAdvanced:
                        return 3
                    }
                }
                when: priv.isManageTokensSubsection
                restoreMode: Binding.RestoreNone
            }
        }

        SavedAddressesView {
            id: savedAddressesView
            contactsStore: root.contactsStore
            networkConnectionStore: root.networkConnectionStore
            networksStore: root.networksStore

            onSendToAddressRequested: {
                Global.sendToRecipientRequested(address)
            }
        }

        Component {
            id: addNewAccountButtonComponent
            StatusButton {
                objectName: "settings_Wallet_MainView_AddNewAccountButton"
                text: qsTr("Add new account")
                onClicked: root.walletStore.runAddAccountPopup()
            }
        }

        Component {
            id: experimentalTagComponent
            StatusBetaTag {
                tooltipText: qsTr("Under construction, you might experience some minor issues")
            }
        }

        Component {
            id: toggleTestnetModeSwitchComponent

            StatusSwitch {
                id: testnetSwitch
                objectName: "testnetModeSwitch"
                text: qsTr("Testnet mode")
                leftSide: false
                checked: root.networksStore.areTestNetworksEnabled
                onToggled:{
                    checked = Qt.binding(() => root.networksStore.areTestNetworksEnabled)
                    Global.openTestnetPopup()
                }
            }
        }

        Component {
            id: addNewSavedAddressButtonComponent

            StatusButton {
                objectName: "addNewSavedAddressButton"
                text: qsTr("Add new address")
                onClicked: {
                    Global.openAddEditSavedAddressesPopup({})
                }
            }
        }

        Component {
            id: networkIcon
            StatusRoundedImage {
                width: 28
                height: 28
                image.source: Theme.svg(!!editNetwork.network && !!editNetwork.network.iconUrl ? editNetwork.network.iconUrl: "")
                image.fillMode: Image.PreserveAspectCrop
            }
        }

        Loader {
            id: renameKeypairPopup
            active: false

            property string keyUid
            property string name
            property var accounts

            sourceComponent: RenameKeypairPopup {
                accountsModule: root.walletStore.accountsModule
                keyUid: renameKeypairPopup.keyUid
                name: renameKeypairPopup.name
                accounts: renameKeypairPopup.accounts

                onClosed: {
                    renameKeypairPopup.active = false
                }
            }

            onLoaded: {
                renameKeypairPopup.item.open()
            }
        }

        Loader {
            id: removeKeypairPopup
            active: false

            property string name
            property string keyUid
            property var accounts

            sourceComponent: RemoveKeypairPopup {
                name: removeKeypairPopup.name
                relatedAccounts: removeKeypairPopup.accounts
                onClosed: removeKeypairPopup.active = false
                onConfirmClicked: {
                    root.walletStore.authenticateLoggedInUser(priv.removeKeypairIdentifier)
                }
            }

            onLoaded: {
                const loggedInUserAuthenticated = (requestedBy, password, pin, keyUid, keycardUid) => {
                    if (priv.removeKeypairIdentifier !== requestedBy || password === "") {
                        return
                    }
                    root.walletStore.deleteKeypair(removeKeypairPopup.keyUid, password)
                    removeKeypairPopup.active = false
                }

                root.walletStore.loggedInUserAuthenticated.connect(loggedInUserAuthenticated)
                removeKeypairPopup.item.open()
            }
        }

        Connections {
            target: root.walletStore.walletModule

            function onDisplayKeypairImportPopup() {
                keypairImport.active = true
            }
            function onDestroyKeypairImportPopup() {
                keypairImport.active = false
            }
        }


        Loader {
            id: keypairImport
            active: false
            asynchronous: true

            sourceComponent: KeypairImportPopup {
                store.keypairImportModule: root.walletStore.walletModule.keypairImportModule
            }

            onLoaded: {
                keypairImport.item.open()
            }
        }
    }

    Component.onCompleted: {
        root.titleRowComponentLoader.sourceComponent = addNewAccountButtonComponent
    }
}
