import QtQuick 2.13
import QtQuick.Controls 2.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

Rectangle {
    id: root
    implicitWidth: 168
    implicitHeight: 95

    property string text: ""
    property bool highlighted: false
    property bool enabled: true

    signal clicked(var mouse)

    property StatusIconSettings icon: StatusIconSettings {
        width: 24
        height: 24
        background: StatusIconBackgroundSettings {}
    }

    color: {
        let actualColor = Qt.darker(root.icon.color, 1)
        actualColor.a = sensor.containsMouse && enabled ? 0.3 : 0.2
        return actualColor
    }

    radius: 16

    MouseArea {
        id: sensor
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        anchors.fill: parent
        hoverEnabled: true

        onClicked: function (mouse) {
            root.clicked(mouse)
        }

        StatusRoundIcon {
            icon.name: root.icon.name
            icon.width: root.icon.width
            icon.height: root.icon.height
            icon.rotation: root.icon.rotation
            icon.color: Theme.palette.white
            icon.background.width: 40
            icon.background.height: 40
            icon.background.color: root.icon.color
            anchors.top: parent.top
            anchors.topMargin: 8
            anchors.left: parent.left
            anchors.leftMargin: 8
        }

        StatusBaseText {
            text: root.text
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8
            font.pixelSize: 13
            font.weight: Font.Medium
            color: Theme.palette.white
        }
    }
}


