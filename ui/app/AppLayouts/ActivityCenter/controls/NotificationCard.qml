// NotificationCard.qml
// API summary:
// - Data: username, userId, verified, avatarSource, community, channel,
//          actionIconSource, actionText, content, timestampText, unread
// - Style/sizing: density, maxContentLines, cornerRadius, spacing, paddings
// - Interactions: clicked(), avatarClicked(), actionClicked(), linkActivated(url)
// - Slots: markAsRead(), toggleUnread()

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls

import StatusQ.Core.Theme
import StatusQ.Components
import StatusQ.Core

import utils

Item {
    id: root
    clip: true

    // ──────────────────────────────────────────────────────────────────────────
    // API
    // ──────────────────────────────────────────────────────────────────────────

    // ──────────────────────────────────────────────────────────────────────────
    // Avatar parameters
    // ──────────────────────────────────────────────────────────────────────────

    // Content image URL
    property url    avatarSource: ""

    // Optional badge icon name (empty → hidden)
    property url    badgeIconName: ""

    // When true, render avatar as a circle using a mask.
    // When false, shows the image provided.
    property bool   isCircularAvatar: true

    // ──────────────────────────────────────────────────────────────────────────
    // Header parameters
    // ──────────────────────────────────────────────────────────────────────────

    // Titile (truncated to maxTitleChars)
    property string title: ""

    // Chat key (formatted as prefix…suffix)
    property string chatKey: ""

    // Show "is contact" badge if true
    property bool   isContact: false

    // Trust level indicator (0 = none). Expected values: StatusContactVerificationIcons.TrustedType
    property int    trustedIndicator: 0

    // ──────────────────────────────────────────────────────────────────────────
    // Context row parameters
    // ──────────────────────────────────────────────────────────────────────────

    // Main and secondary labels (e.g., Community and #channel)
    property string primaryText
    property string secondaryText

    // Optional icons
    property string separatorIconName   // Leading icon (hidden if empty)
    property string iconName            // Separator icon between labels

    // ──────────────────────────────────────────────────────────────────────────
    // Action and meta data  parameters
    // ──────────────────────────────────────────────────────────────────────────

    property string actionText: ""            // Short hint after context row
    property string timestampText: ""         // falls back to "Just now" if empty

    // ──────────────────────────────────────────────────────────────────────────
    // Content  parameters
    // ──────────────────────────────────────────────────────────────────────────

    property string content: ""               // supports RichText if contentIsRichText = true
    property bool   contentIsRichText: true
    property int    maxContentLines: 4
    property url    preImageSource: ""
    property var    attachments: []

    // ──────────────────────────────────────────────────────────────────────────
    // Card states
    // ──────────────────────────────────────────────────────────────────────────

    required property bool unread
    property bool          selected

    // ──────────────────────────────────────────────────────────────────────────
    // Style / layout
    // ──────────────────────────────────────────────────────────────────────────

    property real   density: 1.0
    property real   cornerRadius: 14 * density
    property real   gap: 8 * density
    property real   horizontalPadding: 14 * density
    property real   verticalPadding: 12 * density

    // ──────────────────────────────────────────────────────────────────────────
    // Colors (Theme-driven)
    // ──────────────────────────────────────────────────────────────────────────

    // Unread indicator dot color
    property color  unreadDotColor: Theme.palette.primaryColor1

    // Fixed size of unread indicator dot (diameter)
    readonly property int unreadBadgeSize: 18

    // ──────────────────────────────────────────────────────────────────────────
    // Interactions
    // ──────────────────────────────────────────────────────────────────────────
    signal clicked()

    QtObject {
        id: d
        readonly property int avatarSize: 36 * root.density
        readonly property int actionIconSize: 18 * root.density
        readonly property int readUnreadBadgeSize: 8
    }

    // Sane implicit size and default size
    implicitWidth: 420 * density
    implicitHeight: Math.max(72 * density, contentCol.implicitHeight + verticalPadding * 2)
    width: implicitWidth
    height: implicitHeight

    onSelectedChanged:  {
        if(root.selected) {
            bg.color = Theme.palette.baseColor5
        } else {
            bg.color = Theme.palette.transparent
        }
    }

    // Card background
    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 8
        color: root.selected ? Theme.palette.baseColor5 : Theme.palette.transparent

        // Unread indicator dot (small circle)
        Rectangle {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Theme.halfPadding
            width: Theme.halfPadding
            height: width
            radius: width / 2
            color: root.unreadDotColor
            visible: root.unread
        }
    }

    // Content layout
    ColumnLayout {
        id: contentCol
        anchors.fill: parent
        spacing: gap

        RowLayout {
            spacing: gap
            Layout.leftMargin:  horizontalPadding
            Layout.rightMargin: horizontalPadding
            Layout.topMargin:   verticalPadding
            Layout.fillWidth:   parent.width

            NotificationAvatar {
                Layout.alignment: Qt.AlignTop

                density: root.density // TODO
                avatarSource: root.avatarSource
                badgeIconName: root.badgeIconName
                circular: root.isCircularAvatar
                isAvatarClickable: false
                isBadgeClickable: false
                // TODO: Colors customization
            }

            // Main content area
            ColumnLayout {
                spacing: Theme.smallPadding / 2
                Layout.fillWidth: true

                // Header row: username + verified + id + unread dot
                NotificationHeaderRow {
                    Layout.fillWidth: true
                    title: root.title
                    chatKey: root.chatKey
                    isContact: root.isContact
                    trustedIndicator: root.trustedIndicator
                    // TODO: Colors customization
                }

                NotificationContextRow {
                    Layout.fillWidth: true
                    primaryText: root.primaryText
                    secondaryText: root.secondaryText
                    iconName: root.iconName
                    separatorIconName: root.separatorIconName
                }

                StatusBaseText {
                    visible: root.actionText
                    text: root.actionText
                    font.pixelSize: Theme.fontSize13
                    color: Theme.palette.directColor5
                    elide: Text.ElideRight
                }

                // TODO: Replace by NotificationContentBlock
                NotificationContentBlock {
                    contentHtml: root.content
                    preImageSource: root.preImageSource
                    attachments: root.attachments
                }

                // Timestamp
                StatusBaseText {
                    text: root.timestampText ? root.timestampText :
                                               qsTr("Just now")
                    font.pixelSize: Theme.fontSize11
                    color: Theme.palette.directColor5
                }
            }
        }
    }

    // Full-card click layer
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: bg.color = Theme.palette.baseColor5
        onExited: {
            if(root.selected) {
                bg.color = Theme.palette.baseColor5
            } else {
                bg.color = Theme.palette.transparent
            }
        }
        onClicked: root.clicked()
    }
}
