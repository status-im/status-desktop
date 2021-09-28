import QtQuick 2.13
import QtGraphicalEffects 1.13
import utils 1.0

Image {
    property string icon: ""
    property color color

    id: root
    width: 24
    height: 24
    sourceSize.width: width
    sourceSize.height: height
    fillMode: Image.PreserveAspectFit

    onIconChanged: {
        if (icon !== "") {
            source = Style.icon(icon);
        }
    }

    ColorOverlay {
        visible: root.color !== undefined
        anchors.fill: root
        source: root
        color: root.color
        antialiasing: true
        smooth: true
        rotation: root.rotation
    }
}

