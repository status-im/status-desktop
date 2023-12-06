import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import QtQml 2.15

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Utils 0.1

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.popups.keypairimport 1.0
import shared.status 1.0

import "../controls"
import "../popups"
import "../panels"

import AppLayouts.Profile.views.wallet 1.0
import AppLayouts.Wallet.stores 1.0

SettingsContentBase {
    id: root

    property var emojiPopup
    property var rootStore
    property var walletStore
    required property TokensStore tokensStore

    readonly property int mainViewIndex: 0
    readonly property int networksViewIndex: 1
    readonly property int editNetworksViewIndex: 2
    readonly property int accountOrderViewIndex: 3
    readonly property int accountViewIndex: 4
    readonly property int manageTokensViewIndex: 5

    readonly property string walletSectionTitle: qsTr("Wallet")
    readonly property string networksSectionTitle: qsTr("Networks")

    function resetStack() {
        if(stackContainer.currentIndex === root.editNetworksViewIndex) {
            stackContainer.currentIndex = root.networksViewIndex
        }
        else {
            stackContainer.currentIndex = mainViewIndex;
        }
    }

    dirty: manageTokensView.dirty
    ignoreDirty: stackContainer.currentIndex === manageTokensViewIndex
    saveChangesButtonEnabled: dirty
    toast.type: SettingsDirtyToastMessage.Type.Info
    toast.cancelButtonVisible: false
    toast.saveForLaterButtonVisible: dirty
    toast.saveChangesText: qsTr("Apply to my Wallet")
    toast.changesDetectedText: qsTr("New custom sort order created")

    onSaveForLaterClicked: {
        manageTokensView.saveChanges()
    }
    onSaveChangesClicked: {
        manageTokensView.saveChanges()
        Global.displayToastMessage(
            qsTr("Your new custom token order has been applied to your %1", "Go to Wallet")
                    .arg(`<a style="text-decoration:none" href="#${Constants.appSection.wallet}">` + qsTr("Wallet", "Go to Wallet") + "</a>"),
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

    StackLayout {
        id: stackContainer

        width: root.contentWidth
        height: stackContainer.currentIndex === root.mainViewIndex ? main.height:
                stackContainer.currentIndex === root.networksViewIndex ? networksView.height:
                stackContainer.currentIndex === root.editNetworksViewIndex ? editNetwork.height:
                stackContainer.currentIndex === root.accountOrderViewIndex ? accountOrderView.height:
                stackContainer.currentIndex === root.manageTokensViewIndex ? manageTokensView.implicitHeight :
                                                                             accountView.height
        currentIndex: mainViewIndex

        Binding on currentIndex {
            value: root.manageTokensViewIndex
            when: Global.settingsSubSubsection === Constants.walletSettingsSubsection.manageAssets ||
                  Global.settingsSubSubsection === Constants.walletSettingsSubsection.manageCollectibles ||
                  Global.settingsSubSubsection === Constants.walletSettingsSubsection.manageTokenLists
            restoreMode: Binding.RestoreNone
        }

        onCurrentIndexChanged: {
            root.rootStore.backButtonName = ""
            root.sectionTitle = root.walletSectionTitle
            root.titleRowComponentLoader.sourceComponent = undefined
            root.titleRowLeftComponentLoader.sourceComponent = undefined
            root.titleRowLeftComponentLoader.visible = false
            root.titleLayout.spacing = 5

            if (currentIndex == root.mainViewIndex) {
                root.titleRowComponentLoader.sourceComponent = addNewAccountButtonComponent
            }

            if(currentIndex == root.networksViewIndex) {
                root.rootStore.backButtonName = root.walletSectionTitle
                root.sectionTitle = root.networksSectionTitle
            }

            if(currentIndex == root.editNetworksViewIndex) {
                root.rootStore.backButtonName = root.networksSectionTitle
                root.sectionTitle = qsTr("Edit %1").arg(!!editNetwork.combinedNetwork.prod &&
                                                        !!editNetwork.combinedNetwork.prod.chainName ? editNetwork.combinedNetwork.prod.chainName: "")
                root.titleRowLeftComponentLoader.visible = true
                root.titleRowLeftComponentLoader.sourceComponent = networkIcon
                root.titleLayout.spacing = 12

            } else if(currentIndex == root.accountViewIndex) {
                root.rootStore.backButtonName = root.walletSectionTitle
                root.sectionTitle = ""

            } else if(currentIndex == root.accountOrderViewIndex) {
                root.rootStore.backButtonName = root.walletSectionTitle
                root.sectionTitle = qsTr("Edit account order")

            } else if(currentIndex == root.manageTokensViewIndex) {
                root.rootStore.backButtonName = root.walletSectionTitle
                root.titleRowLeftComponentLoader.visible = false
                root.sectionTitle = qsTr("Manage tokens")
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
                root.walletStore.selectedAccount = account
                accountView.keyPair = keypair
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
        }

        NetworksView {
            id: networksView
            Layout.fillWidth: true
            Layout.fillHeight: false

            walletStore: root.walletStore

            onGoBack: {
                stackContainer.currentIndex = mainViewIndex
            }

            onEditNetwork: {
                editNetwork.combinedNetwork = network
                stackContainer.currentIndex = editNetworksViewIndex
            }
        }

        EditNetworkView {
            id: editNetwork
            Layout.fillHeight: true
            Layout.fillWidth: true
            networksModule: root.walletStore.networksModule
            onEvaluateRpcEndPoint: root.walletStore.evaluateRpcEndPoint(url, isMainUrl)
            onUpdateNetworkValues: {
                root.walletStore.updateNetworkEndPointValues(chainId, newMainRpcInput, newFailoverRpcUrl, revertToDefault)
                stackContainer.currentIndex = networksViewIndex
            }
        }

        AccountOrderView {
            id: accountOrderView
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
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
            onVisibleChanged: if(!visible) root.walletStore.selectedAccount = null
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
            sourcesOfTokensModel: tokensStore.sourcesOfTokensModel
            tokensListModel: tokensStore.extendedFlatTokensModel
            baseWalletAssetsModel: RootStore.assets // TODO include community assets (#12369)
            baseWalletCollectiblesModel: {
                RootStore.setFillterAllAddresses() // FIXME no other way to get _all_ collectibles?
                // TODO concat proxy model to include community collectibles (#12519)
                return RootStore.collectiblesStore.ownedCollectibles
            }

            Binding on currentIndex {
                value: {
                    switch (Global.settingsSubSubsection) {
                    case Constants.walletSettingsSubsection.manageAssets:
                        return 0
                    case Constants.walletSettingsSubsection.manageCollectibles:
                        return 1
                    case Constants.walletSettingsSubsection.manageTokenLists:
                        return 2
                    }
                }
                when: Global.settingsSubSubsection === Constants.walletSettingsSubsection.manageAssets ||
                      Global.settingsSubSubsection === Constants.walletSettingsSubsection.manageCollectibles ||
                      Global.settingsSubSubsection === Constants.walletSettingsSubsection.manageTokenLists
                restoreMode: Binding.RestoreNone
            }
        }

        DappPermissionsView {
            walletStore: root.walletStore
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
            id: networkIcon
            StatusRoundedImage {
                width: 28
                height: 28
                image.source: Style.svg(!!editNetwork.combinedNetwork.prod && !!editNetwork.combinedNetwork.prod.iconUrl ? editNetwork.combinedNetwork.prod.iconUrl: "")
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
                getNetworkShortNames: function(chainIds) {return root.walletStore.getNetworkShortNames(chainIds)}
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
