import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Popups 0.1

import "../stores"

import utils 1.0

StatusMenu {
    id: root

    property var account

    signal editAccountClicked()
    signal deleteAccountClicked()
    signal addNewAccountClicked()
    signal addWatchOnlyAccountClicked()
    signal hideFromTotalBalanceClicked(string address, bool hideFromTotalBalance)


    StatusSuccessAction {
        id: copyAddressAction
        objectName: "AccountMenu-CopyAddressAction-%1".arg(root.uniqueIdentifier)
        successText: qsTr("Address copied")
        text: qsTr("Copy address")
        icon.name: "copy"
        timeout: 1500
        enabled: !!root.account
        onTriggered: RootStore.copyToClipboard(root.account.address?? "")
    }

    StatusMenuSeparator {
        visible: !!root.account
    }

    StatusAction {
        objectName: "AccountMenu-EditAction-%1".arg(root.uniqueIdentifier)
        enabled: !!root.account
        text: qsTr("Edit")
        icon.name: "pencil-outline"
        onTriggered: {
            root.editAccountClicked()
        }
    }   

    StatusAction {
        objectName: "AccountMenu-HideFromTotalBalance-%1".arg(root.uniqueIdentifier)
        enabled: !!root.account && root.account.walletType === Constants.watchWalletType
        text: !!root.account ? root.account.hideFromTotalBalance ? qsTr("Include in total balance"): qsTr("Exclude from total balance"): ""
        icon.name: !!root.account ? root.account.hideFromTotalBalance ? "show" : "hide": ""
        onTriggered: root.hideFromTotalBalanceClicked(root.account.address, !root.account.hideFromTotalBalance)
    }

    StatusAction {
        objectName: "AccountMenu-DeleteAction-%1".arg(root.uniqueIdentifier)
        enabled: !!root.account && !root.account.isWallet
        text: qsTr("Delete")
        icon.name: "info"
        type: StatusAction.Type.Danger
        onTriggered: {
            root.deleteAccountClicked()
        }
    }

    StatusAction {
        objectName: "AccountMenu-AddNewAccountAction-%1".arg(root.uniqueIdentifier)
        text: qsTr("Add new account")
        enabled: !root.account
        icon.name: "add"
        onTriggered: {
            root.addNewAccountClicked()
        }
    }

    StatusAction {
        objectName: "AccountMenu-AddWatchOnlyAccountAction-%1".arg(root.uniqueIdentifier)
        text: qsTr("Add watched address")
        enabled: !root.account
        icon.name: "show"
        onTriggered: {
            root.addWatchOnlyAccountClicked()
        }
    }
}
