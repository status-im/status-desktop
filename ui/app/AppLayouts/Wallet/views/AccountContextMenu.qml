import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Popups 0.1

import "../stores"

StatusMenu {
    id: root

    property var account

    signal editAccountClicked()
    signal deleteAccountClicked()
    signal addNewAccountClicked()
    signal addWatchOnlyAccountClicked()

    width: 204

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
        text: qsTr("Add watch-only account")
        enabled: !root.account
        icon.name: "show"
        onTriggered: {
            root.addWatchOnlyAccountClicked()
        }
    }
}
