import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../imports"
import ".."
import "."

Rectangle {
    property alias text: textElement.text
    property var buttonGroup
    property bool checked: false
    property bool isHovered: false
    signal radioCheckedChanged(checked: bool)

    id: root
    height: 52
    color: isHovered ? Style.current.backgroundHover : Style.current.transparent
    radius: Style.current.radius
    border.width: 0
    anchors.left: parent.left
    anchors.leftMargin: -Style.current.padding
    anchors.right: parent.right
    anchors.rightMargin: -Style.current.padding


    StyledText {
        id: textElement
        text: ""
        font.pixelSize: 15
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
    }

    MouseArea {
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.isHovered = true
        onExited: root.isHovered = false
        onClicked: {
            radioButton.checked = true
        }
    }

    StatusRadioButton {
        id: radioButton
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        ButtonGroup.group: root.buttonGroup
        rightPadding: 0
        checked: root.checked
        onCheckedChanged: root.radioCheckedChanged(checked)
        MouseArea {
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent
            onPressed: mouse.accepted = false
            onEntered: root.isHovered = true
        }
    }

}
