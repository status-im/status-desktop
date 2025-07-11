import QtQuick

import utils

import AppLayouts.Profile.controls
import AppLayouts.Wallet

import StatusQ.Core.Theme

import StatusQ

ProfileShowcasePanel {
    id: root

    property string currentWallet

    emptyInShowcasePlaceholderText: qsTr("Accounts here will show on your profile")
    emptyHiddenPlaceholderText: qsTr("Accounts here will be hidden from your profile")
    emptySearchPlaceholderText: qsTr("No accounts matching search")
    searchPlaceholderText: qsTr("Search account name or address")
    delegate: ProfileShowcasePanelDelegate {
        title: model ? model.name : ""
        secondaryTitle: WalletUtils.addressToDisplay(model ? model.address ?? "" : "",
                                                     true,
                                                     containsMouse)
        hasEmoji: model && !!model.emoji
        hasIcon: !hasEmoji
        icon.name: hasEmoji ? model.emoji : "filled-account"
        icon.color: model && model.colorId ? Utils.getColorForId(model.colorId) : Theme.palette.primaryColor3
        highlighted: model ? model.address === root.currentWallet : false
    }
    filter: FastExpressionFilter {
        readonly property string lowerCaseSearchText: root.searcherText.toLowerCase()
        expression: {
            lowerCaseSearchText
            return (address.toLowerCase().includes(lowerCaseSearchText) ||
                    name.toLowerCase().includes(lowerCaseSearchText))
        }
        expectedRoles: ["address", "name"]
    }
}
