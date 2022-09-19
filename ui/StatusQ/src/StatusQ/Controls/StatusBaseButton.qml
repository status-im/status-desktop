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

    property StatusAssetSettings asset: StatusAssetSettings { }

    property bool loading

    property color normalColor
    property color hoverColor
    property color disabledColor

    property color textColor
    property color disabledTextColor
    property color borderColor: "transparent"

    property int size: StatusBaseButton.Size.Large
    property int type: StatusBaseButton.Type.Normal

    QtObject {
        id: d
        readonly property color textColor: root.enabled || root.loading ? root.textColor : root.disabledTextColor
    }

    font.family: Theme.palette.baseFont.name
    font.weight: Font.Medium
    font.pixelSize: size === StatusBaseButton.Size.Large ? 15 : 13

    horizontalPadding: {
        if (root.icon.name) {
            return size === StatusBaseButton.Size.Large ? 18 : 16
        }
        return size === StatusBaseButton.Size.Large ? 24 : 12
    }
    verticalPadding: {
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

    icon.height: 24
    icon.width: 24

    background: Rectangle {
        radius: root.size === StatusBaseButton.Size.Tiny ? 6 : 8
        border.color: root.borderColor
        color: {
            if (root.enabled)
                return !root.loading && (root.hovered || root.highlighted) ? hoverColor : normalColor;
            return disabledColor;
        }
    }

    contentItem: RowLayout {
        spacing: root.spacing
        StatusIcon {
            Layout.preferredWidth: visible ? root.icon.width : 0
            Layout.preferredHeight: visible ? root.icon.height : 0
            icon: root.icon.name
            rotation: root.asset.rotation
            opacity: !loading && root.icon.name !== ""
            visible: root.icon.name !== ""
            color: d.textColor
        }
        StatusEmoji {
            Layout.preferredWidth: visible ? root.icon.width : 0
            Layout.preferredHeight: visible ? root.icon.height : 0
            visible: root.asset.emoji
            emojiId: Emoji.iconId(root.asset.emoji, root.asset.emojiSize) || ""
        }
        StatusBaseText {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            opacity: !loading
            font: root.font
            text: root.text
            color: d.textColor
            verticalAlignment: Text.AlignVCenter
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
