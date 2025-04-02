import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Controls 0.1
import StatusQ.Platform 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

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
        width: notificationPreview.width + Theme.padding * 2
        height: childrenRect.height + Theme.padding + Theme.halfPadding
        color: radioButton.checked ? Theme.palette.secondaryBackground :
                                     (isHovered ? Theme.palette.backgroundHover : Theme.palette.transparent)
        radius: Theme.radius

        StatusRadioButton {
            id: radioButton
            text: root.name
            ButtonGroup.group: root.buttonGroup
            checked: root.checked
            onCheckedChanged: root.radioCheckedChanged(checked)
            anchors.top: parent.top
            anchors.topMargin: Theme.halfPadding
            anchors.left: parent.left
            anchors.leftMargin: Theme.padding
        }

        StatusNotificationWithDropShadowPanel {
            id: notificationPreview
            anchors.top: radioButton.bottom
            anchors.topMargin: Theme.halfPadding
            anchors.left: parent.left
            name: root.notificationTitle
            message: root.notificationMessage
        }
    }

    StatusMouseArea {
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

