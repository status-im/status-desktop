import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../../../shared"
import "../../../../shared/status"
import "../../../../imports"
import "../components"

Rectangle {
    property string communityId: ""
    property string name: "channelName"
    property string description: "channel description"
    property string unviewedMessagesCount: "0"
    property string image: "../../../img/ens-header-dark@2x.png"
    property bool hasMentions: false
    property string searchStr: ""
    property bool isCompact: appSettings.useCompactMode
    property bool hovered: false

    id: communityButton
    color: {
      if (communityButton.hovered) {
        return Style.current.secondaryBackground
      }
      return Style.current.background
    }
    anchors.right: parent.right
    anchors.top: applicationWindow.top
    anchors.left: parent.left
    radius: Style.current.radius
    // Hide the box if it is filtered out
    property bool isVisible: searchStr === "" ||
                             communityButton.name.toLowerCase().includes(searchStr) ||
                             communityButton.description.toLowerCase().includes(searchStr)
    visible: isVisible ? true : false
    height: isVisible ? !isCompact ? 64 : communityImage.height + Style.current.smallPadding * 2 : 0

    RoundedImage {
        id: communityImage
        height: !isCompact ? 40 : 20
        width: !isCompact ? 40 : 20
        source: communityButton.image
        anchors.left: parent.left
        anchors.leftMargin: !isCompact ? Style.current.padding : Style.current.smallPadding
        anchors.verticalCenter: parent.verticalCenter
    }

    StyledText {
        id: contactInfo
        text: communityButton.name
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
        visible: (unviewedMessagesCount > 0) || communityButton.hasMentions
        StyledText {
            id: contactNumberChats
            text: communityButton.hasMentions ? '@' : (communityButton.unviewedMessagesCount < 100 ? communityButton.unviewedMessagesCount : "99")
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
          communityButton.hovered = true
        }
        onExited: {
          communityButton.hovered = false
        }
        onClicked: {
            chatsModel.setActiveCommunity(communityId)
        }
    }

}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";height:64;width:640}
}
##^##*/
