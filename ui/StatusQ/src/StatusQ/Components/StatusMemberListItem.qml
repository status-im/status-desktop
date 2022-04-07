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
       \qmlproperty string StatusMemberListItem::chatKey
       This property holds the chat key of the member represented.
    */
    property string chatKey: ""
    /*!
       \qmlproperty string StatusMemberListItem::isMutualContact
       This property holds if the member represented is a mutual contact.
    */
    property bool isMutualContact: false
    /*!
       \qmlproperty string StatusMemberListItem::trustIndicator
       This property holds the trust indicator of the member represented. Possible values are:
       \list
       \li StatusContactVerificationIcons.TrustedType.None
       \li StatusContactVerificationIcons.TrustedType.Verified
       \li StatusContactVerificationIcons.TrustedType.Untrustworthy
       \endlist
    */
    property var trustIndicator: StatusContactVerificationIcons.TrustedType.None
    /*!
       \qmlproperty string StatusMemberListItem::isOnline
       This property holds the connectivity status of the member represented.
    */
    property bool isOnline: false

    QtObject {
        id: d

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
    }

    // root object settings:
    title: root.nickName
    statusListItemTitleIcons.sourceComponent: StatusContactVerificationIcons {
        isMutualContact: root.isMutualContact
        trustIndicator: root.trustIndicator
    }
    subTitle: d.composeSubtitile()
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
