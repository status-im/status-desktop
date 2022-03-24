import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0
import "../"
import "../panels"

import StatusQ.Core 0.1
import StatusQ.Components 0.1

TabButton {
    property string btnText: "Default Button"
    property int addToWidth: 0

    property alias badge: statusBadge

    id: tabButton
    width: tabBtnText.width +
           (statusBadge.visible ? statusBadge.width + statusBadge.anchors.leftMargin : 0) +
           addToWidth

    height: tabBtnText.height + 11
    text: ""
    padding: 0
    background: Rectangle {
        color: Style.current.transparent
        border.width: 0
    }

    StyledText {
        id: tabBtnText
        anchors.horizontalCenter: parent.horizontalCenter
        text: btnText
        font.weight: Font.Medium
        font.pixelSize: 15
        color: parent.checked || parent.hovered ? Style.current.textColor : Style.current.secondaryText
    }

    StatusBadge {
        id: statusBadge
        visible: value > 0
        anchors.left: tabBtnText.right
        anchors.leftMargin: 10
        anchors.verticalCenter: tabBtnText.verticalCenter
    }

    Rectangle {
        visible: parent.checked || parent.hovered
        color: parent.checked ? Style.current.primary : Style.current.secondaryBackground
        anchors.bottom: parent.bottom
        width: 40
        anchors.horizontalCenter: parent.horizontalCenter
        height: 3
        radius: 4
    }

    MouseArea {
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        onPressed: mouse.accepted = false
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";formeditorZoom:1.75}
}
##^##*/
