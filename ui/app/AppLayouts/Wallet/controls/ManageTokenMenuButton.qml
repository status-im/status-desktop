import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1

StatusFlatButton {
    id: root

    property int currentIndex
    property int count

    property bool inHidden
    property bool isGroup
    property string groupId
    property bool isCommunityAsset
    property bool isCollectible

    readonly property bool hideEnabled: model.symbol !== "ETH"
    readonly property bool menuVisible: menuLoader.active

    signal moveRequested(int from, int to)
    signal showHideRequested(int index, bool flag)
    signal showHideGroupRequested(string groupId, bool flag)

    icon.name: "more"
    horizontalPadding: 4
    verticalPadding: 4
    textColor: hovered || highlighted ? Theme.palette.directColor1 : Theme.palette.baseColor1
    highlighted: menuLoader.item && menuLoader.item.opened

    onClicked: {
        menuLoader.active = true
        menuLoader.item.popup(width - menuLoader.item.width, height)
    }

    Loader {
        id: menuLoader
        objectName: "manageTokensContextMenuLoader"
        active: false
        sourceComponent: StatusMenu {
            onClosed: menuLoader.active = false

            StatusAction {
                objectName: "miMoveToTop"
                enabled: !root.inHidden && root.currentIndex !== 0
                icon.name: "arrow-top"
                text: qsTr("Move to top")
                onTriggered: root.moveRequested(root.currentIndex, 0)
            }
            StatusAction {
                objectName: "miMoveUp"
                enabled: !root.inHidden && root.currentIndex !== 0
                icon.name: "arrow-up"
                text: qsTr("Move up")
                onTriggered: root.moveRequested(root.currentIndex, root.currentIndex - 1)
            }
            StatusAction {
                objectName: "miMoveDown"
                enabled: !root.inHidden && root.currentIndex < root.count - 1
                icon.name: "arrow-down"
                text: qsTr("Move down")
                onTriggered: root.moveRequested(root.currentIndex, root.currentIndex + 1)
            }
            StatusAction {
                objectName: "miMoveToBottom"
                enabled: !root.inHidden && root.currentIndex < root.count - 1
                icon.name: "arrow-bottom"
                text: qsTr("Move to bottom")
                onTriggered: root.moveRequested(root.currentIndex, root.count - 1)
            }

            StatusMenuSeparator { enabled: !root.inHidden && root.hideEnabled }

            // any token
            StatusAction {
                objectName: "miHideToken"
                enabled: !root.inHidden && root.hideEnabled && !root.isGroup && !root.isCommunityAsset
                type: StatusAction.Type.Danger
                icon.name: "hide"
                text: root.isCollectible ? qsTr("Hide collectible") : qsTr("Hide asset")
                onTriggered: root.showHideRequested(root.currentIndex, false)
            }
            StatusAction {
                objectName: "miShowToken"
                enabled: root.inHidden
                icon.name: "show"
                text: root.isCollectible ? qsTr("Show collectible") : qsTr("Show asset")
                onTriggered: root.showHideRequested(root.currentIndex, true)
            }

            // (hide) community tokens
            StatusMenu {
                id: communitySubmenu
                enabled: !root.inHidden && root.isCommunityAsset
                title: qsTr("Hide")
                assetSettings.name: "hide"
                type: StatusAction.Type.Danger

                StatusAction {
                    objectName: "miHideCommunityToken"
                    text: root.isCollectible ? qsTr("This collectible") : qsTr("This asset")
                    onTriggered: {
                        root.showHideRequested(root.currentIndex, false)
                        communitySubmenu.dismiss()
                    }
                }
                StatusAction {
                    objectName: "miHideAllCommunityTokens"
                    text: root.isCollectible ? qsTr("All collectibles from this community") : qsTr("All assets from this community")
                    onTriggered: {
                        root.showHideGroupRequested(root.groupId, false)
                        communitySubmenu.dismiss()
                    }
                }
            }

            // token group
            StatusAction {
                objectName: "miHideTokenGroup"
                enabled: !root.inHidden && root.isGroup
                type: StatusAction.Type.Danger
                icon.name: "hide"
                text: root.isCollectible ? qsTr("Hide all collectibles from this community") : qsTr("Hide all assets from this community")
                onTriggered: root.showHideGroupRequested(root.groupId, false)
            }
            StatusAction {
                objectName: "miShowTokenGroup"
                enabled: root.inHidden && root.groupId
                icon.name: "show"
                text: root.isCollectible ? qsTr("Show all collectibles from this community") : qsTr("Show all assets from this community")
                onTriggered: root.showHideGroupRequested(root.groupId, true)
            }
        }
    }
}
