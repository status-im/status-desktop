import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1

/*!
   \qmltype StatusMemberListItem
   \inherits ItemDelegate
   \inqmlmodule StatusQ.Components
   \since StatusQ.Components 0.1
   \brief It is a list item with a specific format to display members of a community or chat. Inherits from \c ItemDelegate.

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
ItemDelegate {
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
       \qmlproperty bool StatusMemberListItem::isContact
       This property holds if the member represented is contact.
    */
    property bool isContact: false
    /*!
       \qmlproperty bool StatusMemberListItem::isVerified
       This property holds if the member represented is verified contact.
    */
    property bool isVerified: false
    /*!
       \qmlproperty bool StatusMemberListItem::isUntrustworthy
       This property holds if the member represented is untrustworthy.
    */
    property bool isUntrustworthy: false
    /*!
       \qmlproperty bool StatusMemberListItem::isBlocked
       This property holds if the member represented is blocked.
    */
    property bool isBlocked: false
    /*!
       \qmlproperty int StatusMemberListItem::status
       This property holds the connectivity status of the member represented.

    int unknown: -1
    int inactive: 0
    int online: 1

    */
    // FIXME: move Constants.onlineStatus from status-desktop
    property int status: 0
    /*!
       \qmlproperty bool StatusMemberListItem::isAdmin
       This property holds the admin status of the member represented.
    */
    property bool isAdmin: false

    /*!
       \qmlproperty bool StatusMemberListItem::isAwaitingAddress
       This property indicate if member shared his addresses
    */
    property bool isAwaitingAddress: false

    /*!
       \qmlproperty color StatusMemberListItem::color
       Defines the background color of the delegate
    */
    property color color: hovered || highlighted ? Theme.palette.baseColor2 : Theme.palette.baseColor4

    /*!
       \qmlproperty list<Item> StatusMemberListItem::components
       This property holds the optional list of actions, displayed on the right side.
       The actions are reparented into a Row.
    */
    property alias components: componentsRow.children

    /*!
       \qmlproperty StatusIdenticonRingSettings StatusMemberListItem::ringSettings
       This property holds the StatusSmartIdenticon ring settings
    */
    property alias ringSettings: identicon.ringSettings

    /*!
       \qmlproperty StatusBadge StatusMemberListItem::badge
       This property holds the StatusBadge used for displaying user's online status
    */
    property alias badge: identicon.badge

    /*!
        \qmlsignal rightClicked
        This signal is emitted when the StatusMemberListItem is right clicked.
    */
    signal rightClicked

    QtObject {
        id: d

        // Subtitle composition:
        function composeSubtitle() {
            var compose = ""
            if(root.userName !== "" && root.nickName !== "")
                compose = "(" + Emoji.parse(root.userName, "12x12") + ")"

            if(compose !== "" && root.pubKey !== "")
                // Composition
                compose += " • " + composeShortKeyChat(root.pubKey)

            else if(root.pubKey !== "")
                compose = composeShortKeyChat(root.pubKey)

            return compose
        }

        // Short keychat composition:
        function composeShortKeyChat(pubKey) {
            if (!pubKey)
                return ""
            return Utils.elideText(pubKey, 3, 6)
        }
    }

    horizontalPadding: Theme.halfPadding
    verticalPadding: 12
    spacing: Theme.halfPadding

    icon.width: 32
    icon.height: 32

    font.family: Theme.baseFont.name
    font.pixelSize: Theme.primaryTextFontSize

    background: Rectangle {
        color: root.color
        radius: Theme.radius
    }

    HoverHandler {
       cursorShape: root.enabled && root.hoverEnabled && root.hovered ? Qt.PointingHandCursor : undefined
    }

    TapHandler {
        acceptedButtons: Qt.RightButton
        onTapped: root.rightClicked()
    }

    contentItem: RowLayout {
        spacing: root.spacing

        StatusSmartIdenticon {
            id: identicon

            name: root.nickName || root.userName

            asset.name: root.icon.name
            asset.color: root.icon.color
            asset.isImage: asset.name !== ""
            asset.isLetterIdenticon: asset.name === ""
            asset.width: root.icon.width
            asset.height: root.icon.height
            asset.charactersLen: 2
            asset.letterSize: asset._twoLettersSize

            // badge
            badge.visible: true
            badge.color: root.status === 1 ? Theme.palette.successColor1 : Theme.palette.baseColor1 // FIXME, see root.status
            badge.border.width: 2
            badge.border.color: root.hovered ? Theme.palette.statusBadge.hoverBorderColor : Theme.palette.statusBadge.borderColor
            badge.implicitHeight: 12 // 8 px + 2 px * 2 borders
            badge.implicitWidth: 12 // 8 px + 2 px * 2 borders
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 4
            Row {
                spacing: 4
                Layout.fillWidth: true
                StatusBaseText {
                    width: Math.min(implicitWidth, parent.width - (iconsLoader.item ? iconsLoader.item.width + parent.spacing : 0))
                    anchors.verticalCenter: parent.verticalCenter
                    elide: Text.ElideRight
                    text: root.nickName || Emoji.parse(root.userName)
                    font.pixelSize: root.font.pixelSize
                    font.weight: Font.Medium
                    color: Theme.palette.directColor4

                    HoverHandler {
                        id: primaryTextHandler
                    }

                    StatusToolTip {
                        text: parent.text
                        delay: 50
                        visible: parent.truncated && primaryTextHandler.hovered
                    }
                }
                Loader {
                    id: iconsLoader
                    anchors.verticalCenter: parent.verticalCenter
                    sourceComponent: root.isAwaitingAddress ? awaitingAddressComponent : statusContactVerificationIcons
                }
            }
            StatusBaseText {
                Layout.fillWidth: true
                elide: Text.ElideRight
                text: d.composeSubtitle()
                font.pixelSize: Theme.asideTextFontSize
                color: Theme.palette.baseColor1
                visible: !!text

                HoverHandler {
                    id: secondaryTextHandler
                }

                StatusToolTip {
                    text: parent.text
                    delay: 50
                    visible: parent.truncated && secondaryTextHandler.hovered
                }
            }
        }

        Row {
            id: componentsRow
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            spacing: 12
        }

        Loader {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            active: root.isAdmin
            sourceComponent: StatusIcon {
                anchors.verticalCenter: parent.verticalCenter
                icon: "crown"
                color: Theme.palette.directColor1
            }
        }
    }

    Component {
        id: statusContactVerificationIcons
        StatusContactVerificationIcons {
            isContact: root.isContact
            isBlocked: root.isBlocked
            trustIndicator: {
                if (root.isVerified)
                    return StatusContactVerificationIcons.TrustedType.Verified
                if (root.isUntrustworthy)
                    return StatusContactVerificationIcons.TrustedType.Untrustworthy
                return StatusContactVerificationIcons.TrustedType.None
            }
        }
    }

    Component {
        id: awaitingAddressComponent
        StatusIcon {
            width: 16
            height: 16

            color: Theme.palette.baseColor1
            icon: "sandwatch"
        }
    }
}
