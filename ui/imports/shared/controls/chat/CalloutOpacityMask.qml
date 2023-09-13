import QtQuick 2.15
import QtGraphicalEffects 1.15

import utils 1.0

OpacityMask {
    id: root
    property bool leftTail: true
    readonly property int smallCorner: Style.current.radius / 2
    readonly property int bigCorner: Style.current.radius * 2
    readonly property int fakeCornerSize: bigCorner * 2

    cached: true
    maskSource: Item {
        width: root.width
        height: root.height

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            width: parent.width
            height: parent.height
            radius: root.bigCorner
        }

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: root.fakeCornerSize
            height: root.fakeCornerSize
            radius: root.smallCorner
            visible: root.leftTail
        }
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            width: root.fakeCornerSize
            height: root.fakeCornerSize
            radius: root.smallCorner
            visible: !root.leftTail
        }
    }
}