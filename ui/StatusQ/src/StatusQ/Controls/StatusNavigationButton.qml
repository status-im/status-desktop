import QtQuick 2.14

import StatusQ.Core.Theme 0.1

Rectangle {
    id: root

    property bool mirrored: false
    property color gradientColor: Theme.palette.statusAppLayout.backgroundColor

    signal clicked()

    width: height * 2

    gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop { position: mirrored ? 0.0 : 1.0; color: "transparent" }
        GradientStop { position: 0.5; color: root.gradientColor }
    }

    // TODO: use SVGImage (move SVGImage to StatusQ)
    Image {
        source: mirrored ? d.iconSrc("arrow-next") : d.iconSrc("arrow-previous")
        anchors.right: mirrored ? parent.right : undefined
        anchors.left: mirrored ? undefined : parent.left
        width: parent.height
        height: width
        sourceSize: Qt.size(width, height)
    }

    MouseArea {
        anchors.fill: parent
        preventStealing: true
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    QtObject {
        id: d

        function iconSrc(icon) {
            return "../../assets/img/icons/" + icon + ".svg";
        }
    }
}
