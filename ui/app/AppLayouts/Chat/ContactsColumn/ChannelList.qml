import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../shared"
import "../../../../imports"
import "../components"

ScrollView {
    property alias channelListCount: chatGroupsListView.count
    property string searchStr: ""
    id: chatGroupsContainer
    Layout.fillHeight: true
    Layout.fillWidth: true
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

    ListView {
        id: chatGroupsListView
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.rightMargin: Style.current.padding
        anchors.leftMargin: Style.current.padding
        clip: true
        model: chatsModel.chats
        delegate: Channel {
            name: model.name
            lastMessage: model.lastMessage
            timestamp: model.timestamp
            chatType: model.chatType
            unviewedMessagesCount: model.unviewedMessagesCount
            hasMentions: model.hasMentions
            contentType: model.contentType
            searchStr: chatGroupsContainer.searchStr
        }
        onCountChanged: {
            if (count > 0 && chatsModel.activeChannelIndex > -1) {
                // If a chat is added or removed, we set the current index to the first value
                chatsModel.activeChannelIndex = 0;
                currentIndex = 0;
            } else {
                if(chatsModel.activeChannelIndex > -1){
                    chatGroupsListView.currentIndex = 0;
                } else {
                    // Initial state. No chat has been selected yet
                    chatGroupsListView.currentIndex = -1;
                }
            }
        }
    }

    PopupMenu {
        property int channelIndex

        id: channelContextMenu
        width: 175

        function openMenu(channelIndex) {
            channelContextMenu.channelIndex = channelIndex
            channelContextMenu.popup()
        }

        Action {
            text: qsTr("View Group")
            icon.source: "../../../img/group.svg"
            icon.width: 13
            icon.height: 13
            onTriggered: console.log('TODO View group')
        }
        Action {
            text: qsTr("Mute Chat")
            icon.source: "../../../img/bell.svg"
            icon.width: 13
            icon.height: 13
            onTriggered: console.log('TODO Mute')
        }
        Action {
            text: qsTr("Mark as Read")
            icon.source: "../../../img/check-circle.svg"
            icon.width: 13
            icon.height: 13
            onTriggered: {
                chatsModel.markAllChannelMessagesReadByIndex(channelContextMenu.channelIndex)
            }
        }
        Action {
            text: qsTr("Fetch Messages")
            icon.source: "../../../img/fetch.svg"
            icon.width: 13
            icon.height: 13
            onTriggered: {
                chatsModel.loadMoreMessagesWithIndex(channelContextMenu.channelIndex)
            }
        }
        Action {
            text: qsTr("Clear History")
            icon.source: "../../../img/close.svg"
            icon.width: 13
            icon.height: 13
            onTriggered: chatsModel.clearChatHistoryByIndex(channelContextMenu.channelIndex)
        }
        Action {
            text: qsTr("Leave Group")
            icon.source: "../../../img/leave_chat.svg"
            icon.width: 13
            icon.height: 13
            onTriggered: chatsModel.leaveChatByIndex(channelContextMenu.channelIndex)
        }
    }

    Connections {
        target: chatsModel.chats
        onDataChanged: {
            // If the current active channel receives messages and changes its position,
            // refresh the currentIndex accordingly
            if(chatsModel.activeChannelIndex !== chatGroupsListView.currentIndex){
                chatGroupsListView.currentIndex = chatsModel.activeChannelIndex
            }
        }
    }

    Connections {
        target: chatsModel
        onActiveChannelChanged: {
            chatGroupsListView.currentIndex = chatsModel.activeChannelIndex
            SelectedMessage.reset();
            chatColumn.isReply = false;
        }
    }
}
/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
