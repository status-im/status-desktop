import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../../../shared"
import "../../../../shared/status"
import "../../../../imports"
import "../components"

Rectangle {
    property string chatId: ""
    property string name: "channelName"
    property string lastMessage: "My latest message\n with a return"
    property string timestamp: "1605212622434"
    property string unviewedMessagesCount: "2"
    property string identicon
    property bool hasMentions: false
    property int chatType: Constants.chatTypePublic
    property string searchStr: ""
    property bool isCompact: appSettings.compactMode
    property int contentType: 1
    property bool muted: false
    property bool hovered: false
    property bool enableMouseArea: true

    property string profileImage: chatType === Constants.chatTypeOneToOne ? appMain.getProfileImage(chatId) || ""  : ""

    Connections {
        enabled: chatType === Constants.chatTypeOneToOne
        target: profileModel.contacts.list
        onContactChanged: {
            if (pubkey === wrapper.chatId) {
                wrapper.profileImage = appMain.getProfileImage(wrapper.chatId)
            }
        }
    }

    id: wrapper
    color: {
      if (ListView.isCurrentItem || wrapper.hovered) {
        return Style.current.secondaryBackground
      }
      return Style.current.transparent
    }
    anchors.right: parent.right
    anchors.top: applicationWindow.top
    anchors.left: parent.left
    radius: 8
    // Hide the box if it is filtered out
    property bool isVisible: searchStr === "" || name.includes(searchStr)
    visible: isVisible ? true : false
    height: isVisible ? (!isCompact ? 64 : contactImage.height + Style.current.smallPadding * 2) : 0

    StatusIdenticon {
        id: contactImage
        height: !isCompact ? 40 : 20
        width: !isCompact ? 40 : 20
        chatName: wrapper.name
        chatType: wrapper.chatType
        identicon: wrapper.profileImage || wrapper.identicon
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
        text: wrapper.chatType !== Constants.chatTypePublic ?
                  Emoji.parse(Utils.removeStatusEns(Utils.filterXSS(wrapper.name))) :
                  "#" + Utils.filterXSS(wrapper.name)
        anchors.right: contactTime.left
        anchors.rightMargin: Style.current.smallPadding
        elide: Text.ElideRight
        color: muted ? Style.current.secondaryText : Style.current.textColor
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
        text: {
            switch(contentType){
                //% "Image"
                case Constants.imageType: return qsTrId("image");
                //% "Sticker"
                case Constants.stickerType: return qsTrId("sticker");
                //% "No messages"
                default: return lastMessage ? Emoji.parse(Utils.filterXSS(lastMessage)).replace(/\n|\r/g, ' ') : qsTrId("no-messages")
            }
        }
        textFormat: Text.RichText
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
        text: Utils.formatDateTime(wrapper.timestamp, appSettings.locale)
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
            text: wrapper.hasMentions ? '@' : (wrapper.unviewedMessagesCount < 100 ? wrapper.unviewedMessagesCount : "99+")
            font.pixelSize: 12
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            color: Style.current.white
        }
    }

    MouseArea {
        enabled: enableMouseArea
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
          wrapper.hovered = true
        }
        onExited: {
          wrapper.hovered = false
        }
        onClicked: {
            if (mouse.button & Qt.RightButton) {
                channelContextMenu.openMenu(index, muted, chatType, name, chatId, identicon)
                return;
            }
            chatsModel.setActiveChannelByIndex(index)
            chatGroupsListView.currentIndex = index
        }
    }

}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";height:64;width:640}
}
##^##*/
