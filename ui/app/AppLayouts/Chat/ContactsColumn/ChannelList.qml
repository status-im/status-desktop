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

    Component {
        id: chatViewDelegate

        Rectangle {
            id: wrapper
            color: ListView.isCurrentItem ? Theme.lightBlue : Theme.transparent
            anchors.right: parent.right
            anchors.rightMargin: Theme.padding
            anchors.top: applicationWindow.top
            anchors.topMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: Theme.padding
            radius: 8
            // Hide the box if it is filtered out
            property bool isVisible: searchStr == "" || name.includes(searchStr)
            visible: isVisible ? true : false
            height: isVisible ? 64 : 0

            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                onClicked: {
                    chatsModel.setActiveChannelByIndex(index)
                    chatGroupsListView.currentIndex = index
                }
            }

            Rectangle {
                id: contactImage
                width: 40
                color: Theme.darkGrey
                anchors.left: parent.left
                anchors.leftMargin: Theme.padding
                anchors.top: parent.top
                anchors.topMargin: 12
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 12
                radius: 50
            }

            Text {
                id: contactInfo
                text: name
                anchors.right: contactTime.left
                anchors.rightMargin: Theme.smallPadding
                elide: Text.ElideRight
                font.weight: Font.Medium
                font.pixelSize: 15
                anchors.left: contactImage.right
                anchors.leftMargin: Theme.padding
                anchors.top: parent.top
                anchors.topMargin: Theme.smallPadding
                color: "black"
            }
            Text {
                id: lastChatMessage
                text: lastMessage || qsTr("No messages")
                anchors.right: contactNumberChatsCircle.left
                anchors.rightMargin: Theme.smallPadding
                elide: Text.ElideRight
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Theme.smallPadding
                font.pixelSize: 15
                anchors.left: contactImage.right
                anchors.leftMargin: Theme.padding
                color: Theme.darkGrey
            }
            Text {
                id: contactTime
                text: timestamp
                anchors.right: parent.right
                anchors.rightMargin: Theme.padding
                anchors.top: parent.top
                anchors.topMargin: Theme.smallPadding
                font.pixelSize: 11
                color: Theme.darkGrey
            }
            Rectangle {
                id: contactNumberChatsCircle
                width: 22
                height: 22
                radius: 50
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Theme.smallPadding
                anchors.right: parent.right
                anchors.rightMargin: Theme.padding
                color: Theme.blue
                visible: unviewedMessagesCount > 0
                Text {
                    id: contactNumberChats
                    text: unviewedMessagesCount
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    color: "white"
                }
            }
        }
    }

    ListView {
        id: chatGroupsListView
        anchors.topMargin: 24
        anchors.fill: parent
        model: chatsModel.chats
        delegate: chatViewDelegate
    }
}