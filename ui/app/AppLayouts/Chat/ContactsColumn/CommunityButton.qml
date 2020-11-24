import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../../../shared"
import "../../../../shared/status"
import "../../../../imports"
import "../components"

Rectangle {
    property string communityId: ""
    property string name: "channelName"
    property string unviewedMessagesCount: "2"
    property string image: "../../../img/ens-header-dark@2x.png"
    property bool hasMentions: false
    property string searchStr: ""
    property bool isCompact: appSettings.compactMode
    property bool hovered: false

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
    radius: Style.current.radius
    // Hide the box if it is filtered out
    property bool isVisible: searchStr === "" || name.includes(searchStr)
    visible: isVisible ? true : false
    height: isVisible ? !isCompact ? 64 : communityImage.height + Style.current.smallPadding * 2 : 0

    RoundedImage {
        id: communityImage
        height: !isCompact ? 40 : 20
        width: !isCompact ? 40 : 20
        source: wrapper.image
        anchors.left: parent.left
        anchors.leftMargin: !isCompact ? Style.current.padding : Style.current.smallPadding
        anchors.verticalCenter: parent.verticalCenter
    }

    StyledText {
        id: contactInfo
        text: wrapper.name
        anchors.right: contactNumberChatsCircle.left
        anchors.rightMargin: Style.current.smallPadding
        elide: Text.ElideRight
        font.weight: Font.Medium
        font.pixelSize: 15
        anchors.left: communityImage.right
        anchors.leftMargin: Style.current.padding
        anchors.verticalCenter: parent.verticalCenter
    }

    Rectangle {
        id: contactNumberChatsCircle
        width: 22
        height: 22
        radius: 50
        anchors.right: parent.right
        anchors.rightMargin: !isCompact ? Style.current.padding : Style.current.smallPadding
        anchors.verticalCenter: parent.verticalCenter
        color: Style.current.primary
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

    MouseArea {
        cursorShape: Qt.PointingHandCursor
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
            console.log("Open community")
            chatsModel.setActiveCommunity(communityId)
        }
    }

}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";height:64;width:640}
}
##^##*/
