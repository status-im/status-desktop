import QtQuick 2.15

import StatusQ.Popups.Dialog 0.1

import AppLayouts.Communities.panels 1.0

import utils 1.0

StatusDialog {
    id: root

    property bool isEditMode

    required property string communityName
    required property string communityIcon
    property int loginType: Constants.LoginType.Password

    required property var walletAccountsModel // name, address, emoji, colorId, assets
    required property var permissionsModel  // id, key, permissionType, holdingsListModel, channelsListModel, isPrivate, tokenCriteriaMet
    required property var assetsModel
    required property var collectiblesModel

    readonly property string selectedAirdropAddress: panel.selectedAirdropAddress
    readonly property var selectedSharedAddresses: panel.selectedSharedAddresses

    signal shareSelectedAddressesClicked(string airdropAddress, var sharedAddresses)

    title: panel.title
    implicitWidth: 640 // by design
    padding: 0

    contentItem: SharedAddressesPanel {
        id: panel
        isEditMode: root.isEditMode
        communityName: root.communityName
        communityIcon: root.communityIcon
        loginType: root.loginType
        walletAccountsModel: root.walletAccountsModel
        permissionsModel: root.permissionsModel
        assetsModel: root.assetsModel
        collectiblesModel: root.collectiblesModel
        onShareSelectedAddressesClicked: root.shareSelectedAddressesClicked(airdropAddress, sharedAddresses)
        onClose: root.close()
    }

    footer: StatusDialogFooter {
        spacing: Style.current.padding
        rightButtons: panel.buttons
    }
}
