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
            muted: model.muted
            lastMessage: model.lastMessage
            timestamp: model.timestamp
            chatType: model.chatType
            identicon: model.identicon
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
        property bool channelMuted

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

        function openMenu(channelIndex, muted) {
            channelContextMenu.channelIndex = channelIndex
            channelContextMenu.channelMuted = muted
            channelContextMenu.popup()
        }

        Action {
            //% "View Group"
            text: qsTrId("view-group")
            icon.source: "../../../img/group.svg"
            icon.width: 16
            icon.height: 16
            onTriggered: console.log('TODO View group')
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

        /* PopupMenu { */
        /*     hasArrow: false */
        /*     title: qstr("Mute chat") */

        /*     // TODO implement mute chat in Model and call it here */
        /*     Action { */ 
        //% "15 minutes"
        /*         text: qsTrId("15-minutes"); */
        /*         icon.width: 0; */ 
        /*         onTriggered: { */
        /*             chatsModel.muteChannel(channelContextMenu.channelIndex, Constants.muteChat15Minutes) */
        /*         } */
        /*     } */
        /*     Action { */
        //% "1 hour"
        /*         text: qsTrId("1-hour"); */
        /*         icon.width: 0; */
        /*         onTriggered: { */
        /*             chatsModel.muteChannel(channelContextMenu.channelIndex, Constants.muteChatOneHour) */
        /*         } */
        /*     } */
        /*     Action { */
        //% "8 hours"
        /*         text: qsTrId("8-hours"); */
        /*         icon.width: 0; */
        /*         onTriggered: { */
        /*             chatsModel.muteChannel(channelContextMenu.channelIndex, Constants.muteChatEightHours) */
        /*         } */
        /*     } */
        /*     Action { */ 
        //% "24 hours"
        /*         text: qsTrId("24-hours"); */ 
        /*         icon.width: 0; */
        /*         onTriggered: { */
        /*             chatsModel.muteChannel(channelContextMenu.channelIndex, Constants.muteChat24Hours) */
        /*         } */
        /*     } */
        /*     Action { */ 
        //% "Until I turn it back on"
        /*         text: qsTrId("until-i-turn-it-back-on"); */
        /*         icon.width: 0; */ 
        /*         onTriggered: { */
        /*             console.log(appSettings.mutedChannels) */
        /*             appSettings.mutedChannels.push({ */
        /*               name: "Foo" */
        /*             }) */
        /*             console.log(appSettings.mutedChannels) */
        /*             //chatsModel.muteChannel(channelContextMenu.channelIndex, Constants.muteChatUntilUnmuted) */
        /*         } */
        /*     } */
        /* } */
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
        PopupMenu {
            hasArrow: false
            //% "Fetch Messages"
            title: qsTrId("fetch-messages")

            // TODO call fetch for the wanted duration
            //% "Last 24 hours"
            Action { text: qsTrId("last-24-hours"); icon.width: 0; }
            //% "Last 2 days"
            Action { text: qsTrId("last-2-days"); icon.width: 0; }
            //% "Last 3 days"
            Action { text: qsTrId("last-3-days"); icon.width: 0; }
            //% "Last 7 days"
            Action { text: qsTrId("last-7-days"); icon.width: 0; }
        }
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
            //% "Leave Group"
            text: qsTrId("leave-group")
            icon.source: "../../../img/leave_chat.svg"
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
