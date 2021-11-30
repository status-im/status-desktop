import QtQuick 2.13
import QtQuick.Controls 2.13
import shared 1.0
import shared.panels 1.0

import utils 1.0

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1

StatusListItem {
    id: root
    anchors.right: parent.right
    anchors.rightMargin: 8
    anchors.left: parent.left
    anchors.leftMargin: 8
    implicitHeight: 44
    leftPadding: 8
    rightPadding: 8

    property var contactsList
    property int statusType: -1
    property string name: ""
    property string publicKey: ""
    property string profilePubKey: ""
    property string identicon: ""
    property bool isCurrentUser: (publicKey === profilePubKey)
    property string profileImage: appMain.getProfileImage(publicKey) || ""
    property bool highlighted: false
    property string lastSeen: ""
    property bool isOnline: false
    property var currentTime
    property var messageContextMenu


    title: isCurrentUser ? qsTr("You") : Emoji.parse(Utils.removeStatusEns(Utils.filterXSS(root.name)))
    image.source: profileImage || identicon
    image.isIdenticon: !profileImage
    image.width: 24
    image.height: 24
    statusListItemIcon.anchors.topMargin: 10
    statusListItemTitle.elide: Text.ElideRight
    statusListItemTitle.wrapMode: Text.NoWrap
    color: sensor.containsMouse ? 
        Theme.palette.statusChatListItem.hoverBackgroundColor : 
        Theme.palette.baseColor4

    sensor.onClicked: {
        if (mouse.button === Qt.LeftButton) {
            //TODO remove dynamic scoping
            openProfilePopup(root.name, root.publicKey, (root.profileImage || root.identicon), "", appMain.getUserNickname(root.publicKey));
        }
          else if (mouse.button === Qt.RightButton && !!messageContextMenu) {
            // Set parent, X & Y positions for the messageContextMenu
            messageContextMenu.parent = root
            messageContextMenu.setXPosition = function() { return 0}
            messageContextMenu.setYPosition = function() { return root.height}
            messageContextMenu.isProfile = true;
            messageContextMenu.show(root.name, root.publicKey, (root.profileImage || root.identicon), "", appMain.getUserNickname(root.publicKey))
        }
    }

    Connections {
        enabled: !!root.contactsList
        target: root.contactsList
        onContactChanged: {
            if (pubkey === root.publicKey) {
                root.profileImage = !!appMain.getProfileImage(root.publicKey) ?
                            appMain.getProfileImage(root.publicKey) : ""
            }
        }
    }

    StatusBadge {
        id: statusBadge
        width: 15
        height: 15
        anchors.left: parent.left
        anchors.leftMargin: 22
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 6
        visible: root.isOnline && !((root.statusType === -1) && (lastSeenMinutesAgo > 7))
        border.width: 3
        border.color: root.sensor.containsMouse ? Theme.palette.baseColor2 : Theme.palette.baseColor4
        property real lastSeenMinutesAgo: ((currentTime/1000 - parseInt(lastSeen)) / 60);
        color: {
            if (visible) {
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
}
