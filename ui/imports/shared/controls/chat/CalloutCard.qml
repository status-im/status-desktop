import QtQuick 2.13
import QtQuick.Controls 2.15

import utils 1.0
import shared 1.0


Control {
    id: root

    property bool leftTail: true
    property real borderWidth: 1

    readonly property Component clippingEffect: CalloutOpacityMask {
        width: parent.width
        height: parent.height
        leftTail: root.leftTail
    }
    
    background: Rectangle {
        color: Style.current.border
        layer.enabled: true
        layer.effect: root.clippingEffect

        Rectangle {
            id: clipping
            anchors.fill: parent
            anchors.margins: root.borderWidth
            color: Style.current.background
            layer.enabled: true
            layer.effect: root.clippingEffect
        }
    }
}
