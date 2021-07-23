import QtQuick 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

Rectangle {
    id: root

    implicitWidth: 480
    height: (label.visible ? 
                  label.anchors.topMargin +
                  label.height :
              charLimitLabel.visible ?
                  charLimitLabel.anchors.topMargin +
                  charLimitLabel.height :
              0) +
            statusBaseInput.anchors.topMargin +
            statusBaseInput.height + 
            (errorMessage.visible ? 
                  errorMessage.anchors.topMargin +
                  errorMessage.height :
                  0) + 8

    color: "transparent"
    property alias input: statusBaseInput
    property string label: ""
    property int charLimit: 0
    property string errorMessage: ""

    StatusBaseText {
        id: label
        height: visible ? implicitHeight : 0
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: visible ? 8 : 0
        anchors.leftMargin: 16
        anchors.right: charLimitLabel.visible ? charLimitLabel.left : parent.right
        anchors.rightMargin: 16
        visible: !!root.label
        elide: Text.ElideRight

        text: root.label
        font.pixelSize: 15
        color: statusBaseInput.enabled ? Theme.palette.directColor1 : Theme.palette.baseColor1
    }

    StatusBaseText {
        id: charLimitLabel
        height: visible ? implicitHeight : 0
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: visible ? 11 : 0
        anchors.rightMargin: 16
        visible: root.charLimit > 0

        text: "%1 / %2".arg(statusBaseInput.text.length).arg(root.charLimit)
        font.pixelSize: 12
        color: statusBaseInput.enabled ? Theme.palette.baseColor1 : Theme.palette.directColor6
    }

    StatusBaseInput {
        id: statusBaseInput
        anchors.top:  label.visible ? label.bottom : 
                charLimitLabel.visible ? charLimitLabel.bottom : parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: charLimitLabel.visible ? 11 : 8
        anchors.leftMargin: 16
        anchors.rightMargin: 16
    }

    StatusBaseText {
        id: errorMessage

        anchors.top: statusBaseInput.bottom
        anchors.topMargin: 11
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.left: parent.left
        anchors.leftMargin: 16

        height: visible ? implicitHeight : 0
        visible: !!root.errorMessage && !statusBaseInput.valid

        font.pixelSize: 12
        color: Theme.palette.dangerColor1
        text: root.errorMessage
        horizontalAlignment: Text.AlignRight
        wrapMode: Text.WordWrap
    }
}
