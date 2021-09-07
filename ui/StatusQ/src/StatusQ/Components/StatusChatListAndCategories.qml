import QtQuick 2.14
import QtQml.Models 2.14
import QtQuick.Controls 2.14 as QC

import StatusQ.Core.Utils 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1
import StatusQ.Core 0.1

Item {
    id: statusChatListAndCategories

    implicitHeight: chatListsAndCategories.height
    implicitWidth: chatListsAndCategories.width

    property StatusTooltipSettings categoryAddButtonToolTip: StatusTooltipSettings {
        text: "Add channel inside category"
    }
    property StatusTooltipSettings categoryMenuButtonToolTip: StatusTooltipSettings {
        text: "More"
    }

    property string selectedChatId: ""
    property bool showCategoryActionButtons: false
    property bool showPopupMenu: true
    property alias chatList: statusChatList.chatListItems
    property alias categoryList: delegateModel
    property alias sensor: sensor
    property bool draggableItems: false
    property bool draggableCategories: false

    property Component categoryPopupMenu
    property Component chatListPopupMenu
    property Component popupMenu

    signal chatItemSelected(string id)
    signal chatItemUnmuted(string id)
    signal chatItemReordered(string categoryId, string chatId, int from, int to)
    signal chatListCategoryReordered(string categoryId, int from, int to)
    signal categoryAddButtonClicked(string id)

    onPopupMenuChanged: {
        if (!!popupMenu) {
            popupMenuSlot.sourceComponent = popupMenu
        }
    }

    MouseArea {
        id: sensor
        anchors.top: parent.top
        width: statusChatListAndCategories.width
        height: statusChatListAndCategories.height
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            if (mouse.button === Qt.RightButton && showPopupMenu && !!statusChatListAndCategories.popupMenu) {
                popupMenuSlot.item.popup(mouse.x + 4, mouse.y + 6)
                return
            }
        }

        Column {
            id: chatListsAndCategories

            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 4

            StatusChatList {
                id: statusChatList
                anchors.horizontalCenter: parent.horizontalCenter
                visible: chatListItems.count > 0
                selectedChatId: statusChatListAndCategories.selectedChatId
                onChatItemSelected: statusChatListAndCategories.chatItemSelected(id)
                onChatItemUnmuted: statusChatListAndCategories.chatItemUnmuted(id)
                onChatItemReordered: statusChatListAndCategories.chatItemReordered(categoryId, id, from, to)
                draggableItems: statusChatListAndCategories.draggableItems
                filterFn: function (model) {
                    return !!!model.categoryId
                }
                popupMenu: statusChatListAndCategories.chatListPopupMenu
            }

            DelegateModel {
                id: delegateModel

                delegate: Item {
                    id: draggable
                    width: statusChatListCategory.width
                    height: statusChatListCategory.height

                    property alias chatListCategory: statusChatListCategory

                    StatusChatListCategory {
                        id: statusChatListCategory

                        property bool dragActive: false
                        property real startY: 0
                        property real startX: 0
                      
                        opacity: dragActive ? 0.0 : 1.0

                        dragSensor.drag.target: draggedListCategoryLoader.item
                        dragSensor.drag.threshold: 0.1
                        dragSensor.drag.filterChildren: true
                        dragSensor.onPressAndHold: {
                            if (statusChatListAndCategories.draggableCategories) {
                                dragActive = true
                            }
                        }
                        dragSensor.onReleased: {
                            if (dragActive) {
                                statusChatListAndCategories.chatListCategoryReordered(statusChatListCategory.categoryId, statusChatListCategory.originalOrder, statusChatListCategory.originalOrder)
                            }
                            dragActive = false
                        }
                        dragSensor.cursorShape: dragActive ? Qt.ClosedHandCursor : Qt.PointingHandCursor
                        dragSensor.onPressed: {
                            startY = dragSensor.mouseY
                            startX = dragSensor.mouseX
                        }
                        dragSensor.onMouseYChanged: {
                            if (statusChatListAndCategories.draggableCategories && (Math.abs(startY - dragSensor.mouseY) > 1) && dragSensor.pressed) {
                                dragActive = true
                            }
                        }
                        dragSensor.onMouseXChanged: {
                            if (statusChatListAndCategories.draggableCategories && (Math.abs(startX - dragSensor.mouseX) > 1) && dragSensor.pressed) {
                                dragActive = true
                            }
                        }

                        addButton.tooltip: statusChatListAndCategories.categoryAddButtonToolTip
                        menuButton.tooltip: statusChatListAndCategories.categoryMenuButtonToolTip

                        originalOrder: model.position
                        categoryId: model.categoryId
                        name: model.name
                        showActionButtons: statusChatListAndCategories.showCategoryActionButtons
                        addButton.onClicked: statusChatListAndCategories.categoryAddButtonClicked(model.categoryId)

                        chatList.chatListItems.model: statusChatListAndCategories.chatList.model
                        chatList.selectedChatId: statusChatListAndCategories.selectedChatId
                        chatList.onChatItemSelected: statusChatListAndCategories.chatItemSelected(id)
                        chatList.onChatItemUnmuted: statusChatListAndCategories.chatItemUnmuted(id)
                        chatList.onChatItemReordered: statusChatListAndCategories.chatItemReordered(model.categoryId, id, from, to)
                        chatList.draggableItems: statusChatListAndCategories.draggableItems

                        popupMenu: statusChatListAndCategories.categoryPopupMenu
                        chatListPopupMenu: statusChatListAndCategories.chatListPopupMenu
                    }

                    DropArea {
                        id: dropArea
                        width: draggable.chatListCategory.dragActive ? 0 : parent.width
                        height: draggable.chatListCategory.dragActive ? 0 : parent.height
                        keys: ["chat-category"]

                        onEntered: reorderDelay.start()
                        onDropped: statusChatListAndCategories.chatListCategoryReordered(statusChatListCategory.categoryId, drag.source.originalOrder, statusChatListCategory.DelegateModel.itemsIndex)

                        Timer {
                            id: reorderDelay
                            interval: 100
                            repeat: false
                            onTriggered: {
                                if (dropArea.containsDrag) {
                                    dropArea.drag.source.chatListCategory.originalOrder = statusChatListCategory.originalOrder
                                    delegateModel.items.move(dropArea.drag.source.DelegateModel.itemsIndex, draggable.DelegateModel.itemsIndex)
                                }
                            }
                        }
                    }

                    Loader {
                        id: draggedListCategoryLoader
                        active: draggable.chatListCategory.dragActive
                        sourceComponent: StatusChatListCategory {
                            property var globalPosition: Utils.getAbsolutePosition(draggable)
                            parent: QC.Overlay.overlay

                            dragSensor.cursorShape: draggable.chatListCategory.dragSensor.cursorShape
                            Drag.active: draggable.chatListCategory.dragActive
                            Drag.hotSpot.x: width / 2
                            Drag.hotSpot.y: height / 2
                            Drag.keys: ["chat-category"]
                            Drag.source: draggable

                            Component.onCompleted: {
                                x = globalPosition.x
                                y = globalPosition.y
                            }
                            dragged: true
                            categoryId: draggable.chatListCategory.categoryId
                            name: draggable.chatListCategory.name
                            showActionButtons: draggable.chatListCategory.showActionButtons

                            chatList.chatListItems.model: draggable.chatListCategory.chatList.chatListItems.model
                            chatList.selectedChatId: draggable.chatListCategory.chatList.selectedChatId
                        }
                    }
                }
            }

            Repeater {
                id: statusChatListCategories
                visible: !!model && model.count > 0
                model: delegateModel
            }
        }
    }

    Loader {
        id: popupMenuSlot
        active: !!statusChatListAndCategories.popupMenu
    }
}
