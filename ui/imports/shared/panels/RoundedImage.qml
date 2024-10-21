import QtQuick 2.15
import QtGraphicalEffects 1.15

import StatusQ.Core.Theme 0.1

import utils 1.0

Rectangle {
    id: root
    signal clicked
    property bool noMouseArea: false
    property bool noHover: false
    property alias showLoadingIndicator: imgStickerPackThumb.showLoadingIndicator
    property alias source: imgStickerPackThumb.source
    property alias fillMode: imgStickerPackThumb.fillMode

    radius: width / 2

    width: 24
    height: 24
    color: Theme.palette.background

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
        noMouseArea: root.noMouseArea
        noHover: root.noHover
        opacity: 1
        smooth: false
        radius: root.radius
        anchors.fill: parent
        onClicked: root.clicked()
    }
}
