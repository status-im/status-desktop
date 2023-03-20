import QtQuick 2.15
import QtQuick.Controls 2.15 as QC

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

Item {
    id: root

    implicitWidth: statusChatListItems.width
    implicitHeight: statusChatListItems.contentHeight

    property string categoryId: ""
    property var model: null
    property bool draggableItems: false
    property bool highlightItem: true
    property bool showCategoryActionButtons: false

    property alias statusChatListItems: statusChatListItems

    property Component popupMenu
    property Component categoryPopupMenu

    property var isEnsVerified: function(pubKey) { return false }

    signal chatItemSelected(string categoryId, string id)
    signal chatItemUnmuted(string id)
    signal categoryReordered(string categoryId, int to)
    signal chatItemReordered(string categoryId, string chatId, int to)
    signal categoryAddButtonClicked(string id)

    StatusListView {
        id: statusChatListItems
        width: 288
        height: root.height
        objectName: "chatListItems"
        model: root.model
        spacing: 0
        interactive: height !== contentHeight

        delegate: DropArea {
            id: chatListDelegate
            objectName: model.name
            width: model.isCategory ? statusChatListCategoryItem.width : statusChatListItem.width
            height: model.isCategory ? statusChatListCategoryItem.height : statusChatListItem.height
            keys: ["x-status-draggable-chat-list-item-and-categories"]

            property int visualIndex: index
            property string chatId: model.itemId
            property string categoryId: model.categoryId
            property string isCategory: model.isCategory
            property Item item: isCategory ? draggableItem.actions[0] : draggableItem.actions[1]

            onEntered: function(drag) {
                drag.accept();
                statusChatListCategoryItem.highlighted = true;
                statusChatListItem.highlighted = true;
            }
            onExited: {
                statusChatListCategoryItem.highlighted = false;
                statusChatListItem.highlighted = false;
            }

            onDropped: function(drop) {
                const from = drop.source.visualIndex;
                const to = chatListDelegate.visualIndex;
                if (to === from)
                    return;
                if (!model.isCategory) {
                    root.chatItemReordered(statusChatListItems.itemAtIndex(from).categoryId, statusChatListItems.itemAtIndex(from).chatId, to);
                } else {
                    root.categoryReordered(statusChatListItems.itemAtIndex(from).categoryId, to);
                }
            }

            StatusDraggableListItem {
                id: draggableItem
                width: parent.width
                height: visible ? implicitHeight : 0
                dragParent: root.draggableItems ? statusChatListItems : null
                visualIndex: chatListDelegate.visualIndex
                draggable: (root.draggableItems && (statusChatListItems.count > 1))
                horizontalPadding: 0
                verticalPadding: 0
                icon.width: 0
                icon.height: 0
                spacing: 0
                topInset: 0
                bottomInset: 0
                customizable: true
                Drag.keys: chatListDelegate.keys
                onClicked: {
                    if (model.isCategory) {
                        statusChatListCategoryItem.clicked(mouse);
                    } else {
                        statusChatListItem.clicked(mouse);
                    }
                }

                actions: [
                   StatusChatListCategoryItem {
                        id: statusChatListCategoryItem
                        objectName: "categoryItem"
                        visible: model.isCategory

                        function setupPopup() {
                            categoryPopupMenuSlot.item.categoryItem = model
                        }
                        Connections {
                            enabled: categoryPopupMenuSlot.active && statusChatListCategoryItem.highlighted
                            target: categoryPopupMenuSlot.item
                            function onClosed() {
                                statusChatListCategoryItem.highlighted = false
                                statusChatListCategoryItem.menuButton.highlighted = false
                            }
                        }
                        text: model.name
                        opened: model.categoryOpened
                        highlighted: draggableItem.dragActive
                        showAddButton: showCategoryActionButtons
                        showMenuButton: !!root.onPopupMenuChanged
                        hasUnreadMessages: model.hasUnreadMessages
                        onClicked: {
                            if (mouse.button === Qt.RightButton && showCategoryActionButtons && !!root.categoryPopupMenu) {
                                statusChatListCategoryItem.setupPopup()
                                highlighted = true;
                                categoryPopupMenuSlot.item.popup()
                            } else if (mouse.button === Qt.LeftButton) {
                                root.model.sourceModel.changeCategoryOpened(model.categoryId, !statusChatListCategoryItem.opened)
                            }
                        }
                        onToggleButtonClicked: root.model.sourceModel.changeCategoryOpened(model.categoryId, !statusChatListCategoryItem.opened)
                        onMenuButtonClicked: {
                            statusChatListCategoryItem.setupPopup()
                            highlighted = true
                            menuButton.highlighted = true
                            categoryPopupMenuSlot.item.popup()
                        }
                        onAddButtonClicked: {
                            root.categoryAddButtonClicked(categoryId)
                        }
                    },
                    StatusChatListItem {
                        id: statusChatListItem
                        objectName: model.name
                        width: root.width
                        height: visible ? (statusChatListItem.implicitHeight + 4) /*spacing between non-collapsed items*/ : 0
                        visible: (!model.isCategory && model.categoryOpened)
                        originalOrder: model.position
                        chatId: model.itemId
                        categoryId: model.categoryId
                        name: model.name
                        type: model.type ?? StatusChatListItem.Type.CommunityChat
                        muted: model.muted
                        hasUnreadMessages: model.hasUnreadMessages
                        notificationsCount: model.notificationsCount
                        highlightWhenCreated: !!model.highlight
                        selected: (model.active && root.highlightItem)
                        asset.emoji: !!model.emoji ? model.emoji : ""
                        asset.color: !!model.color ? model.color : Theme.palette.userCustomizationColors[model.colorId]
                        asset.isImage: model.icon.includes("data")
                        asset.name: model.icon
                        ringSettings.ringSpecModel: type === StatusChatListItem.Type.OneToOneChat && root.isEnsVerified(chatId) ? undefined : model.colorHash
                        onlineStatus: !!model.onlineStatus ? model.onlineStatus : StatusChatListItem.OnlineStatus.Inactive
                        sensor.enabled: draggableItem.dragActive
                        dragged: draggableItem.dragActive
                        onClicked: {
                            highlightWhenCreated = false

                            if (mouse.button === Qt.RightButton && !!root.popupMenu) {
                                statusChatListItem.highlighted = true

                                const originalOpenHandler = popupMenuSlot.item.openHandler
                                const originalCloseHandler = popupMenuSlot.item.closeHandler

                                popupMenuSlot.item.openHandler = function () {
                                    if (!!originalOpenHandler) {
                                        originalOpenHandler(statusChatListItem.chatId)
                                    }
                                }

                                popupMenuSlot.item.closeHandler = function () {
                                    if (statusChatListItem) {
                                        statusChatListItem.highlighted = false
                                    }
                                    if (!!originalCloseHandler) {
                                        originalCloseHandler()
                                    }
                                }

                                const p = statusChatListItem.mapToItem(root, mouse.x, mouse.y)

                                popupMenuSlot.item.popup(p.x + 4, p.y + 6)
                                popupMenuSlot.item.openHandler = originalOpenHandler
                                return
                            }
                            if (!statusChatListItem.selected) {
                                root.chatItemSelected(statusChatListItem.categoryId, statusChatListItem.chatId)
                            }
                        }

                        onUnmute: root.chatItemUnmuted(statusChatListItem.chatId)
                    }
                ]
            }
        }
    }

    onPopupMenuChanged: {
        if (!!popupMenu) {
            popupMenuSlot.sourceComponent = popupMenu
        }
    }

    onCategoryPopupMenuChanged: {
        if (!!categoryPopupMenu) {
            categoryPopupMenuSlot.sourceComponent = categoryPopupMenu
        }
    }

    QtObject {
        id: d
        property int destinationPosition: -1
    }

    Loader {
        id: popupMenuSlot
        active: !!root.popupMenu
    }

    Loader {
        id: categoryPopupMenuSlot
        active: !!root.categoryPopupMenu
    }
}
