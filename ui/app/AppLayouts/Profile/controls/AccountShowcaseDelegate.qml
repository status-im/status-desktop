import QtQuick 2.15

import StatusQ.Core.Theme 0.1

import AppLayouts.Wallet 1.0

import utils 1.0

ShowcaseDelegate {
    title: !!showcaseObj && !!showcaseObj.name ? showcaseObj.name : ""
    secondaryTitle: WalletUtils.addressToDisplay(!!showcaseObj && !!showcaseObj.address ? showcaseObj.address : "", "", true, containsMouse)
    hasEmoji: !!showcaseObj && !!showcaseObj.emoji
    hasIcon: !hasEmoji
    icon.name: hasEmoji ? showcaseObj.emoji : "filled-account"
    icon.color: !!showcaseObj && showcaseObj.colorId ? Utils.getColorForId(showcaseObj.colorId) : Theme.palette.primaryColor3
}
