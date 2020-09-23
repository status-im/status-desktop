import QtQuick 2.12
import QtGraphicalEffects 1.0

Rectangle {
    id: root
    signal clicked
    property alias source: imgStickerPackThumb.source

    radius: width / 2

    width: 24
    height: 24

    // apply rounded corners mask
    layer.enabled: true
    layer.effect: OpacityMask {
        maskSource: Rectangle {
            x: root.x; y: root.y
            width: root.width
            height: root.height
            radius: root.radius
        }
    }

    ImageLoader {
        id: imgStickerPackThumb
        opacity: 1
        smooth: false
        radius: root.radius
        anchors.fill: parent
        source: "https://ipfs.infura.io/ipfs/" + thumbnail
        onClicked: root.clicked()
    }
}