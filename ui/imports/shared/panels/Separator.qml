import QtQuick

import StatusQ.Core.Theme

Item {
    id: root
    property color color: Theme.palette.separator
    width: parent.width
    implicitHeight: 1
    height: root.visible ? implicitHeight : 0
    anchors.topMargin: Theme.padding
    Rectangle {
        id: separator
        width: parent.width
        height: 1
        color: root.color
        anchors.verticalCenter: parent.verticalCenter
    }
}
