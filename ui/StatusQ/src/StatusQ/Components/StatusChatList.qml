import QtQuick 2.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

Column {
    id: statusChatList

    spacing: 4

    property string selectedChatId: ""
    property alias chatListItems: statusChatListItems

    signal chatItemSelected(string id)
    signal chatItemUnmuted(string id)

    Repeater {
        id: statusChatListItems
        delegate: StatusChatListItem {
            chatId: model.chatId
            name: model.name
            type: model.chatType
            muted: !!model.muted
            hasUnreadMessages: !!model.hasUnreadMessages
            hasMention: !!model.hasMention
            badge.value: model.unreadMessagesCount || 0
            selected: model.chatId === statusChatList.selectedChatId

            icon.color: model.iconColor || ""
            image.source: model.identicon || ""

            onClicked: statusChatList.chatItemSelected(model.chatId)
            onUnmute: statusChatList.chatItemUnmuted(model.chatId)
        }
    }
}
