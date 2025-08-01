import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme

ItemDelegate {
    id: root

    property bool centerTextHorizontally: false
    property int radius: 0
    property int cursorShape: Qt.PointingHandCursor
    property color highlightColor: Theme.palette.statusMenu.hoverBackgroundColor

    padding: 8
    spacing: 8

    icon.width: 16
    icon.height: 16

    font.family: Theme.baseFont.name
    font.pixelSize: Theme.primaryTextFontSize

    contentItem: RowLayout {
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
            color: root.highlighted ? Theme.palette.white : root.enabled ? Theme.palette.directColor1 : Theme.palette.baseColor1

            Binding on horizontalAlignment {
                when: root.centerTextHorizontally
                value: Text.AlignHCenter
            }
        }
    }

    background: Rectangle {
        color: root.highlighted ? root.highlightColor : "transparent"
        radius: root.radius
    }

    MouseArea {
        // NOTE The hover handler would break control's hover in some corner cases, hence mouse area is used
        hoverEnabled: true
        cursorShape: root.cursorShape
        propagateComposedEvents: true
    }
}
