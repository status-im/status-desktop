import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

ItemDelegate {
    id: root

    padding: 8
    spacing: 8

    icon.width: 16
    icon.height: 16

    contentItem:  RowLayout {
        spacing: root.spacing

        StatusIcon {
            Layout.alignment: Qt.AlignVCenter
            visible: !!icon
            icon: root.icon.name
            color: root.enabled ? root.icon.color : Theme.palette.baseColor1
            width: root.icon.width
            height: root.icon.height
        }

        StatusBaseText {
            id: textItem
            Layout.fillWidth: true
            Layout.fillHeight: true
            font: root.font
            text: root.text
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            color: root.enabled ? Theme.palette.directColor1 : Theme.palette.baseColor1
        }
    }

    background: Rectangle {
        color: root.highlighted
               ? Theme.palette.statusMenu.hoverBackgroundColor
               : "transparent"

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.NoButton
            enabled: root.enabled
        }
    }
}
