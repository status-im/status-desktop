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

    antialiasing: true
    mipmap: true

    onIconChanged: {
        if (icon !== "") {
            source = "../../assets/img/icons/" + icon + ".svg";
        }
    }

    layer.mipmap: true
    layer.smooth: true
    layer.format: ShaderEffectSource.RGBA
    layer.enabled:!Qt.colorEqual(statusIcon.color, "transparent")
    layer.effect: ColorOverlay {
        color: statusIcon.color
    }
}
