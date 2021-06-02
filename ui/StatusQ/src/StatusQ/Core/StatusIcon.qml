import QtQuick 2.13
import QtGraphicalEffects 1.13

Image {
    property string icon: ""
    property color color: "transparent"

    id: statusIcon
    width: 24
    height: 24
    sourceSize.width: width
    sourceSize.height: height
    fillMode: Image.PreserveAspectFit

    onIconChanged: {
        if (icon !== "") {
            source = "../../assets/img/icons/" + icon + ".svg";
        }
    }

    ColorOverlay {
        visible: !Qt.colorEqual(statusIcon.color, "transparent")
        anchors.fill: statusIcon
        source: statusIcon
        color: statusIcon.color
        antialiasing: true
        smooth: true
    }
}

