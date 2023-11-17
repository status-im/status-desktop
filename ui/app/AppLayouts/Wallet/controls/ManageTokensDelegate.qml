import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

DropArea {
    id: root
    objectName: "manageTokensDelegate-%1".arg(index)

    // expected roles: symbol, name, communityId, communityName, communityImage, collectionName, imageUrl
    // + enabledNetworkBalance, enabledNetworkCurrencyBalance -> TODO might get dropped/renamed in the future!!!

    property var controller
    property int visualIndex: index
    property alias dragParent: delegate.dragParent
    property alias dragEnabled: delegate.dragEnabled
    property alias bgColor: delegate.bgColor
    property alias topInset: delegate.topInset
    property alias bottomInset: delegate.bottomInset
    property bool isGrouped
    property bool isHidden
    property int count

    property bool isCollectible

    readonly property alias title: delegate.title

    readonly property var priv: QtObject {
        id: priv
        readonly property int iconSize: root.isCollectible ? 44 : 32
        readonly property int bgRadius: root.isCollectible ? Style.current.radius : iconSize/2
    }

    ListView.onRemove: SequentialAnimation {
        PropertyAction { target: root; property: "ListView.delayRemove"; value: true }
        NumberAnimation { target: root; property: "scale"; to: 0; easing.type: Easing.InOutQuad }
        PropertyAction { target: root; property: "ListView.delayRemove"; value: false }
    }

    width: ListView.view.width
    height: visible ? delegate.height : 0

    onEntered: function(drag) {
        const from = drag.source.visualIndex
        const to = delegate.visualIndex
        if (to === from)
            return
        ListView.view.model.moveItem(from, to)
        drag.accept()
    }

    StatusDraggableListItem {
        id: delegate
        objectName: "draggableDelegate"

        visualIndex: index
        Drag.keys: root.keys
        Drag.hotSpot.x: root.width/2
        Drag.hotSpot.y: root.height/2
        draggable: true

        width: root.width
        title: model.name
        secondaryTitle: root.isCollectible ? (!!model.communityId ? qsTr("Community minted") : model.collectionName || model.symbol) :
                                             hovered || menuBtn.menuVisible ? "%1 • %2".arg(LocaleUtils.currencyAmountToLocaleString(model.enabledNetworkBalance))
                                                                              .arg(LocaleUtils.currencyAmountToLocaleString(model.enabledNetworkCurrencyBalance))
                                                                            : LocaleUtils.currencyAmountToLocaleString(model.enabledNetworkBalance)
        bgRadius: priv.bgRadius
        hasImage: true
        icon.source: root.isCollectible ? model.imageUrl : Constants.tokenIcon(model.symbol) // TODO unify via backend model for both assets and collectibles; handle communityPrivilegesLevel
        icon.width: priv.iconSize
        icon.height: priv.iconSize
        spacing: 12
        assetBgColor: model.backgroundColor

        actions: [
            ManageTokensCommunityTag {
                visible: !!model.communityId && !root.isGrouped
                text: model.communityName
                imageSrc: model.communityImage
            },
            ManageTokenMenuButton {
                id: menuBtn
                objectName: "btnManageTokenMenu-%1".arg(currentIndex)
                currentIndex: root.visualIndex
                count: root.count
                inHidden: root.isHidden
                groupId: model.communityId
                isCommunityAsset: !!model.communityId
                isCollectible: root.isCollectible
                onMoveRequested: (from, to) => root.ListView.view.model.moveItem(from, to)
                onShowHideRequested: (index, flag) => isCommunityAsset ? root.controller.showHideCommunityToken(index, flag)
                                                                       : root.controller.showHideRegularToken(index, flag)
                onShowHideGroupRequested: (groupId, flag) => root.controller.showHideGroup(groupId, flag)
            }
        ]
    }
}
