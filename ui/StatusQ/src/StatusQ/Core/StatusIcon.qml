import QtQuick 2.13
import QtGraphicalEffects 1.13

Image {
    property string icon: ""
    property color color: "transparent"

    id: statusIcon
    width: 24
    height: 24
    // SVGs must have sourceSize, PNGs not; otherwise blurry
    sourceSize: !!icon ? Qt.size(width, height) : undefined
    fillMode: Image.PreserveAspectFit

    onIconChanged: {
        if(icon.startsWith("data:image/") || icon.startsWith("https://") || icon.startsWith("qrc:/") || icon.startsWith("file:/")) {
            //raw image data
            source = icon
            objectName = "custom-icon"
        } else if (icon !== "") {
            source = "../../assets/img/icons/" + icon+ ".svg";
            objectName = icon + "-icon"
        }
    }

    layer.smooth: true
    layer.format: ShaderEffectSource.RGBA
    layer.enabled: !Qt.colorEqual(statusIcon.color, "transparent")
    layer.effect: ColorOverlay {
        color: statusIcon.color
    }
}
