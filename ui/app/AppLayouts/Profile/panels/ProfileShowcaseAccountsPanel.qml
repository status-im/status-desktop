import QtQuick 2.15

import utils 1.0

import AppLayouts.Profile.controls 1.0

ProfileShowcasePanel {
    id: root

    property string currentWallet

    settingsKey: "accounts"
    keyRole: "address"
    roleNames: ["name", "address", "walletType", "emoji", "colorId"]
    filterFunc: (modelData) => modelData.walletType !== Constants.keyWalletType && !showcaseModel.hasItem(modelData.address)
    hiddenPlaceholderBanner: qsTr("Accounts here will show on your profile")
    showcasePlaceholderBanner: qsTr("Accounts here will be hidden from your profile")

    draggableDelegateComponent: AccountShowcaseDelegate {
        Drag.keys: ["x-status-draggable-showcase-item-hidden"]
        showcaseObj: modelData
        dragParent: dragParentData
        visualIndex: visualIndexData
        highlighted: !!modelData && modelData.address === root.currentWallet
        onShowcaseVisibilityRequested: {
            var tmpObj = Object()
            root.roleNames.forEach(role => tmpObj[role] = showcaseObj[role])
            tmpObj.showcaseVisibility = value
            showcaseModel.append(tmpObj)
            showcaseVisibility = Constants.ShowcaseVisibility.NoOne // reset
        }
    }
    showcaseDraggableDelegateComponent: AccountShowcaseDelegate {
        Drag.keys: ["x-status-draggable-showcase-item"]
        showcaseObj: modelData
        dragParent: dragParentData
        visualIndex: visualIndexData
        highlighted: !!modelData && modelData.address === root.currentWallet
        dragAxis: Drag.YAxis
        showcaseVisibility: !!modelData ? modelData.showcaseVisibility : Constants.ShowcaseVisibility.NoOne
        onShowcaseVisibilityRequested: {
            if (value === Constants.ShowcaseVisibility.NoOne) {
                showcaseModel.remove(visualIndex)
            } else {
                showcaseModel.setProperty(visualIndex, "showcaseVisibility", value)
            }
        }
    }
}
