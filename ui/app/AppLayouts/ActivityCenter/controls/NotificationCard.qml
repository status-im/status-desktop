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

    // ===== Public API =====
    // Identity
    property string username: ""              // falls back to "username" if empty
    property string userId: ""                // falls back to "0x…id" if empty
    property bool   verified: false
    property url    avatarSource: ""          // falls back to placeholder if empty

    // Context
    property string community: ""             // falls back to "@community" if empty
    property string channel: ""               // falls back to "#channel" if empty

    // Action
    property url    actionIconName: ""      // optional badge over avatar
    property string actionText: ""            // short hint after username

    // Content
    property string content: ""               // supports RichText if contentIsRichText = true
    property bool   contentIsRichText: true
    property int    maxContentLines: 4

    // State
    property bool   unread: true

    // Meta
    property string timestampText: ""         // falls back to "Just now" if empty

    // Style / layout
    property real   density: 1.0
    property real   cornerRadius: 14 * density
    property real   gap: 8 * density
    property real   horizontalPadding: 14 * density
    property real   verticalPadding: 12 * density

    // Visual tokens (customize freely)
    //property color  backgroundColor: palette.window
    //property color  textColor:       palette.windowText
    //property color  mutedTextColor:  Qt.rgba(textColor.r, textColor.g, textColor.b, 0.65)
    // color  subtleTextColor: Qt.rgba(textColor.r, textColor.g, textColor.b, 0.55)

    // Shadow behavior (MultiEffect is Qt 6 native; disable if target/platform complains)
    property bool   useMultiEffectShadow: true

    // Signals
    signal clicked()
    signal avatarClicked()
    signal actionClicked()
    signal linkActivated(url url)

    // Helpers
    function markAsRead() { unread = false }
    function toggleUnread() { unread = !unread }

    QtObject {
        id: d
        readonly property int avatarSize: 36
        readonly property int actionIconSize: 18
        readonly property int readUnreadBadgeSize: 8
    }

    // Sane implicit size and default size
    implicitWidth: 420 * density
    implicitHeight: Math.max(72 * density, contentCol.implicitHeight + verticalPadding * 2)
    width: implicitWidth
    height: implicitHeight

    // ===== Shadow behind the card =====
    // MultiEffect shadow
    MultiEffect {
        id: shadow
        anchors.fill: bg
        source: bg
        z: -1
        visible: useMultiEffectShadow
        shadowEnabled: true
        shadowColor: Qt.rgba(0,0,0,0.16)
        shadowBlur: 0.6
        shadowHorizontalOffset: 0
        shadowVerticalOffset: 4 * density
        autoPaddingEnabled: true
    }

    // Lightweight faux shadow (no Effects) — used if MultiEffect disabled
    Rectangle {
        anchors.fill: bg
        y: 3 * density
        radius: bg.radius + 1
        color: "#1A000000"
        visible: !useMultiEffectShadow
        z: -1
    }

    // ===== Card background =====
    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 8
        color: root.unread ? Theme.palette.baseColor5 : Theme.palette.transparent

        StatusBadge {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 8
            anchors.rightMargin: 12
            visible: root.unread
            implicitWidth: d.readUnreadBadgeSize
            implicitHeight: implicitWidth
        }
    }

    // ===== Content layout =====
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

            // Avatar + action badge
            Item {
                id: avatarWrap
                Layout.preferredWidth:  d.avatarSize * density
                Layout.preferredHeight: d.avatarSize * density
                Layout.alignment: Qt.AlignTop

                // Circular clipped avatar
                StatusRoundedImage {
                    id: avatar

                    anchors.centerIn: parent
                    width: parent.width
                    height: width
                    image.source: root.avatarSource

                    // Click on avatar
                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.avatarClicked()
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }

                StatusRoundIcon {
                    id: actionBadge
                    anchors.left: avatar.right
                    anchors.bottom: avatar.bottom
                    visible: root.actionIconName !== ""
                    height: d.actionIconSize * density
                    width: d.actionIconSize * density
                    asset.name: root.actionIconName
                    asset.bgColor: Theme.palette.primaryColor3

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.actionClicked()
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }

            // Main content area
            ColumnLayout {
                spacing: Theme.smallPadding / 2
                Layout.fillWidth: true

                // Header row: username + verified + id + unread dot
                RowLayout {
                    spacing: Theme.smallPadding / 2
                    Layout.fillWidth: true

                    StatusBaseText {
                        text: root.username.length ? root.username : "username"
                        font.pixelSize: Theme.fontSize13
                        font.weight: Font.Medium
                        color: Theme.palette.directColor1
                        elide: Text.ElideRight
                    }

                    // Verified badge (TODO: icon)
                    Rectangle {
                        visible: root.verified
                        Layout.preferredWidth: Theme.fontSize14
                        Layout.preferredHeight: Layout.preferredWidth
                        radius: width / 2
                        color: Theme.palette.primaryColor1
                        StatusBaseText {
                            anchors.centerIn: parent
                            text: "✓"
                            font.pixelSize: parent.width * 0.7
                            color: Theme.palette.white
                        }
                    }

                    StatusBaseText {
                        visible: true
                        text: (root.userId.length ? root.userId : "0x…id")
                        font.pixelSize: Theme.fontSize11
                        color: Theme.palette.directColor6
                        elide: Text.ElideRight
                    }
                }

                // Location: community › channel
                RowLayout {
                    spacing: 4 * density
                    Layout.fillWidth: true
                    visible: true

                    StatusBaseText {
                        text: "@" + (root.community.length ? root.community : "community")
                        font.pixelSize: Theme.fontSize13
                        font.weight: Font.Medium
                        color: Theme.palette.directColor1
                        elide: Text.ElideRight
                    }
                    StatusBaseText {
                        text: "›"
                        font.pixelSize: Theme.fontSize16
                        font.weight: Font.Medium
                        color: Theme.palette.directColor6
                    }
                    StatusBaseText {
                        text: (root.channel.length ? root.channel : "#channel")
                        font.pixelSize: Theme.fontSize13
                        font.weight: Font.Medium
                        color: Theme.palette.directColor1
                        elide: Text.ElideRight
                    }
                }

                StatusBaseText {
                    visible: root.actionText.length > 0
                    text: root.actionText
                    font.pixelSize: Theme.fontSize13
                    color: Theme.palette.directColor5
                    elide: Text.ElideRight
                }

                // Content
                StatusBaseText {
                    id: tContent
                    text: root.content.length
                          ? root.content
                          : "This is a sample message to prove the card is rendering correctly."
                    textFormat: root.contentIsRichText ? Text.RichText : Text.AutoText
                    wrapMode: Text.Wrap
                    maximumLineCount: root.maxContentLines
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    font.pixelSize: Theme.fontSize13
                    color: Theme.palette.directColor1
                    linkColor: Theme.palette.baseColor1
                    onLinkActivated: (u)=> root.linkActivated(u)
                }

                // Timestamp
                StatusBaseText {
                    text: root.timestampText.length ?
                              root.timestampText : qsTr("Just now")
                    font.pixelSize: Theme.fontSize11
                    color: Theme.palette.directColor5
                }
            }
        }
    }

    // Full-card click layer
   /* MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered:  bg.color = Qt.lighter(backgroundColor, 1.02)
        onExited:   bg.color = backgroundColor
        onClicked:  root.clicked()
    }*/
}
