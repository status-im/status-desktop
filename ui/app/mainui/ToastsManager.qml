import QtQuick 2.15

import utils 1.0

import AppLayouts.stores 1.0
import AppLayouts.Chat.stores 1.0 as ChatStores

import shared.stores 1.0 as SharedStores

// The purpose of this class is to be the central point for generating toasts in the application.
// It will have as input all needed stores.
// In case the file grows considerably, consider creating different toasts managers per topic / context
// and just instantiate them in here.
QtObject {
    id: root

    // Here there are defined some specific actions needed by a toast.
    // They are normally specific navigations or open popup action.
    enum ActionType {
        None = 0,
        NavigateToCommunityAdmin = 1,
        OpenFinaliseOwnershipPopup = 2,
        OpenSendModalPopup = 3
    }

    // Stores:
    required property RootStore rootStore
    required property ChatStores.RootStore rootChatStore
    required property SharedStores.CommunityTokensStore communityTokensStore

    // Properties:
    required property var sendModalPopup

    // Utils:
    readonly property string viewOptimismExplorerText: qsTr("View on Optimism Explorer")
    readonly property string checkmarkCircleAssetName: "checkmark-circle"
    readonly property string crownOffAssetName: "crown-off"

    // Community Transfer Ownership related toasts:
    readonly property Connections _communityTokensStoreConnections: Connections {
        target: root.communityTokensStore

        // Ownership Receiver:
        function onOwnerTokenReceived(communityId, communityName) {
            let communityColor = root.rootChatStore.getCommunityDetailsAsJson(communityId).color
            Global.displayToastWithActionMessage(qsTr("You received the Owner token for %1. To finalize ownership, make your device the control node.").arg(communityName),
                                                 qsTr("Finalise ownership"),
                                                 "crown",
                                                 communityColor,
                                                 false,
                                                 Constants.ephemeralNotificationType.normal,
                                                 ToastsManager.ActionType.OpenFinaliseOwnershipPopup,
                                                 communityId)
        }

        function onSetSignerStateChanged(communityId, communityName, status, url) {
            if (status === Constants.ContractTransactionStatus.Completed) {
                Global.displayToastMessage(qsTr("%1 smart contract amended").arg(communityName),
                                           root.viewOptimismExplorerText,
                                           root.checkmarkCircleAssetName,
                                           false,
                                           Constants.ephemeralNotificationType.success,
                                           url)
                Global.displayToastWithActionMessage(qsTr("Your device is now the control node for %1. You now have full Community admin rights.").arg(communityName),
                                                     qsTr("%1 Community admin").arg(communityName),
                                                     root.checkmarkCircleAssetName,
                                                     "",
                                                     false,
                                                     Constants.ephemeralNotificationType.success,
                                                     ToastsManager.ActionType.NavigateToCommunityAdmin,
                                                     communityId)
            } else if (status === Constants.ContractTransactionStatus.Failed) {
                Global.displayToastMessage(qsTr("%1 smart contract update failed").arg(communityName),
                                           root.viewOptimismExplorerText,
                                           "warning",
                                           false,
                                           Constants.ephemeralNotificationType.danger,
                                           url)
            } else if (status ===  Constants.ContractTransactionStatus.InProgress) {
                Global.displayToastMessage(qsTr("Updating %1 smart contract").arg(communityName),
                                           root.viewOptimismExplorerText,
                                           "",
                                           true,
                                           Constants.ephemeralNotificationType.normal,
                                           url)
            }
        }

        function onCommunityOwnershipDeclined(communityName) {
            Global.displayToastWithActionMessage(qsTr("You declined ownership of %1.").arg(communityName),
                                                 qsTr("Return owner token to sender"),
                                                 root.crownOffAssetName,
                                                 "",
                                                 false,
                                                 Constants.ephemeralNotificationType.danger,
                                                 ToastsManager.ActionType.OpenSendModalPopup,
                                                 "")
        }

        // Ownership Sender:
        function onSendOwnerTokenStateChanged(tokenName, status, url) {
            if (status === Constants.ContractTransactionStatus.InProgress) {
                Global.displayToastMessage(qsTr("Sending %1 token").arg(tokenName),
                                           root.viewOptimismExplorerText,
                                           "",
                                           true,
                                           Constants.ephemeralNotificationType.normal, url)
            } else if (status ===  Constants.ContractTransactionStatus.Completed) {
                Global.displayToastMessage(qsTr("%1 token sent").arg(tokenName),
                                           root.viewOptimismExplorerText,
                                           root.checkmarkCircleAssetName,
                                           false,
                                           Constants.ephemeralNotificationType.success, url)
            }
        }

        function onOwnershipLost(communityId, communityName) {
            Global.displayToastMessage(qsTr("Your device is no longer the control node for %1.
                                             Your ownership and admin rights for %1 have been transferred to the new owner.").arg(communityName),
                                       "",
                                       root.crownOffAssetName,
                                       false,
                                       Constants.ephemeralNotificationType.danger,
                                       "")
        }
    }

    // Connections to global. These will lead the backend integration:
    readonly property Connections _globalConnections: Connections {
        target: Global

        function onDisplayToastMessage(title: string, subTitle: string, icon: string, loading: bool, ephNotifType: int, url: string) {
            root.rootStore.mainModuleInst.displayEphemeralNotification(title, subTitle, icon, loading, ephNotifType, url)
        }

        // TO UNIFY with the one above.
        // Further refactor will be done in a next step
        function onDisplayToastWithActionMessage(title: string, subTitle: string, icon: string, iconColor: string, loading: bool, ephNotifType: int, actionType: int, actionData: string) {
            root.rootStore.mainModuleInst.displayEphemeralWithActionNotification(title, subTitle, icon, iconColor, loading, ephNotifType, actionType, actionData)
        }
    }

    // It will cover all specific actions (different than open external links) that can be done after clicking toast link text
    function doAction(actionType, actionData) {
        switch(actionType) {
        case ToastsManager.ActionType.NavigateToCommunityAdmin:
            root.rootChatStore.setActiveCommunity(actionData)
            return
        case ToastsManager.ActionType.OpenFinaliseOwnershipPopup:
            Global.openFinaliseOwnershipPopup(actionData)
            return
        case ToastsManager.ActionType.OpenSendModalPopup:
            root.sendModalPopup.open()
            return
        default:
            console.warn("ToastsManager: Action type is not defined")
            return
        }
    }
}
