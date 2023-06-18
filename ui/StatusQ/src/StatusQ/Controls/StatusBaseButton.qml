import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Utils 0.1

Button {
    id: root

    enum Size {
        Tiny,
        Small,
        Large
    }

    enum Type {
        Normal,
        Danger,
        Primary
    }

    enum TextPosition {
        Left,
        Right
    }

    property StatusAssetSettings asset: StatusAssetSettings {
        color: d.textColor
    }

    property bool loading

    property color normalColor
    property color hoverColor
    property color disabledColor

    property color textColor
    property color disabledTextColor
    property color borderColor: "transparent"
    property bool textFillWidth: false

    property int radius: size === StatusBaseButton.Size.Tiny ? 6 : 8

    property int size: StatusBaseButton.Size.Large
    property int type: StatusBaseButton.Type.Normal
    property int textPosition: StatusBaseButton.TextPosition.Right

    property bool isRoundIcon: false

    QtObject {
        id: d
        readonly property color textColor: root.enabled || root.loading ? root.textColor : root.disabledTextColor
        readonly property bool iconOnly: root.display === AbstractButton.IconOnly || root.text === ""
        readonly property int iconSize: {
            switch(root.size) {
            case StatusBaseButton.Size.Tiny:
                return 16
            case StatusBaseButton.Size.Small:
                return 20
            case StatusBaseButton.Size.Large:
            default:
                return 24
            }
        }
    }

    font.family: Theme.palette.baseFont.name
    font.weight: Font.Medium
    font.pixelSize: size === StatusBaseButton.Size.Large ? 15 : 13

    horizontalPadding: {
        if (d.iconOnly) {
            return isRoundIcon ? 8 : spacing
        }
        if (root.icon.name) {
            switch (size) {
            case StatusBaseButton.Size.Tiny:
                return 8
            case StatusBaseButton.Size.Small:
                return 16
            case StatusBaseButton.Size.Large:
            default:
                return 18
            }
        }
        return size === StatusBaseButton.Size.Large ? 24 : 12
    }
    verticalPadding: {
        if (d.iconOnly) {
            return isRoundIcon ? 8 : spacing
        }
        switch (size) {
        case StatusBaseButton.Size.Tiny:
            return 5
        case StatusBaseButton.Size.Small:
            return 10
        case StatusBaseButton.Size.Large:
        default:
            return 11
        }
    }

    spacing: root.size === StatusBaseButton.Size.Large ? 6 : 4

    icon.width: d.iconSize
    icon.height: d.iconSize
    icon.color: asset.color

    background: Rectangle {
        radius: root.radius
        border.color: root.borderColor
        color: {
            if (root.enabled)
                return !root.loading && (root.hovered || root.highlighted) ? hoverColor : normalColor;
            return disabledColor;
        }
    }

    contentItem: Item {
        implicitWidth: layout.implicitWidth
        implicitHeight: layout.implicitHeight

        RowLayout {
            id: layout
            anchors.centerIn: parent
            width: root.textFillWidth ? root.availableWidth : Math.min(root.availableWidth, implicitWidth)
            height: Math.min(root.availableHeight, implicitHeight)
            spacing: root.spacing

            Component {
                id: baseIcon

                StatusIcon {
                    icon: root.icon.name
                    rotation: root.asset.rotation
                    opacity: !root.loading && root.icon.name !== "" && root.display !== AbstractButton.TextOnly
                    color: root.icon.color
                }
            }

            Component {
                id: roundIcon

                StatusRoundIcon {
                    opacity: !root.loading && root.icon.name !== ""  && root.display !== AbstractButton.TextOnly
                    asset.name: root.icon.name
                    asset.width: d.iconSize
                    asset.height: d.iconSize
                    asset.color: root.icon.color
                    asset.bgColor: root.asset.bgColor
                }
            }

            Component {
                id: text

                StatusBaseText {
                    opacity: !root.loading
                    font: root.font
                    text: root.text
                    color: d.textColor
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }
            }

            Loader {
                Layout.fillWidth: true
                active: root.textPosition === StatusBaseButton.TextPosition.Left && !d.iconOnly
                visible: active
                sourceComponent: text
            }

            Loader {
                id: iconLoader

                Layout.preferredWidth: active ? root.icon.width : 0
                Layout.preferredHeight: active ? root.icon.height : 0
                Layout.alignment: Qt.AlignCenter
                active: root.icon.name !== ""
                sourceComponent: root.isRoundIcon ? roundIcon : baseIcon
            }

            StatusEmoji {
                Layout.preferredWidth: visible ? root.icon.width : 0
                Layout.preferredHeight: visible ? root.icon.height : 0
                Layout.alignment: Qt.AlignCenter
                opacity: !root.loading && root.display !== AbstractButton.TextOnly
                visible: root.asset.emoji
                emojiId: Emoji.iconId(root.asset.emoji, root.asset.emojiSize) || ""
            }

            Loader {
                Layout.fillWidth: true
                active: root.textPosition === StatusBaseButton.TextPosition.Right && !d.iconOnly
                visible: active
                sourceComponent: text
            }
        }
    }

    Loader {
        anchors.centerIn: parent
        active: root.loading
        sourceComponent: StatusLoadingIndicator {
            color: d.textColor
        }
    }

    // stop the mouse clicks in the "loading" state w/o disabling the whole button
    // as this would make it impossible to have hover events or a tooltip
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        enabled: root.loading
        onPressed: mouse.accepted = true
        onWheel: wheel.accepted = true
        cursorShape: !root.loading ? Qt.PointingHandCursor: undefined // always works; 'undefined' resets to default cursor
    }
}
