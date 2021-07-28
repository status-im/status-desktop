import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Components 0.1
import StatusQ.Popups 0.1

Item {
    id: statusChatListAndCategories

    implicitHeight: chatListsAndCategories.height
    implicitWidth: chatListsAndCategories.width

    property string selectedChatId: ""
    property bool showCategoryActionButtons: false
    property bool showPopupMenu: true
    property alias chatList: statusChatList.chatListItems
    property alias categoryList: statusChatListCategories
    property alias sensor: sensor
    property bool draggableItems: false

    property Component categoryPopupMenu
    property Component chatListPopupMenu
    property Component popupMenu

    signal chatItemSelected(string id)
    signal chatItemUnmuted(string id)
    signal chatItemReordered(string categoryId, string chatId, int from, int to)
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

            Repeater {
                id: statusChatListCategories
                visible: !!model && model.count > 0

                delegate: StatusChatListCategory {
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
            }
        }
    }

    Loader {
        id: popupMenuSlot
        active: !!statusChatListAndCategories.popupMenu
    }
}
