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
    property bool hasMentions: false
    property int chatType: Constants.chatTypePublic
    property string searchStr: ""
    property bool isCompact: appSettings.compactMode

    id: wrapper
    color: ListView.isCurrentItem ? Style.current.secondaryBackground : Style.current.transparent
    anchors.right: parent.right
    anchors.top: applicationWindow.top
    anchors.left: parent.left
    radius: 8
    // Hide the box if it is filtered out
    property bool isVisible: searchStr == "" || name.includes(searchStr)
    visible: isVisible ? true : false
    height: isVisible ? !isCompact ? 64 : contactImage.height + Style.current.smallPadding * 2 : 0

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
      height: !isCompact ? 40 : 20
      width: !isCompact ? 40 : 20
      fontSize: !isCompact ? this.defaultFontSize : 14
      channelName: wrapper.name
      channelType: wrapper.chatType
      channelIdenticon: identicon
      anchors.left: parent.left
      anchors.leftMargin: !isCompact ? Style.current.padding : Style.current.smallPadding
      anchors.verticalCenter: parent.verticalCenter
    }

    SVGImage {
        id: channelIcon
        width: 16
        height: 16
        fillMode: Image.PreserveAspectFit
        source: "../../../img/channel-icon-" + (wrapper.chatType === Constants.chatTypePublic ? "public-chat.svg" : "group.svg")
        anchors.left: contactImage.right
        anchors.leftMargin: Style.current.padding
        anchors.top: !isCompact ? parent.top : undefined
        anchors.topMargin: !isCompact ? Style.current.smallPadding : 0
        anchors.verticalCenter: !isCompact ? undefined : parent.verticalCenter
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
        anchors.top: !isCompact ? parent.top : undefined
        anchors.topMargin: !isCompact ? Style.current.smallPadding : 0
        anchors.verticalCenter: !isCompact ? undefined : parent.verticalCenter
    }
    
    StyledText {
        id: lastChatMessage
        visible: !isCompact
        //% "No messages"
        text: lastMessage ? Emoji.parse(lastMessage, "26x26").replace(/\n|\r/g, ' ') : qsTrId("no-messages")
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

            if (now.toDateString() === messageDate.toDateString()) {
                return (hours < 10 ? "0" + hours : hours) + ":" + (minutes < 10 ? "0" + minutes : minutes)
            } else if (yesterday.toDateString() === messageDate.toDateString()) {
                //% "Yesterday"
                return qsTrId("yesterday")
            } else if (lastWeek.getTime() < messageDate.getTime()) {
                //% "Sunday"
                let days = [qsTrId("sunday"),
                            //% "Monday"
                            qsTrId("monday"),
                            //% "Tuesday"
                            qsTrId("tuesday"),
                            //% "Wednesday"
                            qsTrId("wednesday"),
                            //% "Thursday"
                            qsTrId("thursday"),
                            //% "Friday"
                            qsTrId("friday"),
                            //% "Saturday"
                            qsTrId("saturday")];
                return days[messageDate.getDay()];
            } else {
                return messageDate.getMonth()+1+"/"+messageDate.getDay()+"/"+messageDate.getFullYear()
            }
            }
            anchors.right: parent.right
            anchors.rightMargin: !isCompact ? Style.current.padding : Style.current.smallPadding
            anchors.top: !isCompact ? parent.top : undefined
            anchors.topMargin: !isCompact ? Style.current.smallPadding : 0
            anchors.verticalCenter: !isCompact ? undefined : parent.verticalCenter
            font.pixelSize: 11
            color: Style.current.darkGrey
    }
    Rectangle {
        id: contactNumberChatsCircle
        width: 22
        height: 22
        radius: 50
        anchors.right: !isCompact ? parent.right : contactTime.left
        anchors.rightMargin: !isCompact ? Style.current.padding : Style.current.smallPadding
        anchors.bottom: !isCompact ? parent.bottom : undefined
        anchors.bottomMargin: !isCompact ? Style.current.smallPadding : 0
        anchors.verticalCenter: !isCompact ? undefined : parent.verticalCenter
        color: Style.current.blue
        visible: (unviewedMessagesCount > 0) || wrapper.hasMentions
        StyledText {
            id: contactNumberChats
            text: wrapper.hasMentions ? '@' : (wrapper.unviewedMessagesCount < 100 ? wrapper.unviewedMessagesCount : "99")
            font.pixelSize: 12
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            color: Style.current.white
        }
    }
}





/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";height:64;width:640}
}
##^##*/
