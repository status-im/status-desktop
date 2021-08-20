import QtQuick 2.13

import StatusQ.Components 0.1
import StatusQ.Popups 0.1

Column {
    id: statusChatListCategory

    spacing: 0

    property string categoryId: ""
    property string name: ""
    property bool opened: true

    property alias showActionButtons: statusChatListCategoryItem.showActionButtons
    property alias addButton: statusChatListCategoryItem.addButton
    property alias menuButton: statusChatListCategoryItem.menuButton
    property alias toggleButton: statusChatListCategoryItem.toggleButton
    property alias chatList: statusChatList

    property Component chatListPopupMenu
    property Component popupMenu

    onPopupMenuChanged: {
        if (!!popupMenu) {
            popupMenuSlot.sourceComponent = popupMenu
        }
    }

    StatusChatListCategoryItem {
        id: statusChatListCategoryItem
        title: statusChatListCategory.name
        opened: statusChatListCategory.opened

        showMenuButton: showActionButtons && !!statusChatListCategory.popupMenu

        sensor.onClicked: {
            if (mouse.button === Qt.RightButton && showActionButtons && !!statusChatListCategory.popupMenu) {
                highlighted = true
                popupMenuSlot.item.popup(mouse.x + 4, mouse.y + 6)
                return
            }
            statusChatListCategory.opened = !opened
        }

        onTitleClicked: statusChatListCategory.opened = !opened
        onToggleButtonClicked: statusChatListCategory.opened = !opened
        onMenuButtonClicked: {
            highlighted = true
            menuButton.highlighted = true
            let p = menuButton.mapToItem(statusChatListCategoryItem, menuButton.x, menuButton.y)
            let menuWidth = popupMenuSlot.item.width
            popupMenuSlot.item.popup(p.x - menuWidth, p.y + menuButton.height + 4)
        }
    }

    StatusChatList {
        id: statusChatList
        anchors.horizontalCenter: parent.horizontalCenter
        visible: statusChatListCategory.opened
        categoryId: statusChatListCategory.categoryId
        filterFn: function (model) {
            return !!model.categoryId && model.categoryId == statusChatList.categoryId
        }

        popupMenu: statusChatListCategory.chatListPopupMenu
    }

    Loader {
        id: popupMenuSlot
        active: !!statusChatListCategory.popupMenu
        onLoaded: {
            let originalOpenHandler = popupMenuSlot.item.openHandler
            let originalCloseHandler = popupMenuSlot.item.closeHandler

            popupMenuSlot.item.openHandler = function () {
                if (!!originalOpenHandler) {
                    originalOpenHandler(statusChatListCategory.categoryId)
                }
            }

            popupMenuSlot.item.closeHandler = function () {
                statusChatListCategoryItem.highlighted = false
                statusChatListCategoryItem.menuButton.highlighted = false
                if (!!originalCloseHandler) {
                    originalCloseHandler()
                }
            }
        }
    }
}

