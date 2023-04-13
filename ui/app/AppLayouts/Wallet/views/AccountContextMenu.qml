import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Popups 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

import "../stores"

StatusMenu {
    id: root

    required property string uniqueIdentifier // unique idetifier added as postfix to options' objectName (used for ui tests)
    property var account

    signal editAccountClicked()
    signal deleteAccountClicked()
    signal addNewAccountClicked()
    signal addWatchOnlyAccountClicked()

    width: 204

    onAboutToShow: {
        d.resetCopyAddressAction()
    }

    QtObject {
        id: d

        function resetCopyAddressAction() {
            copyAddressAction.action.text = qsTr("Copy address")
            copyAddressAction.action.type = StatusAction.Type.Normal
            copyAddressAction.action.icon.name = "copy"
            copyAddressAction.action.icon.color = Theme.palette.primaryColor1
        }
    }

    StatusMenuItem {
        id: copyAddressAction
        objectName: "AccountMenu-CopyAddressAction-%1".arg(root.uniqueIdentifier)
        enabled: !!root.account
        text: qsTr("Copy address")
        action: StatusAction {}
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: {
                RootStore.copyToClipboard(root.account.address?? "")
                copyAddressAction.action.text = qsTr("Address copied")
                copyAddressAction.action.type = StatusAction.Type.Success
                copyAddressAction.action.icon.name = "tiny/checkmark"
                copyAddressAction.action.icon.color = Theme.palette.successColor1

                Backpressure.debounce(root, 1500, function () {
                    d.resetCopyAddressAction()
                    root.dismiss()
                })()
            }
        }
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
        enabled: !!root.account && root.account.walletType !== ""
        text: qsTr("Delete")
        icon.name: "info"
        type: StatusAction.Type.Danger
        onTriggered: {
            root.deleteAccountClicked()
        }
    }

    StatusMenuSeparator {
        visible: !!root.account
    }

    StatusAction {
        objectName: "AccountMenu-AddNewAccountAction-%1".arg(root.uniqueIdentifier)
        text: qsTr("Add new account")
        icon.name: "add"
        onTriggered: {
            root.addNewAccountClicked()
        }
    }

    StatusAction {
        objectName: "AccountMenu-AddWatchOnlyAccountAction-%1".arg(root.uniqueIdentifier)
        text: qsTr("Add watch-only account")
        icon.name: "show"
        onTriggered: {
            root.addWatchOnlyAccountClicked()
        }
    }
}
