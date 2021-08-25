import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../../../shared"
import "../../../../shared/status"
import "../../../../imports"
import "../components"

Item {
    id: wrapper
    anchors.right: parent.right
    anchors.top: applicationWindow.top
    anchors.left: parent.left
    height: rectangle.height + 4

    property string publicKey: ""
    property string name: "channelName"
    property string lastSeen: ""
    property string identicon
    property int statusType: -1
    property bool hovered: false
    property bool enableMouseArea: true
    property bool isOnline: chatsModel.isOnline
    property var currentTime
    property color color: {
        if (wrapper.hovered) {
            return Style.current.menuBackgroundHover
        }
        return Style.current.transparent
    }
    property string profileImage: appMain.getProfileImage(publicKey) || ""
    property bool isCurrentUser: publicKey === profileModel.profile.pubKey

    Rectangle {
        id: rectangle
        width: parent.width
        height: 40
        radius: 8
        color: wrapper.color
        Connections {
            target: profileModel.contacts.list
            onContactChanged: {
                if (pubkey === wrapper.publicKey) {
                    wrapper.profileImage = appMain.getProfileImage(wrapper.publicKey)
                }
            }
        }

        StatusIdenticon {
            id: contactImage
            height: 28
            width: 28
            chatId: wrapper.publicKey
            chatName: wrapper.name
            chatType: Constants.chatTypeOneToOne
            identicon: wrapper.profileImage || wrapper.identicon
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding
            anchors.verticalCenter: parent.verticalCenter
        }

        StyledText {
            id: contactInfo
            text: Emoji.parse(Utils.removeStatusEns(Utils.filterXSS(wrapper.name))) + (isCurrentUser ? " " + qsTrId("(you)") : "")
            anchors.right: parent.right
            anchors.rightMargin: Style.current.smallPadding
            elide: Text.ElideRight
            color: Style.current.textColor
            font.weight: Font.Medium
            font.pixelSize: 15
            anchors.left: contactImage.right
            anchors.leftMargin: Style.current.halfPadding
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            width: 10
            height: 10
            radius: (width/2)
            anchors.left: contactImage.right
            anchors.leftMargin: -Style.current.smallPadding
            anchors.bottom: contactImage.bottom
            visible: wrapper.isOnline
            color: {
                if (visible) {
                    var lastSeenMinutesAgo = ((currentTime/1000 - parseInt(lastSeen)) / 60);
                    if (statusType === Constants.statusType_DoNotDisturb) {
                        return Style.current.red;
                    } else if (isCurrentUser || (lastSeenMinutesAgo < 5.5)) {
                        return Style.current.green;
                    } else if (((statusType !== -1) && (lastSeenMinutesAgo > 5.5)) ||
                               ((statusType === -1) && (lastSeenMinutesAgo < 7))) {
                        return Style.current.orange;
                    } else if ((statusType === -1) && (lastSeenMinutesAgo > 7)) {
                        return "transparent";
                    }
                } else {
                    return "transparent";
                }
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
                if (mouse.button === Qt.LeftButton) {
                    openProfilePopup(wrapper.name, wrapper.publicKey, (wrapper.profileImage || wrapper.identicon), "", appMain.getUserNickname(wrapper.publicKey));
                }
                 else if (mouse.button === Qt.RightButton) {
                    // Set parent, X & Y positions for the messageContextMenu
                    messageContextMenu.parent = rectangle
                    messageContextMenu.setXPosition = function() { return 0}
                    messageContextMenu.setYPosition = function() { return rectangle.height}
                    messageContextMenu.isProfile = true;
                    messageContextMenu.show(wrapper.name, wrapper.publicKey, (wrapper.profileImage || wrapper.identicon), "", appMain.getUserNickname(wrapper.publicKey))
                }
            }
        }

    }
}



/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";height:64;width:640}
}
##^##*/
