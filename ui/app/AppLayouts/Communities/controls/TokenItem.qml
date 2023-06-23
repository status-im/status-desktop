import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

Control {
    id: root

    property string name
    property string shortName
    property string amount
    property url iconSource
    property bool selected: false
    property bool showSubItemsIcon: false

    signal itemClicked

    leftPadding: 6 // by design
    implicitHeight: 45 // by design
    spacing: 8 // by design
    background: Rectangle {
        color: mouseArea.containsMouse ? Theme.palette.baseColor4 : "transparent"

        MouseArea {
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
                font.pixelSize: 13
                font.weight: Font.Medium
                elide: Text.ElideRight
            }

            StatusBaseText {
                visible: !!root.shortName
                Layout.fillWidth: true
                text: root.shortName
                color: Theme.palette.baseColor1
                font.pixelSize: 12
                elide: Text.ElideRight
            }
        }

        StatusBaseText {
            visible: !!root.amount && !root.selected
            text: root.amount
            color: Theme.palette.baseColor1
            font.pixelSize: 12
            font.weight: Font.Medium
            elide: Text.ElideRight

            Layout.rightMargin: root.spacing
        }

        StatusIcon {
            icon: root.selected && !root.showSubItemsIcon ? "checkmark" : "tiny/chevron-right"
            visible: root.selected || root.showSubItemsIcon
            Layout.alignment: Qt.AlignVCenter
            Layout.rightMargin: 16
            color: Theme.palette.baseColor1
            width: 16
            height: 16
        }
    }
}
