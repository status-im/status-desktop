import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import Qt.labs.settings 1.1
import QtQml 2.15

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.popups.keypairimport 1.0
import shared.status 1.0
import shared.stores 1.0 as SharedStores

import "../stores"
import "../controls"
import "../popups"
import "../panels"

import AppLayouts.Profile.views.wallet 1.0
import AppLayouts.Wallet.stores 1.0
import AppLayouts.Wallet.controls 1.0
import AppLayouts.Wallet 1.0

SettingsContentBase {
    id: root

    property var emojiPopup
    property string myPublicKey: ""
    property alias currencySymbol: manageTokensView.currencySymbol

    property int settingsSubSubsection

    property ProfileSectionStore rootStore
    property WalletStore walletStore: rootStore.walletStore
    required property TokensStore tokensStore
    property SharedStores.NetworkConnectionStore networkConnectionStore
    required property WalletAssetsStore assetsStore
    required property CollectiblesStore collectiblesStore

    readonly property int mainViewIndex: 0
    readonly property int networksViewIndex: 1
    readonly property int editNetworksViewIndex: 2
    readonly property int accountOrderViewIndex: 3
    readonly property int accountViewIndex: 4
    readonly property int manageTokensViewIndex: 5
    readonly property int savedAddressesViewIndex: 6

    readonly property string walletSectionTitle: qsTr("Wallet")
    readonly property string networksSectionTitle: qsTr("Networks")

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
        readonly property bool isManageTokensSubsection: root.settingsSubSubsection === Constants.walletSettingsSubsection.manageAssets ||
                                                         root.settingsSubSubsection === Constants.walletSettingsSubsection.manageCollectibles ||
                                                         root.settingsSubSubsection === Constants.walletSettingsSubsection.manageHidden ||
                                                         root.settingsSubSubsection === Constants.walletSettingsSubsection.manageAdvanced

        readonly property var walletSettings: Settings {
            category: "walletSettings-" + root.myPublicKey
        }
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

        onCurrentIndexChanged: {
            root.rootStore.backButtonName = ""
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
                root.rootStore.backButtonName = root.walletSectionTitle
                root.sectionTitle = root.networksSectionTitle

                root.titleRowComponentLoader.sourceComponent = toggleTestnetModeSwitchComponent
            }

            if(currentIndex == root.editNetworksViewIndex) {
                root.rootStore.backButtonName = root.networksSectionTitle
                root.sectionTitle = qsTr("Edit %1").arg(!!editNetwork.network &&
                                                        !!editNetwork.network.chainName ? editNetwork.network.chainName: "")
                root.titleRowLeftComponentLoader.visible = true
                root.titleRowLeftComponentLoader.sourceComponent = networkIcon
                root.titleLayout.spacing = 12

            } else if(currentIndex == root.accountViewIndex) {
                root.rootStore.backButtonName = root.walletSectionTitle
                root.sectionTitle = ""

            } else if(currentIndex == root.accountOrderViewIndex) {
                root.rootStore.backButtonName = root.walletSectionTitle
                root.sectionTitle = qsTr("Edit account order")
                root.titleRowComponentLoader.sourceComponent = experimentalTagComponent
                root.stickTitleRowComponentLoader = true

            } else if(currentIndex == root.manageTokensViewIndex) {
                root.rootStore.backButtonName = root.walletSectionTitle
                root.titleRowLeftComponentLoader.visible = false
                root.sectionTitle = qsTr("Manage tokens")
                root.titleRowComponentLoader.sourceComponent = experimentalTagComponent
                root.stickTitleRowComponentLoader = true
            } else if(currentIndex == root.savedAddressesViewIndex) {
                root.rootStore.backButtonName = root.walletSectionTitle
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

            onGoToNetworksView: {
                stackContainer.currentIndex = networksViewIndex
            }

            onGoToAccountView: {
                if (!!account && !!account.address) {
                    root.rootStore.addressWasShown(account.address)
                }

                root.walletStore.setSelectedAccount(account.address)
                root.walletStore.selectedAccount = Qt.binding(function() { return root.walletStore.accountsModule.selectedAccount })
                accountView.keyPair = Qt.binding(function() { return root.walletStore.accountsModule.selectedKeyPair })
                stackContainer.currentIndex = accountViewIndex
            }

            onGoToAccountOrderView: {
                stackContainer.currentIndex = accountOrderViewIndex
            }
            onRunRenameKeypairFlow: {
                renameKeypairPopup.keyUid = model.keyPair.keyUid
                renameKeypairPopup.name = model.keyPair.name
                renameKeypairPopup.accounts = model.keyPair.accounts
                renameKeypairPopup.active = true
            }
            onRunRemoveKeypairFlow: {
                removeKeypairPopup.name = model.keyPair.name
                removeKeypairPopup.keyUid = model.keyPair.keyUid
                removeKeypairPopup.accounts= model.keyPair.accounts
                removeKeypairPopup.active = true
            }
            onRunMoveKeypairToKeycardFlow: {
                root.rootStore.keycardStore.runSetupKeycardPopup(model.keyPair.keyUid)
            }
            onRunStopUsingKeycardFlow: {
                root.rootStore.keycardStore.runStopUsingKeycardPopup(model.keyPair.keyUid)
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

            flatNetworks: root.walletStore.flatNetworks
            areTestNetworksEnabled: root.walletStore.areTestNetworksEnabled

            onGoBack: {
                stackContainer.currentIndex = mainViewIndex
            }

            onEditNetwork: {
                editNetwork.network = ModelUtils.getByKey(root.walletStore.flatNetworks, "chainId", chainId)
                stackContainer.currentIndex = editNetworksViewIndex
            }

            onSetNetworkActive: {
                root.walletStore.setNetworkActive(chainId, active)
            }
        }

        EditNetworkView {
            id: editNetwork
            Layout.fillHeight: true
            Layout.fillWidth: true
            networksModule: root.walletStore.networksModuleInst
            networkRPCChanged: root.walletStore.networkRPCChanged
            rpcProviders: root.walletStore.rpcProviders
            areTestNetworksEnabled: root.walletStore.areTestNetworksEnabled
            onEvaluateRpcEndPoint: root.walletStore.evaluateRpcEndPoint(url, isMainUrl)
            onUpdateNetworkValues: {
                root.walletStore.updateNetworkEndPointValues(chainId, testNetwork, newMainRpcInput, newFailoverRpcUrl)
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
                root.rootStore.keycardStore.runSetupKeycardPopup(keyPair.keyUid)
            }
            onRunStopUsingKeycardFlow: {
                root.rootStore.keycardStore.runStopUsingKeycardPopup(keyPair.keyUid)
            }
            onUpdateWatchAccountHiddenFromTotalBalance: {
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
            contactsStore: root.rootStore.contactsStore
            networkConnectionStore: root.networkConnectionStore

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
                checked: root.walletStore.areTestNetworksEnabled
                onToggled:{
                    checked = Qt.binding(() => root.walletStore.areTestNetworksEnabled)
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
                    root.walletStore.deleteKeypair(removeKeypairPopup.keyUid)
                    removeKeypairPopup.active = false
                }
            }
            onLoaded: removeKeypairPopup.item.open()
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
