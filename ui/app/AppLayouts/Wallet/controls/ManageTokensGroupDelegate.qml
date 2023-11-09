import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

DropArea {
    id: root
    objectName: "manageTokensGroupDelegate-%1".arg(index)

    // expected roles: communityId, communityName, communityImage

    property int visualIndex: index
    property var controller
    property bool communityGroupsExpanded
    property var dragParent
    property alias dragEnabled: groupedCommunityTokenDelegate.dragEnabled
    property bool isCollectible

    readonly property string communityId: model.communityId
    readonly property int childCount: model.enabledNetworkBalance // NB using "balance" as "count" in m_communityTokenGroupsModel
    readonly property alias title: groupedCommunityTokenDelegate.title

    ListView.onRemove: SequentialAnimation {
        PropertyAction { target: root; property: "ListView.delayRemove"; value: true }
        NumberAnimation { target: root; property: "scale"; to: 0; easing.type: Easing.InOutQuad }
        PropertyAction { target: root; property: "ListView.delayRemove"; value: false }
    }

    keys: ["x-status-draggable-community-group-item"]
    width: ListView.view.width
    height: groupedCommunityTokenDelegate.implicitHeight

    onEntered: function(drag) {
        const from = drag.source.visualIndex
        const to = groupedCommunityTokenDelegate.visualIndex
        if (to === from)
            return
        ListView.view.model.moveItem(from, to)
        drag.accept()
    }

    StatusDraggableListItem {
        id: groupedCommunityTokenDelegate
        width: parent.width
        height: dragActive ? implicitHeight : parent.height
        leftPadding: Style.current.halfPadding
        rightPadding: Style.current.halfPadding
        bottomPadding: Style.current.halfPadding
        topPadding: 22
        draggable: true
        spacing: 12
        bgColor: Theme.palette.baseColor4
        title: model.communityName

        visualIndex: index
        dragParent: root.dragParent
        Drag.keys: root.keys
        Drag.hotSpot.x: root.width/2
        Drag.hotSpot.y: root.height/2

        contentItem: ColumnLayout {
            spacing: 0

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 12
                Layout.rightMargin: 12
                Layout.bottomMargin: 14
                spacing: groupedCommunityTokenDelegate.spacing

                StatusIcon {
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: 20
                    icon: "justify"
                    color: root.dragEnabled ? Theme.palette.baseColor1 : Theme.palette.baseColor2
                }

                StatusRoundedImage {
                    //radius: groupedCommunityTokenDelegate.bgRadius // TODO different for a collection
                    Layout.preferredWidth: root.isCollectible ? 44 : 32
                    Layout.preferredHeight: root.isCollectible ? 44 : 32
                    image.source: model.communityImage
                    showLoadingIndicator: true
                    image.fillMode: Image.PreserveAspectCrop
                }

                StatusBaseText {
                    text: groupedCommunityTokenDelegate.title
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    font.weight: Font.Medium
                }

                StatusBaseText {
                    Layout.leftMargin: -parent.spacing/2
                    text: "• %1".arg(root.isCollectible ? qsTr("%n collectible(s)", "", root.childCount) : qsTr("%n asset(s)", "", root.childCount))
                    elide: Text.ElideRight
                    color: Theme.palette.baseColor1
                    maximumLineCount: 1
                    visible: !root.communityGroupsExpanded
                }

                Item { Layout.fillWidth: true }

                ManageTokenMenuButton {
                    objectName: "btnManageTokenMenu-%1".arg(currentIndex)
                    currentIndex: visualIndex
                    count: root.controller.communityTokenGroupsModel.count
                    isGroup: true
                    isCollectible: root.isCollectible
                    groupId: model.communityId
                    onMoveRequested: (from, to) => root.controller.communityTokenGroupsModel.moveItem(from, to) // TODO collection
                    onShowHideGroupRequested: (groupId, flag) => root.controller.showHideGroup(groupId, flag)
                }
            }

            StatusListView {
                objectName: "manageTokensGroupListView"
                Layout.fillWidth: true
                Layout.preferredHeight: contentHeight
                model: root.controller.communityTokensModel
                interactive: false
                visible: root.communityGroupsExpanded

                displaced: Transition {
                    NumberAnimation { properties: "x,y"; easing.type: Easing.OutQuad }
                }

                delegate: ManageTokensDelegate {
                    controller: root.controller
                    dragParent: root.dragParent
                    isGrouped: true
                    count: root.childCount
                    dragEnabled: count > 1
                    keys: ["x-status-draggable-community-token-item-%1".arg(model.communityId)]
                    bgColor: Theme.palette.indirectColor4
                    topInset: 2 // tighter "spacing"
                    bottomInset: 2
                    visible: root.communityId === model.communityId
                    isCollectible: root.isCollectible
                }
            }
        }
    }
}
