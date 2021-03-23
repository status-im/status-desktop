import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../shared"
import "../../../../shared/status"
import "../../../../imports"
import "../components"
import "./"

Button {
    implicitWidth: Math.max(communityImage.width + communityName.width + Style.current.padding, 200)
    implicitHeight: communityImage.height + Style.current.padding

    background: Rectangle {
        id: btnBackground
        radius: Style.current.radius
        color: Style.current.transparent
    }
    
    contentItem: Item {
        id: content
        Loader {
            id: communityImage
            anchors.verticalCenter: parent.verticalCenter
            active: true
            sourceComponent: !chatsModel.communities.activeCommunity.thumbnailImage ? letterIdenticon : imageIcon
        }

        Component {
            id: imageIcon
            RoundedImage {
                width: 40
                height: 40
                source: chatsModel.communities.activeCommunity.thumbnailImage
                noMouseArea: true
            }
        }

        Component {
            id: letterIdenticon
            StatusLetterIdenticon {
                width: 40
                height: 40
                chatName: chatsModel.communities.activeCommunity.name
                color: chatsModel.communities.activeCommunity.communityColor || Style.current.blue
            }
        }



        StyledText {
            id: communityName
            text: chatsModel.communities.activeCommunity.name
            anchors.left: communityImage.right
            anchors.leftMargin: Style.current.halfPadding
            anchors.top: parent.top
            font.pixelSize: 15
            font.weight: Font.Medium
        }

        StyledText {
            id: communityNbMember
            text: chatsModel.communities.activeCommunity.nbMembers === 1 ? 
                qsTr("1 member") : 
                qsTr("%1 members").arg(chatsModel.communities.activeCommunity.nbMembers)
            anchors.left: communityName.left
            anchors.top: communityName.bottom
            font.pixelSize: 12
            font.weight: Font.Thin
            color: Style.current.secondaryText
        }
    }

    MouseArea {
        id: mouseAreaBtn
        enabled: chatsModel.communities.activeCommunity.admin
        visible: enabled
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        onPressed: {
          communityProfilePopup.communityId = chatsModel.communities.activeCommunity.id;
          communityProfilePopup.name = chatsModel.communities.activeCommunity.name;
          communityProfilePopup.description = chatsModel.communities.activeCommunity.description;
          communityProfilePopup.access = chatsModel.communities.activeCommunity.access;
          communityProfilePopup.nbMembers = chatsModel.communities.activeCommunity.nbMembers;
          communityProfilePopup.isAdmin = chatsModel.communities.activeCommunity.admin
          communityProfilePopup.source = chatsModel.communities.activeCommunity.thumbnailImage
          communityProfilePopup.communityColor = chatsModel.communities.activeCommunity.communityColor

          communityProfilePopup.open();
        }
        hoverEnabled: true
        onExited: {
            btnBackground.color = Style.current.transparent
        }
        onEntered: {
            btnBackground.color = Style.current.backgroundHover
        }
    }
}
