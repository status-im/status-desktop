import QtQuick 2.14
import QtQml.Models 2.14
import QtQuick.Controls 2.14 as QC

import StatusQ.Core.Utils 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1
import StatusQ.Core 0.1

import SortFilterProxyModel 0.2

Item {
    id: root

    implicitHeight: chatListsAndCategories.height
    implicitWidth: chatListsAndCategories.width

    property alias highlightItem: statusChatList.highlightItem

    property StatusTooltipSettings categoryAddButtonToolTip: StatusTooltipSettings {
        text: qsTr("Add channel inside category")
    }
    property StatusTooltipSettings categoryMenuButtonToolTip: StatusTooltipSettings {
        text: qsTr("More")
    }

    property var model: []
    property bool showCategoryActionButtons: false
    property bool showPopupMenu: true
    property alias sensor: sensor
    property bool draggableItems: false
    property bool draggableCategories: false
    // Keeps track of expanded category state. Should only be modified
    // internally at runtime.
    property var openedCategoryState: new Object({})

    property Component categoryPopupMenu
    property Component chatListPopupMenu
    property Component popupMenu

    signal chatItemSelected(string categoryId, string id)
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
        width: root.width
        height: root.height
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            if (mouse.button === Qt.RightButton && showPopupMenu && !!root.popupMenu) {
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
                objectName: "statusChatListAndCategoriesChatList"
                id: statusChatList
                visible: statusChatList.model.count > 0
                onChatItemSelected: root.chatItemSelected(categoryId, id)
                onChatItemUnmuted: root.chatItemUnmuted(id)
                onChatItemReordered: root.chatItemReordered(categoryId, id, from, to)
                draggableItems: root.draggableItems

                model: SortFilterProxyModel {
                    sourceModel: root.model

                    filters: ValueFilter { roleName: "isCategory"; value: false }
                    sorters: RoleSorter { roleName: "position" }
                }

                popupMenu: root.chatListPopupMenu
            }

            DelegateModel {
                id: delegateModel

                property int destinationPosition: -1

                model: SortFilterProxyModel {
                    sourceModel: root.model

                    filters: ValueFilter { roleName: "isCategory"; value: true }
                    sorters: RoleSorter { roleName: "position" }
                }

                items.includeByDefault: false

                groups: DelegateModelGroup {
                    id: unsortedItems

                    name: "unsorted"
                    includeByDefault: true
                    onChanged: Utils.delegateModelSort(unsortedItems, delegateModel.items,
                                                       (a, b) => a.position < b.position)
                }

                delegate: Item {
                    id: draggable
                    objectName: model.name
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
                            if (root.draggableCategories) {
                                dragActive = true
                            }
                        }
                        dragSensor.onReleased: {
                            if (dragActive && delegateModel.destinationPosition !== -1 && statusChatListCategory.originalOrder !== delegateModel.destinationPosition) {
                                root.chatListCategoryReordered(statusChatListCategory.categoryId, statusChatListCategory.originalOrder, delegateModel.destinationPosition)
                            }
                            dragActive = false
                        }
                        dragSensor.cursorShape: dragActive ? Qt.ClosedHandCursor : Qt.PointingHandCursor
                        dragSensor.onPressed: {
                            startY = dragSensor.mouseY
                            startX = dragSensor.mouseX
                        }
                        dragSensor.onMouseYChanged: {
                            if (root.draggableCategories && (Math.abs(startY - dragSensor.mouseY) > 1) && dragSensor.pressed) {
                                dragActive = true
                            }
                        }
                        dragSensor.onMouseXChanged: {
                            if (root.draggableCategories && (Math.abs(startX - dragSensor.mouseX) > 1) && dragSensor.pressed) {
                                dragActive = true
                            }
                        }
                        onDragActiveChanged: delegateModel.destinationPosition = -1

                        addButton.tooltip: root.categoryAddButtonToolTip
                        menuButton.tooltip: root.categoryMenuButtonToolTip

                        originalOrder: model.position
                        categoryId: model.itemId
                        name: model.name

                        showActionButtons: root.showCategoryActionButtons
                        addButton.onClicked: root.categoryAddButtonClicked(model.itemId)

                        chatList.model: SortFilterProxyModel {
                            sourceModel: model.subItems
                            sorters: RoleSorter { roleName: "position" }
                        }

                        chatList.onChatItemSelected: root.chatItemSelected(categoryId, id)
                        chatList.onChatItemUnmuted: root.chatItemUnmuted(id)
                        chatList.onChatItemReordered: root.chatItemReordered(model.itemId, id, from, to)
                        chatList.draggableItems: root.draggableItems

                        popupMenu: root.categoryPopupMenu
                        chatListPopupMenu: root.chatListPopupMenu

                        // Used to set the initial value of "opened" when the
                        // model is bound/changed.
                        opened: {
                            let openedState = root.openedCategoryState[model.itemId]
                            return openedState !== undefined ? openedState : true // defaults to open
                        }

                        // Used to track the internal changes of the `opened`
                        // property. This cannot be brought inside the component
                        // as the state would be lost each time the model is
                        // changed.
                        onOpenedChanged: {
                            root.openedCategoryState[model.itemId] = statusChatListCategory.opened
                        }

                        Connections {
                            function onOriginalOrderChanged() {
                                Qt.callLater(() => {
                                    if (!delegateModel)
                                        return

                                    delegateModel.items.setGroups(0, delegateModel.items.count, "unsorted")
                                })
                            }
                        }
                    }

                    DropArea {
                        id: dropArea
                        width: draggable.chatListCategory.dragActive ? 0 : parent.width
                        height: draggable.chatListCategory.dragActive ? 0 : parent.height
                        keys: ["chat-category"]

                        onEntered: reorderDelay.start()

                        Timer {
                            id: reorderDelay
                            interval: 100
                            repeat: false
                            onTriggered: {
                                if (dropArea.containsDrag) {
                                    delegateModel.destinationPosition = delegateModel.model.get(draggable.DelegateModel.itemsIndex).position
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

                            chatList.model: draggable.chatListCategory.chatList.model
                        }
                    }
                }
            }

            Repeater {
                id: statusChatListCategories
                objectName: "communityChatListCategories"
                visible: !!model && model.count > 0
                model: delegateModel
            }
        }
    }

    Loader {
        id: popupMenuSlot
        active: !!root.popupMenu
    }
}
