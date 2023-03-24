import QtQuick 2.13
import QtGraphicalEffects 1.13

Image {
    id: root

    property string icon: ""
    property color color: "transparent"

    width: 24
    height: 24
    // SVGs must have sourceSize, PNGs not; otherwise blurry
    sourceSize: !!icon ? Qt.size(width, height) : undefined
    fillMode: Image.PreserveAspectFit

    onIconChanged: {
        if(icon.startsWith("data:image/") || icon.startsWith("https://")) {
            //raw image data
            source = icon
            objectName = "custom-icon"
        }
        else if (icon !== "") {
            source = "../../assets/img/icons/" + icon+ ".svg";
            objectName = icon + "-icon"
        }
    }

    Loader {
        anchors.fill: root
        active: !Qt.colorEqual(root.color, "transparent")
        sourceComponent: ColorOverlay {
            source: root
            color: root.color
            smooth: true
        }
    }
}
