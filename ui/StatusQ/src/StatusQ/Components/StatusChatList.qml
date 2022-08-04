import QtQuick 2.13
import QtQml.Models 2.14
import QtQuick.Controls 2.13 as QC

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

Column {
    id: statusChatList

    spacing: 4
    width: 288

    property string categoryId: ""
    property var model: null
    property bool draggableItems: false
    property bool highlightItem: true

    property alias statusChatListItems: statusChatListItems

    property Component popupMenu

    signal chatItemSelected(string categoryId, string id)
    signal chatItemUnmuted(string id)
    signal chatItemReordered(string id, int from, int to)

    onPopupMenuChanged: {
        if (!!popupMenu) {
            popupMenuSlot.sourceComponent = popupMenu
        }
    }

    DelegateModel {
        id: delegateModel
        model: statusChatList.model
        delegate: Item {
            id: draggable
            objectName: model.name
            width: statusChatList.width
            height: statusChatListItem.height
            property alias chatListItem: statusChatListItem

            MouseArea {
                id: dragSensor

                anchors.fill: parent
                cursorShape: active ? Qt.ClosedHandCursor : Qt.PointingHandCursor
                hoverEnabled: true
                pressAndHoldInterval: 150
                enabled: statusChatList.draggableItems

                property bool active: false
                property real startY: 0
                property real startX: 0

                drag.target: draggedListItemLoader.item
                drag.threshold: 0.1
                drag.filterChildren: true

                onPressed: {
                    startY = mouseY
                    startX = mouseX
                }
                onPressAndHold: active = true
                onReleased: {
                    if (active) {
                        statusChatList.chatItemReordered(statusChatListItem.chatId, statusChatListItem.originalOrder, statusChatListItem.originalOrder)
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

                StatusChatListItem {
                    id: statusChatListItem

                    width: parent.width
                    opacity: dragSensor.active ? 0.0 : 1.0
                    originalOrder: model.position
                    chatId: model.itemId
                    categoryId: model.parentItemId? model.parentItemId : ""
                    name: model.name
                    type: !!model.type ? model.type : StatusChatListItem.Type.CommunityChat
                    muted: model.muted
                    hasUnreadMessages: model.hasUnreadMessages
                    notificationsCount: model.notificationsCount
                    highlightWhenCreated: !!model.highlight
                    selected: (model.active && statusChatList.highlightItem)

                    icon.emoji: model.emoji
                    icon.color: !!model.color ? model.color : Theme.palette.userCustomizationColors[model.colorId]
                    image.isIdenticon: false
                    image.source: model.icon
                    ringSettings.ringSpecModel: model.colorHash

                    sensor.cursorShape: dragSensor.cursorShape
                    onClicked: {
                        highlightWhenCreated = false

                        if (mouse.button === Qt.RightButton && !!statusChatList.popupMenu) {
                            statusChatListItem.highlighted = true

                            let originalOpenHandler = popupMenuSlot.item.openHandler
                            let originalCloseHandler = popupMenuSlot.item.closeHandler

                            popupMenuSlot.item.openHandler = function () {
                                if (!!originalOpenHandler) {
                                    originalOpenHandler(model.itemId)
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

                            let p = statusChatListItem.mapToItem(statusChatList, mouse.x, mouse.y)

                            popupMenuSlot.item.popup(p.x + 4, p.y + 6)
                            popupMenuSlot.item.openHandler = originalOpenHandler
                            return
                        }
                        if (!statusChatListItem.selected) {
                            statusChatList.chatItemSelected(model.parentItemId, model.itemId)
                        }
                    }
                    onUnmute: statusChatList.chatItemUnmuted(model.itemId)
                }
            }

            DropArea {
                id: dropArea
                width: dragSensor.active ? 0 : parent.width
                height: dragSensor.active ? 0 : parent.height
                keys: ["chat-item-category-" + statusChatListItem.categoryId]

                onEntered: reorderDelay.start()
                onDropped: statusChatList.chatItemReordered(statusChatListItem.chatId, drag.source.originalOrder, statusChatListItem.DelegateModel.itemsIndex)

                Timer {
                    id: reorderDelay
                    interval: 100
                    repeat: false
                    onTriggered: {
                        if (dropArea.containsDrag) {
                            dropArea.drag.source.chatListItem.originalOrder = statusChatListItem.originalOrder
                            delegateModel.items.move(dropArea.drag.source.DelegateModel.itemsIndex, draggable.DelegateModel.itemsIndex)
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

                    Component.onCompleted: {
                        x = globalPosition.x
                        y = globalPosition.y
                    }
                    chatId: draggable.chatListItem.chatId
                    categoryId: draggable.chatListItem.categoryId
                    name: draggable.chatListItem.name
                    type: draggable.chatListItem.type
                    muted: draggable.chatListItem.muted
                    dragged: true
                    hasUnreadMessages: model.hasUnreadMessages
                    notificationsCount: model.notificationsCount
                    selected: draggable.chatListItem.selected

                    icon.color: draggable.chatListItem.icon.color
                    image.isIdenticon: draggable.chatListItem.image.isIdenticon
                    image.source: draggable.chatListItem.image.source
                }
            }
        }
    }

    Repeater {
        id: statusChatListItems
        objectName: "chatListItems"
        model: delegateModel
    }

    Loader {
        id: popupMenuSlot
        active: !!statusChatList.popupMenu
    }
}
