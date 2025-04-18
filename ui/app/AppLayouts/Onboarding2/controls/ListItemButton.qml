import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

AbstractButton {
    id: root

    property string subTitle

    padding: Theme.padding
    spacing: Theme.padding

    icon.width: 32
    icon.height: 32

    background: Rectangle {
        color: {
            if (root.disabled) {
                return Theme.palette.baseColor2
            }
            return root.hovered ? Theme.palette.backgroundHover : "transparent"
        }
        HoverHandler {
            cursorShape: root.hovered ? Qt.PointingHandCursor : undefined
        }
    }

    contentItem: RowLayout {
        spacing: root.spacing

        StatusImage {
            Layout.preferredWidth: root.icon.width
            Layout.preferredHeight: root.icon.height
            source: root.icon.source
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1
            StatusBaseText {
                Layout.fillWidth: true
                text: root.text
                font.pixelSize: Theme.additionalTextSize
                font.weight: Font.Medium
                color: root.enabled ? Theme.palette.directColor1 : Theme.palette.baseColor1
                lineHeightMode: Text.FixedHeight
                lineHeight: 18
            }
            StatusBaseText {
                Layout.fillWidth: true
                text: root.subTitle
                font.pixelSize: Theme.additionalTextSize
                color: root.enabled ? Theme.palette.baseColor1 : Theme.palette.baseColor2
                visible: !!text
                lineHeightMode: Text.FixedHeight
                lineHeight: 18
            }
        }

        StatusIcon {
            Layout.preferredWidth: 16
            Layout.preferredHeight: 16
            icon: "tiny/chevron-right"
            color: root.enabled ? Theme.palette.baseColor1 : Theme.palette.baseColor1
        }
    }
}
