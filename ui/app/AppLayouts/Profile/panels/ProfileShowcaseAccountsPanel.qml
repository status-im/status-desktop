import QtQuick 2.15

import utils 1.0

import AppLayouts.Profile.controls 1.0
import AppLayouts.Wallet 1.0

import StatusQ.Core.Theme 0.1

ProfileShowcasePanel {
    id: root

    property string currentWallet

    emptyInShowcasePlaceholderText: qsTr("Accounts here will show on your profile")
    emptyHiddenPlaceholderText: qsTr("Accounts here will be hidden from your profile")

    delegate: ProfileShowcasePanelDelegate {
        title: model ? model.name : ""
        secondaryTitle: WalletUtils.addressToDisplay(model ? model.key : "", "", true, containsMouse)
        hasEmoji: model && !!model.emoji
        hasIcon: !hasEmoji
        icon.name: hasEmoji ? model.emoji : "filled-account"
        icon.color: model && model.colorId ? Utils.getColorForId(model.colorId) : Theme.palette.primaryColor3
        highlighted: model ? model.key === root.currentWallet : false
    }
}
