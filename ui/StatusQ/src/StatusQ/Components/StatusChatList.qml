import QtQuick 2.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

Column {
    id: statusChatList

    spacing: 4
    width: 288

    property string categoryId: ""
    property string selectedChatId: ""
    property alias chatListItems: statusChatListItems

    property Component popupMenu

    property var filterFn

    signal chatItemSelected(string id)
    signal chatItemUnmuted(string id)

    onPopupMenuChanged: {
        if (!!popupMenu) {
            popupMenuSlot.sourceComponent = popupMenu
        }
    }

    Repeater {
        id: statusChatListItems
        delegate: StatusChatListItem {
            id: statusChatListItem
            chatId: model.chatId || model.id
            name: model.name
            type: model.chatType
            muted: !!model.muted
            hasUnreadMessages: !!model.hasUnreadMessages
            hasMention: !!model.hasMention
            badge.value: model.unreadMessagesCount || 0
            selected: model.chatId === statusChatList.selectedChatId

            icon.color: model.color || ""
            image.source: model.identicon || ""

            onClicked: {
                if (mouse.button === Qt.RightButton && !!statusChatList.popupMenu) {
                    highlighted = true

                    let originalOpenHandler = popupMenuSlot.item.openHandler
                    let originalCloseHandler = popupMenuSlot.item.closeHandler

                    popupMenuSlot.item.openHandler = function () {
                        if (popupMenuSlot.item.hasOwnProperty('chatId')) {
                            popupMenuSlot.item.chatId = model.chatId || model.id
                        }
                        if (!!originalOpenHandler) {
                            originalOpenHandler()
                        }
                    }

                    popupMenuSlot.item.closeHandler = function () {
                        highlighted = false
                        if (!!originalCloseHandler) {
                            originalCloseHandler()
                        }
                    }

                    popupMenuSlot.item.popup(mouse.x + 4, statusChatListItem.y + mouse.y + 6)
                    popupMenuSlot.item.openHandler = originalOpenHandler
                    return
                }
                statusChatList.chatItemSelected(model.chatId || model.id)
            }
            onUnmute: statusChatList.chatItemUnmuted(model.chatId || model.id)
            visible: {
                if (!!statusChatList.filterFn) {
                    return statusChatList.filterFn(model, statusChatList.categoryId)
                }
                return true
            }
        }
    }

    Loader {
        id: popupMenuSlot
        active: !!statusChatList.popupMenu
    }
}
