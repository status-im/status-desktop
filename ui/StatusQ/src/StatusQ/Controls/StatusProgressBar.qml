import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1

ProgressBar {
    id: control

    property string text
    property color fillColor
    property color backgroundColor: Theme.palette.directColor8

    width: 416
    height: 16
    clip: true

    background: Rectangle {
        implicitWidth: parent.width
        implicitHeight: parent.height
        color: control.backgroundColor
        radius: 5
    }
    contentItem: Item {
        implicitHeight: parent.height

        Rectangle {
            id: bar
            width: control.visualPosition * parent.width
            height: parent.height
            color: control.fillColor
            radius: 5

            StatusBaseText {
                anchors.centerIn: parent
                text: control.text
                font.pixelSize: 12
                color: Theme.palette.indirectColor1
            }
        }
    }
}
