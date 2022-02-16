import QtQuick 2.0
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1


StatusListItem {
    id: root

    property string nickName: ""
    property string userName: ""
    property string chatKey: ""
    property bool isMutualContact: false
    property var trustIndicator: StatusContactVerificationIcons.TrustedType.None
    property bool isOnline: false

    // Subtitle composition:
    function composeSubtitile() {
        var compose = ""
        if(root.userName !== "")
            compose = "(" + root.userName + ")"

        if(compose !== "" && root.chatKey !== "")
            // Composition
            compose += " • " + composeShortKeyChat(root.chatKey)

        else if(root.chatKey !== "")
            compose = composeShortKeyChat(root.chatKey)

        return compose
    }

    // Short keychat composition:
    function composeShortKeyChat(chatKey) {
        return chatKey.substring(0, 5) + "..." + chatKey.substring(chatKey.length - 3)
    }

    // root object settings:
    title: root.nickName
    statusListItemTitleIcons.sourceComponent: StatusContactVerificationIcons {
        isMutualContact: root.isMutualContact
        trustIndicator: root.trustIndicator
    }
    subTitle: composeSubtitile()
    statusListItemSubTitle.font.pixelSize: 10
    icon.isLetterIdenticon: !root.image.source.toString()
    statusListItemIcon.badge.visible: true
    statusListItemIcon.badge.color: root.isOnline ? Theme.palette.successColor1 : Theme.palette.baseColor1
    color: sensor.containsMouse ? Theme.palette.baseColor2 : Theme.palette.baseColor4

    // Default sizes / positions by design
    implicitWidth: 256
    implicitHeight: Math.max(56, statusListItemTitleArea.height + leftPadding)
    leftPadding: 8
    image.width: 32
    image.height: 32
    icon.width: 32
    icon.height: 32
    statusListItemIcon.anchors.verticalCenter: sensor.verticalCenter
    statusListItemIcon.anchors.top: undefined
    statusListItemIcon.badge.border.width: 2
    statusListItemIcon.badge.implicitHeight: 12 // 8 px + 2 px * 2 borders
    statusListItemIcon.badge.implicitWidth: 12 // 8 px + 2 px * 2 borders
}
