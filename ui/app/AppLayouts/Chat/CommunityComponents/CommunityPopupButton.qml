import QtQuick 2.12
import QtQuick.Dialogs 1.3
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"
import "../ContactsColumn"
import QtGraphicalEffects 1.13

Rectangle {
    property bool isHovered: false
    property string type: "primary"

    id: root
    width: parent.width
    height: 64

    default property alias actionContent: placeholder.data
    signal clicked()

    property string iconName
    property string label
    property string txtColor: Style.current.blue

    color: isHovered ? Style.current.secondaryBackground : Style.current.transparent
    radius: Style.current.radius

    Item {
        id: contentItem
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        anchors.verticalCenter: parent.verticalCenter
        width: btn.width + btnLabel.width + Style.current.padding
        height: btn.height

        StatusRoundButton {
            id: btn
            anchors.verticalCenter: parent.verticalCenter
            type: root.type
            icon.name: "communities/" + iconName
            width: 40
            height: 40
        }

        StyledText {
            id: btnLabel
            text: label
            color: txtColor
            anchors.left: btn.right
            anchors.leftMargin: Style.current.padding
            anchors.verticalCenter: btn.verticalCenter
            font.pixelSize: 15
        }
    }

    Item {
        id: placeholder
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onEntered: root.isHovered = true
        onExited: root.isHovered = false
        onClicked: root.clicked()
    }
}
