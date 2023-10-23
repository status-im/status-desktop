import QtQuick 2.15

import utils 1.0

import AppLayouts.Profile.controls 1.0

ProfileShowcasePanel {
    id: root

    keyRole: "symbol"
    roleNames: ["symbol", "name", "enabledNetworkBalance"].concat(showcaseRoles)
    filterFunc: (modelData) => !showcaseModel.hasItem(modelData.symbol)
    hiddenPlaceholderBanner: qsTr("Assets here will show on your profile")
    showcasePlaceholderBanner: qsTr("Assets here will be hidden from your profile")

    draggableDelegateComponent: AssetShowcaseDelegate {
        Drag.keys: ["x-status-draggable-showcase-item-hidden"]
        showcaseObj: modelData
        dragParent: dragParentData
        visualIndex: visualIndexData
        onShowcaseVisibilityRequested: {
            var tmpObj = Object()
            root.roleNames.forEach(role => tmpObj[role] = showcaseObj[role])
            tmpObj.showcaseVisibility = value
            showcaseModel.append(JSON.stringify(tmpObj))
            showcaseVisibility = Constants.ShowcaseVisibility.NoOne // reset
            root.updateModelsAfterChange()
            root.showcaseEntryChanged()
        }

        readonly property Connections showcaseUpdateConnections: Connections {
            target: root

            function onUpdateEntry(entry) {
                if (modelData && entry.id === modelData.symbol) {
                    root.updateShowcaseEntryPreferences(modelData, entry)
                }
            }
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
            if (value === Constants.ShowcaseVisibility.NoOne) {
                showcaseModel.remove(visualIndex)
            } else {
                showcaseModel.setVisibility(showcaseObj.symbol, value)
            }
            root.updateModelsAfterChange()
            root.showcaseEntryChanged()
        }
    }
}
