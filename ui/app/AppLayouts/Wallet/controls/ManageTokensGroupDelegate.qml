import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ
import StatusQ.Core
import StatusQ.Components
import StatusQ.Controls
import StatusQ.Core.Theme
import StatusQ.Core.Utils as StatusQUtils

import shared.controls
import utils

DropArea {
    id: root
    objectName: "manageTokensGroupDelegate-%1".arg(index)

    // expected roles: communityId, communityName, communityImage, collectionUid, collectionName, imageUrl // FIXME unify group image

    property int visualIndex: index
    property var controller
    property var dragParent
    property alias dragEnabled: groupedCommunityTokenDelegate.dragEnabled
    property bool isCollectible: isCollection
    property bool isCollection
    property bool isHidden // inside the "Hidden" section

    readonly property string groupId: isCollection ? model.collectionUid : model.communityId
    readonly property string groupImage: !!model ? model.communityImage || model.imageUrl : ""
    readonly property int childCount: model.enabledNetworkBalance // NB using "balance" as "count" in the grouped model
    readonly property alias title: titleText.text

    readonly property bool unknownCommunityName: model.communityName.startsWith("0x") && model.communityName === model.communityId
    
    ListView.onRemove: SequentialAnimation {
        PropertyAction { target: root; property: "ListView.delayRemove"; value: true }
        NumberAnimation { target: root; property: "scale"; to: 0; easing.type: Easing.InOutQuad }
        PropertyAction { target: root; property: "ListView.delayRemove"; value: false }
    }

    keys: isCollection ? ["x-status-draggable-collection-group-item"] : ["x-status-draggable-community-group-item"]
    width: ListView.view ? ListView.view.width : 0
    height: groupedCommunityTokenDelegate.implicitHeight

    onEntered: function(drag) {
        const from = drag.source.visualIndex
        const to = groupedCommunityTokenDelegate.visualIndex
        if (to === from)
            return
        ListView.view.model.moveItem(from, to)
        drag.accept()
    }

    QtObject {
        id: d
        readonly property int iconSize: root.isCollectible ? 44 : 32
    }

    StatusDraggableListItem {
        id: groupedCommunityTokenDelegate
        width: parent.width
        height: dragActive ? implicitHeight : parent.height
        draggable: true
        spacing: 12
        bgColor: Theme.palette.baseColor4

        visualIndex: index
        dragParent: root.dragParent
        Drag.keys: root.keys
        Drag.hotSpot.x: root.width/2
        Drag.hotSpot.y: root.height/2

        contentItem: RowLayout {
            spacing: groupedCommunityTokenDelegate.spacing

            StatusIcon {
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                icon: "justify"
                color: root.dragEnabled ? Theme.palette.baseColor1 : Theme.palette.baseColor2
            }

            StatusRoundIcon {
                Layout.preferredWidth: d.iconSize
                Layout.preferredHeight: d.iconSize
                radius: root.isCollection ? Theme.radius : height/2
                visible: root.unknownCommunityName || !root.groupImage
                asset.name: root.unknownCommunityName ? "help" : root.isCollection ? "gallery" : "group"
                asset.color: root.unknownCommunityName ? Theme.palette.directColor1 : "black"
                asset.bgColor: root.unknownCommunityName ? Theme.palette.primaryColor3 : model.backgroundColor
            }

            StatusRoundedImage {
                visible: !!root.groupImage
                radius: root.isCollection ? Theme.radius : height/2
                Layout.preferredWidth: d.iconSize
                Layout.preferredHeight: d.iconSize

                image.source: root.groupImage
                showLoadingIndicator: true
                image.fillMode: Image.PreserveAspectCrop
            }

            Row {
                id: communityNameRow
                spacing: 2
                Layout.fillWidth: true

                StatusBaseText {
                    id: titleText
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.min(implicitWidth, parent.width - copyButton.width)
                    text: {
                        if (root.isCollection) {
                            return model.collectionName
                        }

                        if (root.unknownCommunityName) {
                            if (communityNameArea.hovered) {
                                return qsTr("Community %1").arg(model.communityName)
                            }
                            return qsTr("Unknown community")
                        }

                        return model.communityName
                    }
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    font.weight: Font.Medium

                    StatusToolTip {
                        text: qsTr("Community name could not be fetched")
                        visible: root.unknownCommunityName && communityNameArea.hovered
                    }
                }

                CopyToClipBoardButton {
                    id: copyButton
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.unknownCommunityName && communityNameArea.hovered
                    icon.height: Theme.primaryTextFontSize
                    icon.width: Theme.primaryTextFontSize
                    icon.color: Theme.palette.directColor1
                    color: Theme.palette.transparent
                    textToCopy: model.communityName
                    onCopyClicked: ClipboardUtils.setText(textToCopy)
                }

                HoverHandler {
                    id: communityNameArea
                }
            }

            ManageTokensCommunityTag {
                communityName: root.childCount
                communityId: ""
                asset.name: root.isCollectible ? "image" : "token"
                asset.isImage: false
                asset.color: Theme.palette.baseColor1
                loading: false
                enabled: false
            }

            ManageTokenMenuButton {
                objectName: "btnManageTokenMenu-%1".arg(currentIndex)
                currentIndex: visualIndex
                count: root.isCollection ? root.controller.collectionGroupsModel.count :
                                           root.controller.communityTokenGroupsModel.count
                isGroup: true
                isCollection: root.isCollection
                isCollectible: root.isCollectible
                groupId: root.groupId
                inHidden: root.isHidden
                onMoveRequested: (from, to) => root.ListView.view.model.moveItem(from, to)
                onShowHideGroupRequested: function(groupId, flag) {
                    if (root.isCollection)
                        root.controller.showHideCollectionGroup(groupId, flag)
                    else
                        root.controller.showHideGroup(groupId, flag)
                }
            }
        }
    }
}
