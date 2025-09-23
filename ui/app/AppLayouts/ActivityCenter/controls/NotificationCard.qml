// NotificationCard.qml
// -----------------------------------------------------------------------------
// Main card component for rendering a single notification entry.
// - Combines avatar, header row (title, contact/trust badges),
//   context row (community, channel), action text, content block, and timestamp.
// - Supports unread state (dot indicator) and selected state (highlighted bg).
//
// USAGE EXAMPLES
// --------------
// // Minimal notification with avatar, text, and timestamp
// NotificationCard {
//     avatarSource: "https://.../user.jpg"
//     title: "Alice"
//     content: "sent you a message"
//     timestampText: "2h ago"
//     unread: true
// }
//
// // With community + channel context
// NotificationCard {
//     avatarSource: "https://.../user.jpg"
//     title: "Alice"
//     chatKey: "alice.eth"
//     primaryText: "CryptoKitties"
//     secondaryText: "#general"
//     content: "shared a file"
//     attachments: [ "https://.../thumb.png" ]
//     timestampText: "Yesterday"
//     unread: false
// }
//
// NOTES
// -----
// * Background and unread dot are theme-driven and update dynamically.
// * Avatar, context row, and content block are self-contained components.
// * Full-card MouseArea ensures click/hover highlight regardless of sub-content.
// -----------------------------------------------------------------------------

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls

import StatusQ.Core.Theme
import StatusQ.Components
import StatusQ.Core

import utils

Control {
    id: root

    // ──────────────────────────────────────────────────────────────────────────
    // API
    // ──────────────────────────────────────────────────────────────────────────

    // ──────────────────────────────────────────────────────────────────────────
    // Avatar parameters
    // ──────────────────────────────────────────────────────────────────────────

    // Avatar image URL. Empty → nothing.
    property url avatarSource: ""

    // Optional avatar badge icon URL/name. Empty → badge hidden.
    property url badgeIconName: ""

    // Render avatar as a circle when true; otherwise keep original image shape.
    property bool isCircularAvatar: true

    // ──────────────────────────────────────────────────────────────────────────
     // Header parameters
     // ──────────────────────────────────────────────────────────────────────────

     // Title (usually display name). Truncated in the header if too long.
     property string title: ""

     // Secondary identifier (e.g., chat key: "prefix…suffix"). Shown after title.
     property string chatKey: ""

     // Shows "is contact" badge when true.
     property bool isContact: false

     // Trust level indicator (0 = none). Values from StatusContactVerificationIcons.TrustedType.
     property int trustedIndicator: 0

    // ──────────────────────────────────────────────────────────────────────────
    // Context row parameters
    // ──────────────────────────────────────────────────────────────────────────

    // Primary context label (e.g., Community name).
    property string primaryText

    // Secondary context label (e.g., #channel).
    property string secondaryText

    // Leading/separator icon before labels. Hidden when empty.
    property string separatorIconName

    // Icon between primary and secondary labels. Hidden when empty.
    property string iconName

    // ──────────────────────────────────────────────────────────────────────────
    // Action and meta data parameters
    // ──────────────────────────────────────────────────────────────────────────

    // Short hint or action text displayed below the context row.
    property string actionText: ""

    // Timestamp text (e.g., "2h", "Yesterday"). Defaults to "Just now" if empty.
    property string timestampText: ""

    // ──────────────────────────────────────────────────────────────────────────
    // Content parameters
    // ──────────────────────────────────────────────────────────────────────────

    // Styled text content for the body (passed to NotificationContentBlock).
    property string content: ""

    // Max number of lines to display for content body (clamped in block).
    property int maxContentLines: 4

    // Optional banner image URL shown above the content body.
    property url preImageSource: ""

    // Media attachments (list/array of image URLs) for the content block.
    property var attachments: []

    // ──────────────────────────────────────────────────────────────────────────
    // Card states
    // ──────────────────────────────────────────────────────────────────────────

    // Whether the card is unread (shows unread dot). REQUIRED.
    required property bool unread

    // Whether the card is in selected state (highlighted background).
    property bool selected

    // ──────────────────────────────────────────────────────────────────────────
    // Colors (Theme-driven)
    // ──────────────────────────────────────────────────────────────────────────

    // Color of the unread indicator dot.
    property color unreadDotColor: Theme.palette.primaryColor1

    // Fixed diameter (or the small unread dot (read-only convenience).
    readonly property int unreadBadgeSize: 18

    // ──────────────────────────────────────────────────────────────────────────
    // Style / layout
    // ──────────────────────────────────────────────────────────────────────────

    // Horizontal spacing between avatar and content column.
    spacing: Theme.halfPadding

    // Vertical padding inside the card background.
    verticalPadding: Theme.halfPadding

    // ──────────────────────────────────────────────────────────────────────────
    // Interactions
    // ──────────────────────────────────────────────────────────────────────────

    // Emitted when the card surface is clicked.
    signal clicked()

    QtObject {
        id: d

        // Avatar image size used (design baseline)
        readonly property int avatarSize: 36

        // Action badge icon size (design baseline)
        readonly property int actionIconSize: 18

        // Suggested default factors per font size step
        property real factorXS:   0.80
        property real factorS:    0.90
        property real factorM:    1.00
        property real factorL:    1.10
        property real factorXL:   1.20
        property real factorXXL:  1.30

        // Dot size used by header spacing.
        readonly property int readUnreadBadgeSize: 8

        // Updates card background according to selection state.
        function updateCardBackgroundColor() {
            if (root.selected) {
                bg.color = Theme.palette.baseColor5
            } else {
                bg.color = Theme.palette.transparent
            }
        }

        // Returns the avatar scaling factor for a given font size enum value.
        function avatarFactorForFontSize(fs) {
            switch (fs) {
            case Theme.FontSize.FontSizeXS:  return d.factorXS;
            case Theme.FontSize.FontSizeS:   return d.factorS;
            case Theme.FontSize.FontSizeM:   return d.factorM;
            case Theme.FontSize.FontSizeL:   return d.factorL;
            case Theme.FontSize.FontSizeXL:  return d.factorXL;
            case Theme.FontSize.FontSizeXXL: return d.factorXXL;
            default:                         return 1.0;  // Safe fallback
            }
        }
    }

    // Keep background consistent when selection changes.
    onSelectedChanged: d.updateCardBackgroundColor()

    // Card background and unread indicator.
    background: Rectangle {
        id: bg
        anchors.fill: parent
        radius: 8
        color: root.selected ? Theme.palette.baseColor5 : Theme.palette.transparent

         // Unread indicator dot (top-right).
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

    // ──────────────────────────────────────────────────────────────────────────
    // Content - Main layout: avatar + content column.
    // ──────────────────────────────────────────────────────────────────────────
    contentItem: RowLayout {
        spacing: root.spacing

        // Avatar block (non-clickable here; card handles clicks).
        NotificationAvatar {
            Layout.alignment: Qt.AlignTop
            Layout.leftMargin: Theme.halfPadding

            // Scale avatar with current font size factor
            density: d.avatarFactorForFontSize(Theme.currentFontSize)

            avatarSource: root.avatarSource
            badgeIconName: root.badgeIconName
            circular: root.isCircularAvatar
            isAvatarClickable: false
            isBadgeClickable: false
        }

        // Main content area
        ColumnLayout {
            spacing: Theme.smallPadding / 2
            Layout.fillWidth: true
            Layout.rightMargin: Theme.halfPadding

            // Header row: title + chat key + contact/trust badges.
            NotificationHeaderRow {
                Layout.fillWidth: true
                Layout.rightMargin: root.unreadBadgeSize / 2
                visible: root.title != ""
                title: root.title
                chatKey: root.chatKey
                isContact: root.isContact
                trustedIndicator: root.trustedIndicator
            }

            // Context row: community + channel + optional icons.
            NotificationContextRow {
                Layout.fillWidth: true
                Layout.rightMargin: root.unreadBadgeSize / 2
                visible: root.primaryText != ""
                primaryText: root.primaryText
                secondaryText: root.secondaryText
                iconName: root.iconName
                separatorIconName: root.separatorIconName
            }

            // Optional action hint/body line under context row.
            StatusBaseText {
                Layout.fillWidth: true
                visible: root.actionText
                text: root.actionText
                font.pixelSize: Theme.fontSize13
                color: Theme.palette.directColor5
                elide: Text.ElideRight
            }

            // Rich content block: HTML, banner, attachments.
            NotificationContentBlock {
                Layout.fillWidth: true
                contentText: root.content
                preImageSource: root.preImageSource
                attachments: root.attachments
                thumbSpacing: 6
            }

            // Timestamp row (falls back to "Just now").
            StatusBaseText {
                Layout.fillWidth: true
                text: root.timestampText ? root.timestampText :
                                           qsTr("Just now")
                font.pixelSize: Theme.fontSize11
                color: Theme.palette.directColor5
                elide: Text.ElideRight
            }
        }
    }

    // Full-card click target + hover highlight.
    MouseArea {
        z: 1
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: bg.color = Theme.palette.baseColor5
        onExited: d.updateCardBackgroundColor()

        onClicked: root.clicked()
    }
}
