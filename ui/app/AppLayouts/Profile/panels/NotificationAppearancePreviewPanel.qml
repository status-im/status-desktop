import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Controls
import StatusQ.Core
import StatusQ.Core.Theme

Control {
    property bool checked: false
    property string name
    property string notificationTitle
    property string notificationMessage
    property var buttonGroup
    property bool isHovered: false
    signal radioCheckedChanged(checked: bool)

    id: root

    background: Rectangle {
        color: radioButton.checked ? Theme.palette.secondaryBackground :
                                     (isHovered ? Theme.palette.backgroundHover
                                                : Theme.palette.transparent)
        radius: Theme.radius
    }

    padding: Theme.padding

    contentItem: ColumnLayout {
        id: container

        StatusRadioButton {
            id: radioButton

            Layout.fillWidth: true

            text: root.name
            ButtonGroup.group: root.buttonGroup || null
            checked: root.checked
            onCheckedChanged: root.radioCheckedChanged(checked)
        }

        StatusNotificationWithDropShadowPanel {
            id: notificationPreview

            Layout.fillWidth: true

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
            if (!radioButton.checked)
                root.radioCheckedChanged(true)
        }

        cursorShape: Qt.PointingHandCursor
    }
}

