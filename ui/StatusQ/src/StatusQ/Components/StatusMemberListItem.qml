import QtQuick 2.0
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1

/*!
   \qmltype StatusMemberListItem
   \inherits StatusListItem
   \inqmlmodule StatusQ.Components
   \since StatusQ.Components 0.1
   \brief It is a list item with a specific format to display members of a community or chat. Inherits from  \c StatusListItem.

   The \c StatusMemberListItem is a clickable / hovering list item with a specific format to display members of a community or chat.

   It displays the member avatar, trust and mutual contact indicators, nick name, user name, chat key and information about the member connectivity.

   Example of how the control looks like:
   \image status_member_list_item.png

   Example of how to use it:

   \qml
        StatusMemberListItem {
            nickName: "carmen.eth"
            isOnline: false
            trustIndicator: StatusContactVerificationIcons.TrustedType.Untrustworthy
        }

        StatusMemberListItem {
            nickName: "This girl I know from work"
            userName: "annabelle"
            isOnline: true
        }
   \endqml

   For a list of components available see StatusQ.
*/
StatusListItem {
    id: root

    /*!
       \qmlproperty string StatusMemberListItem::nickName
       This property holds the nick name of the member represented.
    */
    property string nickName: ""
    /*!
       \qmlproperty string StatusMemberListItem::userName
       This property holds the user name of the member represented.
    */
    property string userName: ""
    /*!
       \qmlproperty string StatusMemberListItem::pubKey
       This property holds the chat public key of the member represented.
    */
    property string pubKey: ""
    /*!
       \qmlproperty string StatusMemberListItem::isContact
       This property holds if the member represented is contact.
    */
    property bool isContact: false
    /*!
       \qmlproperty string StatusMemberListItem::isVerified
       This property holds if the member represented is verified contact.
    */
    property bool isVerified: false
    /*!
       \qmlproperty string StatusMemberListItem::isUntrustworthy
       This property holds if the member represented is untrustworthy.
    */
    property bool isUntrustworthy: false
    /*!
       \qmlproperty string StatusMemberListItem::status
       This property holds the connectivity status of the member represented.
       0 - offline
       1 - online
       2 - doNotDisturb
       3 - idle
    */
    // FIXME: move Constants.userStatus from status-desktop
    property int status: 0
    /*!
       \qmlproperty string StatusMemberListItem::isAdmin
       This property holds the admin status of the member represented.
    */
    property bool isAdmin: false

    QtObject {
        id: d

        // Subtitle composition:
        function composeSubtitile() {
            var compose = ""
            if(root.userName !== "" && root.nickName !== "")
                compose = "(" + root.userName + ")"

            if(compose !== "" && root.pubKey !== "")
                // Composition
                compose += " • " + composeShortKeyChat(root.pubKey)

            else if(root.pubKey !== "")
                compose = composeShortKeyChat(root.pubKey)

            return compose
        }

        // Short keychat composition:
        function composeShortKeyChat(pubKey) {
            return pubKey.substring(0, 5) + "..." + pubKey.substring(pubKey.length - 3)
        }
    }

    // root object settings:
    title: (root.nickName === "") ? root.userName : root.nickName
    statusListItemTitleIcons.sourceComponent: StatusContactVerificationIcons {
        isContact: root.isContact
        trustIndicator: {
            if (root.isVerified) return StatusContactVerificationIcons.TrustedType.Verified
            else if (root.isUntrustworthy) return StatusContactVerificationIcons.TrustedType.Untrustworthy
            return StatusContactVerificationIcons.TrustedType.None
        } 
    }
    subTitle: d.composeSubtitile()
    statusListItemSubTitle.font.pixelSize: 10
    icon.isLetterIdenticon: !root.image.source.toString()
    statusListItemIcon.badge.visible: true
    statusListItemIcon.badge.color: root.status === 1 ? Theme.palette.successColor1 : Theme.palette.baseColor1 // FIXME
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
    components: [
        StatusIcon {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.isAdmin
            icon: "crown"
            color: Theme.palette.directColor1
        }
    ]
}
