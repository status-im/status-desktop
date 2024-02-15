import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared.panels 1.0

import AppLayouts.Profile.controls 1.0

ProfileShowcasePanel {
    id: root

    required property bool addAccountsButtonVisible

    signal navigateToAccountsTab()

    keyRole: "uid"
    roleNames: ["uid", "chainId", "tokenId", "contractAddress", "communityId", "name", "collectionName", "backgroundColor", "imageUrl"].concat(showcaseRoles)
    filterFunc: (modelData) => !showcaseModel.hasItemInShowcase(modelData.uid)
    emptyInShowcasePlaceholderText: qsTr("Collectibles here will show on your profile")
    emptyHiddenPlaceholderText: qsTr("Collectibles here will be hidden from your profile")

    hiddenDraggableDelegateComponent: CollectibleShowcaseDelegate {
        Drag.keys: ["x-status-draggable-showcase-item-hidden"]
        showcaseObj: modelData
        dragParent: dragParentData
        visualIndex: visualIndexData
        onShowcaseVisibilityRequested: {
            var tmpObj = Object()
            root.roleNames.forEach(role => tmpObj[role] = showcaseObj[role])
            tmpObj.showcaseVisibility = value
            showcaseModel.upsertItemJson(JSON.stringify(tmpObj))
            root.showcaseEntryChanged()
        }
    }
    showcaseDraggableDelegateComponent: CollectibleShowcaseDelegate {
        Drag.keys: ["x-status-draggable-showcase-item"]
        showcaseObj: modelData
        dragParent: dragParentData
        visualIndex: visualIndexData
        dragAxis: Drag.YAxis
        showcaseVisibility: !!modelData ? modelData.showcaseVisibility : Constants.ShowcaseVisibility.NoOne
        onShowcaseVisibilityRequested: {
            showcaseModel.setVisibility(showcaseObj.uid, value)
            root.showcaseEntryChanged()
        }
    }

// TODO: Issue #13590
//    additionalComponent: root.addAccountsButtonVisible ? addMoreAccountsComponent : null

//    Component {
//        id: addMoreAccountsComponent

//        AddMoreAccountsLink {
//             visible: root.addAccountsButtonVisible
//             text: qsTr("Don’t see some of your collectibles?")
//             onClicked: root.navigateToAccountsTab()
//        }
//    }
}
