import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "./"
import "../../../../shared"
import "../../../../imports"

PopupMenu {
    property int channelIndex
    property bool channelMuted
    property int chatType
    property string chatName
    property string chatId
    property string chatIdenticon
    property var groupInfoPopup
    property var groupsListView

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

    function openMenu(channel, index) {
        channelContextMenu.channelMuted = channel.muted
        channelContextMenu.chatType = channel.chatType
        channelContextMenu.chatName = channel.name
        channelContextMenu.chatId = channel.id
        channelContextMenu.chatIdenticon = channel.identicon
        if (index !== undefined) {
            channelContextMenu.channelIndex = index
        }
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
            //chatsModel.setActiveChannelByIndex(channelContextMenu.channelIndex)
            if (!!groupsListView) {
                groupsListView.currentIndex = channelContextMenu.channelIndex
            }
            if (channelContextMenu.chatType === Constants.chatTypeOneToOne) {
                const userProfileImage = appMain.getProfileImage(channelContextMenu.chatId)
                return openProfilePopup(channelContextMenu.chatName, channelContextMenu.chatId, userProfileImage || channelContextMenu.chatIdenticon)
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

