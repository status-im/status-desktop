import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Shapes 1.5
import Qt5Compat.GraphicalEffects

import StatusQ.Core.Theme 0.1

import utils 1.0
import shared 1.0
import shared.controls 1.0


Control {
    id: root

    property bool leftTail: true
    property color backgroundColor: Theme.palette.background
    property color borderColor: Theme.palette.border
    property bool dashedBorder: false
    property bool dropShadow: false
    property real borderWidth: 1

    readonly property Component clippingEffect: CalloutOpacityMask {
        width: parent.width
        height: parent.height
        leftTail: root.leftTail
    }

    background: ShapeRectangle {
        path.fillColor: root.backgroundColor
        path.strokeColor: root.borderColor
        path.strokeWidth: root.borderWidth
        path.strokeStyle: root.dashedBorder ? ShapePath.DashLine : ShapePath.SolidLine
        radius: Theme.radius * 2
        leftBottomRadius: root.leftTail ? Theme.radius / 2 : Theme.radius * 2
        rightBottomRadius: root.leftTail ? Theme.radius * 2 : Theme.radius / 2
        layer.enabled: root.dropShadow
        layer.effect: DropShadow {
            verticalOffset: 3
            radius: 8
            samples: 15
            fast: true
            cached: true
            color: Theme.palette.dropShadow
        }
    }
}
