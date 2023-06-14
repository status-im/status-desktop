import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

ItemDelegate {
    id: root

    property bool centerTextHorizontally: false
    property int radius: 0
    property int cursorShape: Qt.PointingHandCursor

    padding: 8
    spacing: 8

    icon.width: 16
    icon.height: 16

    contentItem:  RowLayout {
        spacing: root.spacing

        StatusIcon {
            Layout.alignment: Qt.AlignVCenter
            visible: !!icon
            icon: root.icon.name || root.icon.source
            color: root.enabled ? root.icon.color : Theme.palette.baseColor1
            width: root.icon.width
            height: root.icon.height
        }

        StatusBaseText {
            Layout.fillWidth: true
            Layout.fillHeight: true
            font: root.font
            text: root.text
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            color: root.enabled ? Theme.palette.directColor1 : Theme.palette.baseColor1

            Binding on horizontalAlignment {
                when: root.centerTextHorizontally
                value: Text.AlignHCenter
            }
        }
    }

    background: Rectangle {
        color: root.highlighted
               ? Theme.palette.statusMenu.hoverBackgroundColor
               : "transparent"

        radius: root.radius

        MouseArea {
            anchors.fill: parent
            cursorShape: root.cursorShape
            acceptedButtons: Qt.NoButton
        }
    }
}
