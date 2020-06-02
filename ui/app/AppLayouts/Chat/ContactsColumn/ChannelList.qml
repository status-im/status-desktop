import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "../../../../shared"
import "../../../../imports"
import "../components"

Item {
    property alias channelListCount: chatGroupsListView.count
    id: chatGroupsContainer
    Layout.fillHeight: true
    Layout.fillWidth: true

    ListView {
        id: chatGroupsListView
        anchors.topMargin: 24
        anchors.fill: parent
        model: chatsModel.chats
        delegate: Channel {}
        onCountChanged: {
            // If a chat is added or removed, we set the current index to the first value
            if (count > 0) {
                currentIndex = 0;
                chatsModel.activeChannelIndex = 0;
            }
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
}