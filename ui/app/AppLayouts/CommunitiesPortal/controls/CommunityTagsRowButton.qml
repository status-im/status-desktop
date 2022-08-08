import QtQuick 2.14

import utils 1.0
import shared.panels 1.0

Rectangle {
    id: root

    property bool mirrored: false

    signal clicked()

    width: height * 3

    gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop { position: mirrored ? 0.0 : 1.0; color: "transparent" }
        GradientStop { position: 0.5; color: "white" }
    }

    SVGImage {
        source: mirrored ? Style.svg("arrow-next") : Style.svg("arrow-previous")
        anchors.right: mirrored ? parent.right : undefined
        anchors.left: mirrored ? undefined : parent.left
        width: parent.height
        height: width
    }

    MouseArea {
        anchors.fill: parent
        preventStealing: true
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}