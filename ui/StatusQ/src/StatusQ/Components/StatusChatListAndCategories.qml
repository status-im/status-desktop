import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Components 0.1
import StatusQ.Popups 0.1

ScrollView {
    id: statusChatListAndCategories

    clip: true
    contentHeight: chatListsAndCategories.height + 8

    property string selectedChatId: ""
    property bool showCategoryActionButtons: false
    property alias chatList: statusChatList.chatListItems
    property alias categoryList: statusChatListCategories
    property alias sensor: sensor

    property Component categoryPopupMenu
    property Component popupMenu

    signal chatItemSelected(string id)
    signal chatItemUnmuted(string id)
    signal categoryAddButtonClicked(string id)

    onPopupMenuChanged: {
        if (!!popupMenu) {
            popupMenuSlot.sourceComponent = popupMenu
        }
    }

    MouseArea {
        id: sensor
        anchors.top: parent.top
        width: parent.width
        height: statusChatListAndCategories.height
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            if (mouse.button === Qt.RightButton && !!statusChatListAndCategories.popupMenu) {
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
                visible: !!chatListItems.model && chatListItems.model.count > 0
                selectedChatId: statusChatListAndCategories.selectedChatId
                onChatItemSelected: statusChatListAndCategories.chatItemSelected(id)
                onChatItemUnmuted: statusChatListAndCategories.chatItemUnmuted(id)
                filterFn: function (model) {
                    return !!!model.categoryId
                }
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

                    popupMenu: statusChatListAndCategories.categoryPopupMenu
                }
            }
        }
    }

    Loader {
        id: popupMenuSlot
        active: !!statusChatListAndCategories.popupMenu
    }
}
