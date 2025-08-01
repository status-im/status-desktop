import QtQuick
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Core.Theme

Button {
    id: root

    property color gradientColor: Theme.palette.statusAppLayout.backgroundColor
    property bool navigateForward: false

    width: height * 2
    padding: 0
    hoverEnabled: true

    background: Rectangle {
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: navigateForward ? 0.0 : 1.0; color: "transparent" }
            GradientStop { position: 0.5; color: root.gradientColor }
        }
    }

    contentItem: Item {
        StatusIcon {
            icon: navigateForward ? "next" : "previous"
            anchors.right: navigateForward ? parent.right : undefined
            anchors.left: navigateForward ? undefined : parent.left
            width: parent.height
            height: width
            color: Theme.palette.primaryColor1
        }


        // otherwise there is no pointing hand cursor when button is hovered
        StatusMouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            cursorShape: Qt.PointingHandCursor
        }
    }
}
