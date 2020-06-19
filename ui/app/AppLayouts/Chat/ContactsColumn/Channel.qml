import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../../../shared"
import "../../../../imports"
import "../components"

Rectangle {
    property string name: "channelName"
    property string lastMessage: "My latest message\n with a return"
    property string timestamp: "20/2/2020"
    property string unviewedMessagesCount: "2"
    property string chatType: Constants.chatTypePublic
    property string searchStr: ""

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

    ChannelIcon {
      id: contactImage
      height: 40
      width: 40
      topMargin: 12
      bottomMargin: 12
      channelName: wrapper.name
      channelType: wrapper.chatType
      channelIdenticon: identicon
    }

    Image {
        id: channelIcon
        width: 16
        height: 16
        fillMode: Image.PreserveAspectFit
        source: "../../../img/channel-icon-" + (wrapper.chatType === Constants.chatTypePublic ? "public-chat.svg" : "group.svg")
        anchors.left: contactImage.right
        anchors.leftMargin: Theme.padding
        anchors.top: parent.top
        anchors.topMargin: Theme.smallPadding
        visible: chatType !== Constants.chatTypeOneToOne
    }

    StyledText {
        id: contactInfo
        text: wrapper.chatType !== Constants.chatTypePublic ? wrapper.name : "#" + wrapper.name
        anchors.right: contactTime.left
        anchors.rightMargin: Theme.smallPadding
        elide: Text.ElideRight
        font.weight: Font.Medium
        font.pixelSize: 15
        anchors.left: channelIcon.visible ? channelIcon.right : contactImage.right
        anchors.leftMargin: channelIcon.visible ? 2 : Theme.padding
        anchors.top: parent.top
        anchors.topMargin: Theme.smallPadding
        color: "black"
    }
    
    StyledText {
        id: lastChatMessage
        text: lastMessage ? lastMessage.replace(/\n|\r/g, ' ') : qsTr("No messages")
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
    StyledText {
        id: contactTime
        text: wrapper.timestamp
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
        StyledText {
            id: contactNumberChats
            text: wrapper.unviewedMessagesCount
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            color: "white"
        }
    }
}





/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";height:64;width:640}
}
##^##*/
