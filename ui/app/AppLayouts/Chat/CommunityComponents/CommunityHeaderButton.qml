import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../shared"
import "../../../../imports"
import "../components"
import "./"

Button {
    implicitWidth: Math.max(communityImage.width + communityName.width + Style.current.padding, 200)
    implicitHeight: communityImage.height + Style.current.padding

    background: Rectangle {
        id: btnBackground
        radius: Style.current.radius
    }
    
    contentItem: Item {
        id: content
        RoundedImage {
            id: communityImage
            width: 40
            height: 40
            // TODO get the real image once it's available
            source: "../../../img/ens-header-dark@2x.png"
            anchors.verticalCenter: parent.verticalCenter
        }

        StyledText {
            id: communityName
            text: chatsModel.activeCommunity.name
            anchors.left: communityImage.right
            anchors.leftMargin: Style.current.halfPadding
            anchors.top: parent.top
            font.pixelSize: 15
            font.weight: Font.Medium
        }

        StyledText {
            id: communityNbMember
            text: chatsModel.activeCommunity.nbMembers === 1 ? 
                qsTr("1 member") : 
                qsTr("%1 members").arg(chatsModel.activeCommunity.nbMembers)
            anchors.left: communityName.left
            anchors.top: communityName.bottom
            font.pixelSize: 12
            font.weight: Font.Thin
            color: Style.current.secondaryText
        }
    }

    MouseArea {
        id: mouseAreaBtn
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        onPressed: communityProfilePopup.open();
        hoverEnabled: true
        onExited: {
            btnBackground.color = "transparent"
        }
        onEntered: {
            btnBackground.color = Style.current.topBarChatInfoColor
        }
    }
}