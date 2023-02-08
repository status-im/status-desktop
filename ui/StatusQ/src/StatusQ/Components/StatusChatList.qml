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
    signal chatItemReordered(string id, int from, int to)
    signal categoryAddButtonClicked(string id)

    StatusListView {
        id: statusChatListItems
        width: 288
        height: root.height
        objectName: "chatListItems"
        model: root.model
        spacing: 0
        interactive: height !== contentHeight

        delegate: Loader {
            id: chatLoader

            sourceComponent: {
                if (model.isCategory) {
                     return categoryItemComponent
                }
                return channelItemComponent
            }
            
            Component {
                id: categoryItemComponent
                StatusChatListCategoryItem {
                    id: statusChatListCategoryItem
                    
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

                    title: model.name

                    opened: model.categoryOpened

                    sensor.pressAndHoldInterval: 150
                    propagateTitleClicks: true // title click is handled as a normal click (fallthru)
                    showAddButton: showCategoryActionButtons
                    showMenuButton: !!root.onPopupMenuChanged
                    highlighted: false//statusChatListCategory.dragged // FIXME DND
                    
                    hasUnreadMessages: model.hasUnreadMessages
                    
                    onClicked: {
                        if (!sensor.enabled) {
                            return
                        }
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
                        let p = menuButton.mapToItem(statusChatListCategoryItem, menuButton.x, menuButton.y)
                        let menuWidth = categoryPopupMenuSlot.item.width
                        categoryPopupMenuSlot.item.popup()
                    }
                    onAddButtonClicked: {
                        root.categoryAddButtonClicked(categoryId)
                    }
                }
                
            }
            
            Component {
                id: channelItemComponent
                QC.Control {
                    id: draggable
                    objectName: model.name
                    width: root.width
                    height: model.categoryOpened ? statusChatListItem.height : 0
                    visible: height
                    verticalPadding: 2

                    property alias chatListItem: statusChatListItem

                    contentItem: MouseArea {
                        id: dragSensor

                        anchors.fill: parent
                        cursorShape: active ? Qt.ClosedHandCursor : Qt.PointingHandCursor
                        hoverEnabled: true
                        enabled: root.draggableItems

                        property bool active: false
                        property real startY: 0
                        property real startX: 0

                        drag.target: draggedListItemLoader.item
                        drag.filterChildren: true

                        onPressed: {
                            startY = mouseY
                            startX = mouseX
                        }
                        onPressAndHold: active = true
                        onReleased: {
                            if (active && d.destinationPosition !== -1 && statusChatListItem.originalOrder !== d.destinationPosition) {
                                root.chatItemReordered(statusChatListItem.chatId, statusChatListItem.originalOrder, d.destinationPosition)
                            }
                            active = false
                        }
                        onMouseYChanged: {
                            if ((Math.abs(startY - mouseY) > 1) && pressed) {
                                active = true
                            }
                        }
                        onMouseXChanged: {
                            if ((Math.abs(startX - mouseX) > 1) && pressed) {
                                active = true
                            }
                        }
                        onActiveChanged: d.destinationPosition = -1

                        StatusChatListItem {
                            id: statusChatListItem

                            width: parent.width
                            opacity: dragSensor.active ? 0.0 : 1.0
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

                            sensor.cursorShape: dragSensor.cursorShape

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
                    }

                    DropArea {
                        id: dropArea
                        width: dragSensor.active ? 0 : parent.width
                        height: dragSensor.active ? 0 : parent.height
                        keys: ["chat-item-category-" + statusChatListItem.categoryId]

                        onEntered: reorderDelay.start()

                        Timer {
                            id: reorderDelay
                            interval: 100
                            repeat: false
                            onTriggered: {
                                if (dropArea.containsDrag) {
                                    d.destinationPosition = root.model.get(draggable.DelegateModel.itemsIndex).position
                                    statusChatListItems.items.move(dropArea.drag.source.DelegateModel.itemsIndex, draggable.DelegateModel.itemsIndex)
                                }
                            }
                        }
                    }

                    Loader {
                        id: draggedListItemLoader
                        active: dragSensor.active
                        sourceComponent: StatusChatListItem {
                            property var globalPosition: Utils.getAbsolutePosition(draggable)
                            parent: QC.Overlay.overlay
                            sensor.cursorShape: dragSensor.cursorShape
                            Drag.active: dragSensor.active
                            Drag.hotSpot.x: width / 2
                            Drag.hotSpot.y: height / 2
                            Drag.keys: ["chat-item-category-" + categoryId]
                            Drag.source: draggable

                            chatId: draggable.chatListItem.chatId
                            categoryId: draggable.chatListItem.categoryId
                            name: draggable.chatListItem.name
                            type: draggable.chatListItem.type
                            muted: draggable.chatListItem.muted
                            dragged: true
                            hasUnreadMessages: model.hasUnreadMessages
                            notificationsCount: model.notificationsCount
                            selected: draggable.chatListItem.selected

                            asset.color: draggable.chatListItem.asset.color
                            asset.imgIsIdenticon: draggable.chatListItem.asset.imgIsIdenticon
                            asset.name: draggable.chatListItem.asset.name

                            Component.onCompleted: {
                                x = globalPosition.x
                                y = globalPosition.y
                            }
                        }
                    }
                }
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
