import QtQuick 2.13
import QtQuick.Controls 2.13
import "./"
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

Item {
    property bool checked: false
    property string name
    property string notificationTitle
    property string notificationMessage
    property var buttonGroup
    property bool isHovered: false
    signal radioCheckedChanged(checked: bool)

    id: root
    height: container.height
    width: container.width

    Rectangle {
        id: container
        width: notificationPreview.width + Style.current.padding * 2
        height: childrenRect.height + Style.current.padding + Style.current.halfPadding
        color: radioButton.checked ? Style.current.secondaryBackground :
                                     (isHovered ? Style.current.backgroundHover : Style.current.transparent)
        radius: Style.current.radius

        StatusRadioButton {
            id: radioButton
            text: root.name
            ButtonGroup.group: root.buttonGroup
            checked: root.checked
            onCheckedChanged: root.radioCheckedChanged(checked)
            anchors.top: parent.top
            anchors.topMargin: Style.current.halfPadding
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding
        }

        StatusNotificationWithDropShadow {
            id: notificationPreview
            anchors.top: radioButton.bottom
            anchors.topMargin: Style.current.halfPadding
            anchors.left: parent.left
            name: root.notificationTitle
            chatType: Constants.chatTypePublic
            message: root.notificationMessage
        }

    }

    MouseArea {
        anchors.fill: container
        hoverEnabled: true
        onEntered: root.isHovered = true
        onExited: root.isHovered = false
        onClicked: {
            if (!radioButton.checked) {
                root.radioCheckedChanged(true)
            }
        }

        cursorShape: Qt.PointingHandCursor
    }
}

