import QtQuick 2.0
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1


StatusListItem {
    id: root

    property string nickName: ""
    property string userName: ""
    property string chatKey: ""
    property bool isMutualContact: false
    property var trustIndicator: StatusMemberListItem.TrustedType.None
    property bool isOnline: false

    enum TrustedType {
        None, //0
        Verified, //1
        Untrustworthy //2
    }

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
    titleIcon1Visible: root.isMutualContact
    titleIcon2Visible: root.trustIndicator !== StatusMemberListItem.TrustedType.None
    subTitle: composeSubtitile()
    statusListItemSubTitle.font.pixelSize: 10
    icon.isLetterIdenticon: !root.image.source.toString()
    statusListItemIcon.badge.visible: true
    statusListItemIcon.badge.color: root.isOnline ? Theme.palette.successColor1 : Theme.palette.baseColor1
    color: sensor.containsMouse ? Theme.palette.baseColor2 : Theme.palette.baseColor4

    // Default sizes/positions by design
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

    // Trusted type icons definition:
    titleIcon1.name: "tiny/tiny-contact"
    titleIcon1.color: Theme.palette.indirectColor1
    titleIcon1.background.color: Theme.palette.primaryColor1
    // None and Untrustworthy types, same aspect (Icon will not be visible in case of None type):
    titleIcon2.name: trustIndicator === StatusMemberListItem.TrustedType.Verified ? "tiny/tiny-checkmark" : "tiny/subtract"
    titleIcon2.color: Theme.palette.indirectColor1
    titleIcon2.background.color: trustIndicator === StatusMemberListItem.TrustedType.Verified ? Theme.palette.primaryColor1 : Theme.palette.dangerColor1
}
