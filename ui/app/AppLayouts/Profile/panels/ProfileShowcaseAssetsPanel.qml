import QtQuick 2.15

import utils 1.0

import AppLayouts.Profile.controls 1.0

ProfileShowcasePanel {
    id: root

    property var formatCurrencyAmount: function(amount, symbol){}

    keyRole: "symbol"
    roleNames: ["symbol", "name", "enabledNetworkBalance", "decimals"].concat(showcaseRoles)
    filterFunc: (modelData) => modelData.symbol !== "" && !showcaseModel.hasItemInShowcase(modelData.symbol)
    hiddenPlaceholderBanner: qsTr("Assets here will show on your profile")
    showcasePlaceholderBanner: qsTr("Assets here will be hidden from your profile")

    draggableDelegateComponent: AssetShowcaseDelegate {
        Drag.keys: ["x-status-draggable-showcase-item-hidden"]
        showcaseObj: modelData
        dragParent: dragParentData
        visualIndex: visualIndexData
        formatCurrencyAmount: function(amount, symbol) {
            return root.formatCurrencyAmount(amount, symbol)
        }
        onShowcaseVisibilityRequested: {
            var tmpObj = Object()
            root.roleNames.forEach(role => tmpObj[role] = showcaseObj[role])
            tmpObj.showcaseVisibility = value
            showcaseModel.upsertItemJson(JSON.stringify(tmpObj))
            root.showcaseEntryChanged()
        }
    }
    showcaseDraggableDelegateComponent: AssetShowcaseDelegate {
        Drag.keys: ["x-status-draggable-showcase-item"]
        showcaseObj: modelData
        dragParent: dragParentData
        visualIndex: visualIndexData
        dragAxis: Drag.YAxis
        showcaseVisibility: !!modelData ? modelData.showcaseVisibility : Constants.ShowcaseVisibility.NoOne
        onShowcaseVisibilityRequested: {
            showcaseModel.setVisibility(showcaseObj.symbol, value)
            root.showcaseEntryChanged()
        }
    }
}
