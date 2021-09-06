import QtQuick 2.13
import QtQuick.Controls 2.13
import "../imports"

TabButton {
    property string btnText: "Default Button"
    implicitWidth: tabBtnText.width + 32
    id: tabButton
    padding: 0
    background: Rectangle {
        implicitHeight: 36
        color: Style.current.transparent
        border.width: 0

        Rectangle {
            visible: tabButton.checked || tabButton.hovered
            color: tabButton.checked ? Style.current.primary : Style.current.secondaryBackground
            anchors.bottom: parent.bottom
            width: 24
            anchors.horizontalCenter: parent.horizontalCenter
            height: 3
            radius: 4
        }
    }

    contentItem: Item {
        height: 36
        StyledText {
            id: tabBtnText
            text: btnText
            font.weight: Font.Medium
            font.pixelSize: 15
            color: tabButton.checked || tabButton.hovered ? Style.current.textColor : Style.current.secondaryText
            anchors.horizontalCenter: parent.horizontalCenter
        }
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
