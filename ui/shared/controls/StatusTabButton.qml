import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0
import "../"
import "../panels"

TabButton {
    property string btnText: "Default Button"

    id: tabButton
    width: tabBtnText.width
    height: tabBtnText.height + 11
    text: ""
    padding: 0
    background: Rectangle {
        color: Style.current.transparent
        border.width: 0
    }

    StyledText {
        id: tabBtnText
        text: btnText
        font.weight: Font.Medium
        font.pixelSize: 15
        color: parent.checked || parent.hovered ? Style.current.textColor : Style.current.secondaryText
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
