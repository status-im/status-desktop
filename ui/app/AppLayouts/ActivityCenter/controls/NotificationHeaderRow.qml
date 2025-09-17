// NotificationHeaderRow.qml
// -----------------------------------------------------------------------------
// A compact header line for notification cards.
// - Title (single line, truncated with "…")
// - Optional verification badges (contact + trust indicator)
// - Chat key shortened as "AAAA...ZZZZ"
// - Unread indicator dot aligned to the far right
//
// USAGE EXAMPLES
// --------------
// // Basic usage with title and key
// NotificationHeaderRow {
//     title: "Alice Johnson"
//     chatKey: "0x1234abcd5678efgh9012ijkl"
// }
//
// // With badges
// NotificationHeaderRow {
//     title: "Community Bot"
//     chatKey: "0x8765dcba4321"
//     isContact: true
//     trustedIndicator: 2
// }
//
// // Without unread dot
// NotificationHeaderRow {
//     title: "Charlie"
//     chatKey: "0xabcdef0987"
//     unread: false
// }
//
// NOTES
// -----
// * Maximum visible characters for `title` is controlled by maxNameChars.
// * The unread dot uses Theme.primaryColor1 and sits at the far right.
// * Badges are placed inline between the display name and the chat key.
// * Fonts, spacing, and colors follow Theme definitions.
// -----------------------------------------------------------------------------
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components

import StatusQ.Core.Utils

Control {
    id: root

    // ──────────────────────────────────────────────────────────────────────────
    // API
    // ──────────────────────────────────────────────────────────────────────────

    // Titile (truncated to maxTitleChars)
    required property string title

    // Chat key (formatted as prefix…suffix)
    property string chatKey: ""

    // Show "is contact" badge if true
    property bool   isContact: false

    // Trust level indicator (0 = none). Expected values: StatusContactVerificationIcons.TrustedType
    property int    trustedIndicator: 0

    // ──────────────────────────────────────────────────────────────────────────
    // Design parameters
    // ──────────────────────────────────────────────────────────────────────────

    // Indicates whether the `isContact` or the `trustedIndicators` are visualized as tiny icons or normal ones (size change).
    // By default it scales following a factor based on current app font size.
    property bool   areTinyIndicators: d.indicatorsForFontSize(Theme.currentFontSize)

    // ──────────────────────────────────────────────────────────────────────────
    // Colors (Theme-driven)
    // ──────────────────────────────────────────────────────────────────────────

    // Title color
    property color  titleColor: Theme.palette.directColor1

    // Chat key color
    property color  keyColor: Theme.palette.directColor5

    // ──────────────────────────────────────────────────────────────────────────
    // Style / layout
    // ──────────────────────────────────────────────────────────────────────────

    QtObject {
        id: d

        // Returns the scaling factor for contact/trust indicators based on font size.
        function indicatorsForFontSize(fs) {
            switch (fs) {
            case Theme.FontSize.FontSizeXS:
            case Theme.FontSize.FontSizeS:
            case Theme.FontSize.FontSizeM:
                return true;

            case Theme.FontSize.FontSizeL:
            case Theme.FontSize.FontSizeXL:
            case Theme.FontSize.FontSizeXXL:
                return false;

            default:
                return true; // Safe fallback
            }
        }
    }

    // ──────────────────────────────────────────────────────────────────────────
    // Layout configuration
    // ──────────────────────────────────────────────────────────────────────────

    // Horizontal spacing between items
    spacing: Theme.halfPadding

    // Content layout: [Title] [Badges] [ChatKey] … [UnreadDot]
    contentItem: RowLayout {
        spacing: root.spacing

        // Title (elided if longer than maxNameChars)
        StatusBaseText {
            id: nameText
            Layout.maximumWidth: root.width - 3 * spacing - icons.implicitWidth - keyText.implicitWidth
            Layout.alignment: Qt.AlignVCenter
            text: root.title
            color: root.titleColor
            elide: Text.ElideRight
            maximumLineCount: 1
            wrapMode: Text.NoWrap
            font.pixelSize: Theme.fontSize13
            font.weight: Font.Medium
        }

        // Contact + trust verification icons
        StatusContactVerificationIcons {
            id: icons
            isContact: root.isContact
            trustIndicator: root.trustedIndicator
            tiny: root.areTinyIndicators
        }

        // Shortened chat key
        StatusBaseText {
            id: keyText
            Layout.alignment: Qt.AlignVCenter
            visible: root.chatKey != ""
            text: Utils.elideText(root.chatKey, 4, 4)
            color: root.keyColor
            maximumLineCount: 1
            wrapMode: Text.NoWrap
            font.pixelSize: Theme.fontSize11
        }

        // Spacer pushes content to the left
        Item {
            Layout.fillWidth: true
        }
    }
}
