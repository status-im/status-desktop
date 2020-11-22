import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../shared"
import "../../../../imports"
import "../components"
import "./"

ScrollView {
    property alias channelListCount: chatGroupsListView.count
    property string searchStr: ""
    id: chatGroupsContainer
    Layout.fillHeight: true
    Layout.fillWidth: true
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    contentHeight: channelListContent.height + Style.current.padding
    clip: true

    Timer {
        id: timer
    }


    Item {
        id: channelListContent
        Layout.fillHeight: true
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left
        height: childrenRect.height

        ListView {
            id: chatGroupsListView
            anchors.top: parent.top
            height: childrenRect.height
            visible: height > 0
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.rightMargin: Style.current.padding
            anchors.leftMargin: Style.current.padding
            interactive: false
            model: chatsModel.chats
            delegate: Channel {
                name: model.name
                muted: model.muted
                lastMessage: model.lastMessage
                timestamp: model.timestamp
                chatType: model.chatType
                identicon: model.identicon
                unviewedMessagesCount: model.unviewedMessagesCount
                hasMentions: model.hasMentions
                contentType: model.contentType
                searchStr: chatGroupsContainer.searchStr
                chatId: model.id
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

        Rectangle {
            id: noSearchResults
            anchors.top: parent.top
            height: 300
            color: "transparent"
            visible: !chatGroupsListView.visible && chatGroupsContainer.searchStr !== ""
            anchors.left: parent.left
            anchors.right: parent.right

            StyledText {
                font.pixelSize: 15
                color: Style.current.darkGrey
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("No search results")
            }
        }

        EmptyView {
            width: parent.width
            anchors.top: noSearchResults.visible ? noSearchResults.bottom : chatGroupsListView.bottom 
            anchors.topMargin: Style.current.smallPadding
        }

    }

    GroupInfoPopup {
        id: groupInfoPopup
        onClosed: {
            mouseArea.menuOpened = false
        }
    }

    PopupMenu {
        property int channelIndex
        property bool channelMuted
        property int chatType
        property string chatName
        property string chatId
        property string chatIdenticon

        id: channelContextMenu
        width: 175
        subMenuIcons: [
            /* { */
            /*     source:  Qt.resolvedUrl("../../../img/bell.svg"), */
            /*     width: 16, */
            /*     height: 16 */
            /* }, */
            {
                source: Qt.resolvedUrl("../../../img/fetch.svg"),
                width: 16,
                height: 16
            }
        ]

        function openMenu(channelIndex, muted, chatType, chatName, chatId, chatIdenticon) {
            channelContextMenu.channelIndex = channelIndex
            channelContextMenu.channelMuted = muted
            channelContextMenu.chatType = chatType
            channelContextMenu.chatName = chatName
            channelContextMenu.chatId = chatId
            channelContextMenu.chatIdenticon = chatIdenticon
            channelContextMenu.popup()
        }

        Action {
            enabled: channelContextMenu.chatType !== Constants.chatTypePublic
            text: {
                if (channelContextMenu.chatType === Constants.chatTypeOneToOne) {
                    //% "View Profile"
                    return qsTrId("view-profile")
                }
                if (channelContextMenu.chatType === Constants.chatTypePrivateGroupChat) {
                    //% "View Group"
                    return qsTrId("view-group")
                }
                //% "Share Chat"
                return qsTrId("share-chat")
            }
            icon.source: "../../../img/group.svg"
            icon.width: 16
            icon.height: 16
            onTriggered: {
                chatsModel.setActiveChannelByIndex(channelContextMenu.channelIndex)
                chatGroupsListView.currentIndex = channelContextMenu.channelIndex
                if (channelContextMenu.chatType === Constants.chatTypeOneToOne) {
                    return openProfilePopup(channelContextMenu.chatName, channelContextMenu.chatId, channelContextMenu.chatIdenticon)
                }
                if (channelContextMenu.chatType === Constants.chatTypePrivateGroupChat) {
                    return groupInfoPopup.open()
                }
            }
        }

        Separator {}

        Action {
            text: channelContextMenu.channelMuted ?
                      //% "Unmute chat"
                      qsTrId("unmute-chat") :
                      //% "Mute chat"
                      qsTrId("mute-chat")
            icon.source: "../../../img/bell.svg"
            icon.width: 16
            icon.height: 16
            onTriggered: {
                if (chatsModel.channelIsMuted(channelContextMenu.channelIndex)) {
                    chatsModel.unmuteChannel(channelContextMenu.channelIndex)
                    return
                }
                chatsModel.muteChannel(channelContextMenu.channelIndex)
            }
        }

        Action {
            //% "Mark as Read"
            text: qsTrId("mark-as-read")
            icon.source: "../../../img/check-circle.svg"
            icon.width: 16
            icon.height: 16
            onTriggered: {
                chatsModel.markAllChannelMessagesReadByIndex(channelContextMenu.channelIndex)
            }
        }
        FetchMoreMessages {}
        Action {
            //% "Clear History"
            text: qsTrId("clear-history")
            icon.source: "../../../img/close.svg"
            icon.width: 16
            icon.height: 16
            onTriggered: chatsModel.clearChatHistoryByIndex(channelContextMenu.channelIndex)
        }

        Separator {}

        Action {
            text: {
                if (channelContextMenu.chatType === Constants.chatTypeOneToOne) {
                    //% "Delete chat"
                    return qsTrId("delete-chat")
                }
                if (channelContextMenu.chatType === Constants.chatTypePrivateGroupChat) {
                    //% "Leave group"
                    return qsTrId("leave-group")
                }
                //% "Leave chat"
                return qsTrId("leave-chat")
            }
            icon.source: {
                if (channelContextMenu.chatType === Constants.chatTypeOneToOne) {
                    return "../../../img/delete.svg"
                }
                return "../../../img/leave_chat.svg"
            }
            icon.width: 16
            icon.height: 16
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
            chatsModel.hideLoadingIndicator()
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
