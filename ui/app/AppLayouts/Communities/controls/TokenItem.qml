import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components

Control {
    id: root

    property string name
    property string shortName
    property string amount
    property url iconSource
    property string decimals
    property bool selected: false
    property bool showSubItemsIcon: false

    signal itemClicked

    padding: 6 // by design
    implicitHeight: 44 // by design
    spacing: 8 // by design
    background: Rectangle {
        color: mouseArea.containsMouse ? Theme.palette.statusListItem.highlightColor : "transparent"
        radius: 8

        StatusMouseArea {
            id: mouseArea
            anchors.fill: parent
            cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            hoverEnabled: true
            onClicked: root.itemClicked()
        }
    }
    contentItem: RowLayout {
        spacing: root.spacing

        StatusRoundedImage {
            Layout.alignment: Qt.AlignVCenter
            image.source: root.iconSource
            visible: root.iconSource.toString() !== ""
            Layout.preferredWidth: 32
            Layout.preferredHeight: Layout.preferredWidth
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 0

            StatusBaseText {
                Layout.fillWidth: true
                text: root.name
                color: Theme.palette.directColor1
                font.pixelSize: Theme.additionalTextSize
                font.weight: Font.Medium
                elide: Text.ElideRight
            }

            StatusBaseText {
                visible: !!root.shortName
                Layout.fillWidth: true
                text: root.shortName
                color: Theme.palette.baseColor1
                font.pixelSize: Theme.tertiaryTextFontSize
                elide: Text.ElideRight
            }
        }

        StatusBaseText {
            visible: !!root.amount && !root.selected
            text: root.amount
            color: Theme.palette.baseColor1
            font.pixelSize: Theme.tertiaryTextFontSize
            font.weight: Font.Medium
            elide: Text.ElideRight

            Layout.rightMargin: root.spacing
        }

        StatusIcon {
            icon: root.selected && !root.showSubItemsIcon ? "checkmark" : "tiny/chevron-right"
            visible: root.selected || root.showSubItemsIcon
            Layout.alignment: Qt.AlignVCenter
            color: Theme.palette.baseColor1
            width: 16
            height: 16
        }
    }
}
