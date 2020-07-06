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
    property int chatType: Constants.chatTypePublic
    property string searchStr: ""

    id: wrapper
    color: ListView.isCurrentItem ? Style.current.lightBlue : Style.current.transparent
    anchors.right: parent.right
    anchors.top: applicationWindow.top
    anchors.left: parent.left
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

    SVGImage {
        id: channelIcon
        width: 16
        height: 16
        fillMode: Image.PreserveAspectFit
        source: "../../../img/channel-icon-" + (wrapper.chatType === Constants.chatTypePublic ? "public-chat.svg" : "group.svg")
        anchors.left: contactImage.right
        anchors.leftMargin: Style.current.padding
        anchors.top: parent.top
        anchors.topMargin: Style.current.smallPadding
        visible: wrapper.chatType !== Constants.chatTypeOneToOne
    }

    StyledText {
        id: contactInfo
        text: wrapper.chatType !== Constants.chatTypePublic ? Emoji.parse(wrapper.name, "26x26") : "#" + wrapper.name
        anchors.right: contactTime.left
        anchors.rightMargin: Style.current.smallPadding
        elide: Text.ElideRight
        font.weight: Font.Medium
        font.pixelSize: 15
        anchors.left: channelIcon.visible ? channelIcon.right : contactImage.right
        anchors.leftMargin: channelIcon.visible ? 2 : Style.current.padding
        anchors.top: parent.top
        anchors.topMargin: Style.current.smallPadding
        color: "black"
    }
    
    StyledText {
        id: lastChatMessage
        text: lastMessage ? Emoji.parse(lastMessage, "26x26").replace(/\n|\r/g, ' ') : qsTr("No messages")
        clip: true // This is needed because emojis don't ellide correctly
        anchors.right: contactNumberChatsCircle.left
        anchors.rightMargin: Style.current.smallPadding
        elide: Text.ElideRight
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.current.smallPadding
        font.pixelSize: 15
        anchors.left: contactImage.right
        anchors.leftMargin: Style.current.padding
        color: Style.current.darkGrey
    }
    StyledText {
        id: contactTime
        text: {
          let now = new Date()
          let yesterday = new Date()
          yesterday.setDate(now.getDate()-1)
          let messageDate = new Date(Math.floor(wrapper.timestamp))
          let lastWeek = new Date()
          lastWeek.setDate(now.getDate()-7)

          let minutes = messageDate.getMinutes();
          let hours = messageDate.getHours();

          if (now.toDateString() == messageDate.toDateString()) {
            return (hours < 10 ? "0" + hours : hours) + ":" + (minutes < 10 ? "0" + minutes : minutes)
          } else if (yesterday.toDateString() == messageDate.toDateString()) {
            return qsTr("Yesterday")
          } else if (lastWeek.getTime() < messageDate.getTime()) {
            let days = [qsTr('Sunday'), qsTr('Monday'), qsTr('Tuesday'), qsTr('Wednesday'), qsTr('Thursday'), qsTr('Friday'), qsTr('Saturday')];
            return days[messageDate.getDay()];
          } else {
            return messageDate.getMonth()+1+"/"+messageDate.getDay()+"/"+messageDate.getFullYear()
          }
        }
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        anchors.top: parent.top
        anchors.topMargin: Style.current.smallPadding
        font.pixelSize: 11
        color: Style.current.darkGrey
    }
    Rectangle {
        id: contactNumberChatsCircle
        width: 22
        height: 22
        radius: 50
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.current.smallPadding
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        color: Style.current.blue
        visible: unviewedMessagesCount > 0
        StyledText {
            id: contactNumberChats
            text: wrapper.unviewedMessagesCount < 100 ? wrapper.unviewedMessagesCount : "99"
            font.pixelSize: 12
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
