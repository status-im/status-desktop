import QtQuick 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

Item {
    id: root

    implicitWidth: 480
    height: label.anchors.topMargin +
            label.height + 
            statusBaseInput.anchors.topMargin +
            statusBaseInput.height + 8

    property alias input: statusBaseInput
    property string label: ""

    StatusBaseText {
        id: label
        height: visible ? implicitHeight : 0
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: visible ? 8 : 0
        anchors.leftMargin: 16
        visible: !!root.label

        text: root.label
        font.pixelSize: 15
        color: Theme.palette.directColor1
    }

    StatusBaseInput {
        id: statusBaseInput
        anchors.top:  label.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 8
        anchors.leftMargin: 16
        anchors.rightMargin: 16
    }
}
