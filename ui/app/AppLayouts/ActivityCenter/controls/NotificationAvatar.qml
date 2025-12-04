// NotificationAvatar.qml
// -----------------------------------------------------------------------------
// A compact, avatar component for notification lists.
// - Single image source with optional circular mask
// - Bottom-right actions badge overlay (icon) with adjustable overlap
//
// USAGE EXAMPLES
// --------------
// // Circular (default) with badge
// NotificationAvatar {
//     avatarSource: "https://.../user.jpg"
//     badgeIconName: "action-mention"
// }
//
// // Plain rectangle (no mask), tighter layout that ignores the badge
// NotificationAvatar {
//     circular: false
//     includeBadgeInImplicit: false
//     avatarSource: "https://.../cover.jpg"
//     badgeIconName: ""
// }
//
// // Tweak sizes and overlap
// NotificationAvatar {
//     density: 1.25
//     baseAvatarSize: 36         // base size, multiplied by density
//     baseBadgeSize: 18
//     badgeOverlapRatio: 0.22
//     badgeBgColor: Theme.palette.primaryColor3
// }
//
// NOTES
// -----
// * The component’s implicit size can either hug only the avatar or include the
//   badge extents (see: includeBadgeInImplicit).
// -----------------------------------------------------------------------------

import QtQuick
import QtQuick.Controls
import QtQuick.Effects

import StatusQ.Components
import StatusQ.Core.Theme

Control {
    id: root

    // ──────────────────────────────────────────────────────────────────────────
    // API
    // ──────────────────────────────────────────────────────────────────────────

    // Content image URL
    property url  avatarSource: ""

    // Optional badge icon name (empty → hidden)
    property string badgeIconName: ""

    // When true, render avatar as a circle using a mask.
    // When false, shows the image provided.
    property bool  circular: true

    // Density multiplier (acts like a scaling factor)
    property real  density: 1.0

    // Base sizes (will be multiplied by density)
    property int   baseAvatarSize: 36
    property int   baseBadgeSize:  18

    /// Badge background color
    property color badgeBgColor: Theme.palette.primaryColor3

    // How much the badge overlaps the avatar on bottom-right (0..1)
    property real  badgeOverlapRatio: 0.25

    // If true, root.implicitWidth/Height include the badge extents.
    // If false, the implicit size hugs only the avatar.
    property bool  includeBadgeInImplicit: true

    // When true (default), the avatar area reacts visually to mouse hover and click
    // and exposes a pointing-hand cursor. Disable if you don’t want the
    // avatar to be an interactive target.
    property bool isAvatarClickable: true

    // When true (default), the badge overlay reacts visually to mouse hover and click
    // and exposes a pointing-hand cursor. Disable if you don’t want the
    // badge to be clickable or highlight on hover.
    property bool isBadgeClickable: true

    // Interactions
    signal avatarClicked()
    signal badgeClicked()

    QtObject {
        id: d

        // Dynamic size properties
        readonly property int avatarSize: Math.round(baseAvatarSize * density)
        readonly property int badgeSize:  Math.round(baseBadgeSize  * density)
    }

    contentItem: Item {
        // ──────────────────────────────────────────────────────────────────────────
        // Layout sizing
        // ──────────────────────────────────────────────────────────────────────────
        implicitWidth:  root.includeBadgeInImplicit
                        ? Math.max(avatarImg.width,  badge.x + badge.width)
                        : avatarImg.width
        implicitHeight: root.includeBadgeInImplicit
                        ? Math.max(avatarImg.height, badge.y + badge.height)
                        : avatarImg.height

        // ──────────────────────────────────────────────────────────────────────────
        // Content image (single source for both masked and unmasked paths)
        // ──────────────────────────────────────────────────────────────────────────
        Image {
            id: avatarImg
            anchors.top: parent.top
            anchors.left: parent.left
            width: d.avatarSize
            height: width
            source: root.avatarSource
            fillMode: Image.PreserveAspectCrop
            smooth: true
            mipmap: true

            layer.enabled: root.circular
            layer.effect: MultiEffect {
                source: avatarImg

                maskEnabled: root.circular
                maskSource: circleMask

                visible: root.circular
                enabled: root.circular

                maskThresholdMin: 0.5
                maskSpreadAtMin: 1.0
            }

            // Mask geometry
            Rectangle {
                id: circleMask
                anchors.fill: avatarImg
                radius: width / 2
                visible: false
                layer.enabled: true

            }
        }

        // Unified click target for avatar
        MouseArea {
            anchors.fill: avatarImg
            enabled: root.isAvatarClickable
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: root.avatarClicked()
        }

        // ──────────────────────────────────────────────────────────────────────────
        // Badge overlay (bottom-right)
        // ──────────────────────────────────────────────────────────────────────────
        StatusRoundIcon {
            id: badge
            visible: root.badgeIconName !== ""
            width:  d.badgeSize  + 2 // Just to ensure the border renders completely
            height: width

            asset.width: d.badgeSize
            asset.height: asset.width
            asset.bgWidth: asset.width
            asset.bgHeight: asset.height
            asset.name: root.badgeIconName
            asset.bgColor: StatusColors.transparent
            asset.color: StatusColors.transparent

            anchors.right:  avatarImg.right
            anchors.bottom: avatarImg.bottom
            anchors.rightMargin:  -width  * root.badgeOverlapRatio
            anchors.bottomMargin: -height * root.badgeOverlapRatio

            MouseArea {
                anchors.fill: parent
                enabled: root.isBadgeClickable
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: root.badgeClicked()
            }
        }
    }
}
