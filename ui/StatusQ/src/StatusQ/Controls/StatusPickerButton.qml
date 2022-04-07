import QtQuick 2.14
import QtQuick.Controls 2.12

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Button {
    id: root
    implicitWidth: 446
    implicitHeight: 44

    property color bgColor: Theme.palette.baseColor2
    property color contentColor: Theme.palette.baseColor1
    property var type: StatusPickerButton.Type.Next
    property int lateralMargins: 16
    property int textPixelSize: 15

    enum Type {
        Next,
        Down
    }

    background: Item {
        anchors.fill: parent
        Rectangle {
            id: background
            anchors.fill: parent
            radius: 8
            color: root.bgColor
        }   
    }

    contentItem: Item {
        anchors.fill: parent
        state: root.type === StatusPickerButton.Type.Next ? "NEXT" : "DOWN"

        StatusBaseText {
            id: textLabel
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - icon.width - anchors.rightMargin - anchors.leftMargin - icon.anchors.rightMargin - icon.anchors.leftMargin
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: root.textPixelSize
            color: root.contentColor
            text: root.text
            clip: true
            elide: Text.ElideRight
        }

        StatusIcon {
            id: icon
            anchors.verticalCenter: parent.verticalCenter
            color: !Qt.colorEqual(root.contentColor, Theme.palette.baseColor1) ? root.contentColor : Theme.palette.directColor1
        }

        states: [
            State {
                name: "NEXT"
                PropertyChanges {target: icon; icon: "next"}
                PropertyChanges {target: icon; anchors.left: undefined }
                PropertyChanges {target: icon; anchors.right: parent.right }
                PropertyChanges {target: icon; anchors.rightMargin: root.lateralMargins / 2 }
                PropertyChanges {target: icon; anchors.leftMargin: root.lateralMargins / 2 }
                PropertyChanges {target: textLabel; anchors.left: parent.left }
                PropertyChanges {target: textLabel; anchors.right: undefined }
                PropertyChanges {target: textLabel; anchors.rightMargin: undefined }
                PropertyChanges {target: textLabel; anchors.leftMargin: root.lateralMargins }
            },
            State {
                name: "DOWN"
                PropertyChanges {target: icon; icon: "chevron-down"}
                PropertyChanges {target: icon; anchors.left: parent.left }
                PropertyChanges {target: icon; anchors.right: undefined }
                PropertyChanges {target: icon; anchors.rightMargin: root.lateralMargins / 2 }
                PropertyChanges {target: icon; anchors.leftMargin: root.lateralMargins }
                PropertyChanges {target: textLabel; anchors.left: icon.right }
                PropertyChanges {target: textLabel; anchors.right: undefined }
                PropertyChanges {target: textLabel; anchors.rightMargin: root.lateralMargins / 2 }
                PropertyChanges {target: textLabel; anchors.leftMargin: undefined }
            }
        ]
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: { root.clicked() }
    }
}
