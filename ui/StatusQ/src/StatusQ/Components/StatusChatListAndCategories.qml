import QtQuick 2.15

import StatusQ.Components 0.1
import StatusQ.Core 0.1

import SortFilterProxyModel 0.2

Item {
    id: root

    implicitHeight: statusChatList.height
    implicitWidth: statusChatList.width

    property alias highlightItem: statusChatList.highlightItem

    property var model: []
    property bool showCategoryActionButtons: false
    property bool showPopupMenu: true
    property alias sensor: sensor
    property bool draggableItems: false
    property bool draggableCategories: false

    property Component categoryPopupMenu
    property Component chatListPopupMenu
    property alias popupMenu: popupMenuSlot.sourceComponent

    signal chatItemSelected(string categoryId, string id)
    signal chatItemUnmuted(string id)
    signal chatItemReordered(string categoryId, string chatId, int to)
    signal chatListCategoryReordered(string categoryId, int to)
    signal categoryAddButtonClicked(string id)

    MouseArea {
        id: sensor
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            if (mouse.button === Qt.RightButton && showPopupMenu && !!root.popupMenu) {
                popupMenuSlot.item.popup(mouse.x + 4, mouse.y + 6)
                return
            }
        }

        StatusChatList {
            objectName: "statusChatListAndCategoriesChatList"
            id: statusChatList
            width: parent.width
            visible: statusChatList.model.count > 0
            onChatItemSelected: root.chatItemSelected(categoryId, id)
            onChatItemUnmuted: root.chatItemUnmuted(id)
            onChatItemReordered: root.chatItemReordered(categoryId, chatId, to)
            onCategoryReordered: root.chatListCategoryReordered(categoryId, to)
            draggableItems: root.draggableItems
            showCategoryActionButtons: root.showCategoryActionButtons
            onCategoryAddButtonClicked: root.categoryAddButtonClicked(id)

            model: SortFilterProxyModel {
                sourceModel: root.model
                sorters: [
                    RoleSorter {
                        roleName: "categoryPosition"
                        priority: 2 // Higher number === higher priority
                    },
                    RoleSorter {
                        roleName: "position"
                        priority: 1
                    }
                ]
            }

            popupMenu: root.chatListPopupMenu
            categoryPopupMenu: root.categoryPopupMenu
        }
    }

    Loader {
        id: popupMenuSlot
        active: !!sourceComponent
    }
}
