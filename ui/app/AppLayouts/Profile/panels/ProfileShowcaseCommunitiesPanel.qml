import QtQuick 2.15

import utils 1.0

import AppLayouts.Profile.controls 1.0

ProfileShowcasePanel {
    id: root

    keyRole: "id"
    roleNames: ["id", "name", "memberRole", "image", "color", "showcaseVisibility"]
    filterFunc: (modelData) => !showcaseModel.hasItem(modelData.id)
    hiddenPlaceholderBanner: qsTr("Communities here will show on your profile")
    showcasePlaceholderBanner: qsTr("Communities here will be hidden from your profile")

    draggableDelegateComponent: CommunityShowcaseDelegate {
        Drag.keys: ["x-status-draggable-showcase-item-hidden"]
        showcaseObj: modelData
        dragParent: dragParentData
        visualIndex: visualIndexData
        onShowcaseVisibilityRequested: {
            var tmpObj = Object()
            root.roleNames.forEach(role => tmpObj[role] = showcaseObj[role])
            tmpObj.showcaseVisibility = value
            showcaseModel.append(tmpObj)
            showcaseVisibility = Constants.ShowcaseVisibility.NoOne // reset
            root.showcaseEntryChanged(tmpObj.id, tmpObj.showcaseVisibility)
        }
    }
    showcaseDraggableDelegateComponent: CommunityShowcaseDelegate {
        Drag.keys: ["x-status-draggable-showcase-item"]
        showcaseObj: modelData
        dragParent: dragParentData
        visualIndex: visualIndexData
        dragAxis: Drag.YAxis
        showcaseVisibility: !!modelData ? modelData.showcaseVisibility : Constants.ShowcaseVisibility.NoOne
        onShowcaseVisibilityRequested: {
            if (value === Constants.ShowcaseVisibility.NoOne) {
                showcaseModel.remove(visualIndex)
            } else {
                showcaseModel.setProperty(visualIndex, "showcaseVisibility", value)
            }
            root.showcaseEntryChanged(modelData.id, value)
        }
    }
}
