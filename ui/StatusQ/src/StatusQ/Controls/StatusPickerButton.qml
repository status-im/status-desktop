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
    signal clicked()

    background: Item {
        anchors.fill: parent
        Rectangle {
            id: background
            anchors.fill: parent
            radius: 8
            color: root.bgColor
        }
        StatusIcon {
            id: nextIcon
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            icon: "next"
            color: !Qt.colorEqual(root.contentColor, Theme.palette.baseColor1)
                   ? root.contentColor : Theme.palette.directColor1
        }
    }

    contentItem: Item {
        anchors.fill: parent
        StatusBaseText {
            id: textLabel
            anchors {
                fill: parent
                leftMargin: 16
            }
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 15
            color: root.contentColor
            text: root.text
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.clicked();
        }
    }
}
