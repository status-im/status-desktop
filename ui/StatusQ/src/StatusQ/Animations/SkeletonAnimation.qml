import QtQuick 2.14
import QtGraphicalEffects 1.14

Item {
    id: root

    property Item mask
    property color color: "#F6F8FA"

    Rectangle {
        id: gradient
        anchors.fill: parent
        visible: false

        gradient: Gradient {
            orientation: Gradient.Horizontal
            SkeletonGradientStop { color: "transparent"; from: -3; }
            SkeletonGradientStop { color: "transparent"; from: -2; }
            SkeletonGradientStop { color: root.color; from: -1 ; }
            SkeletonGradientStop { color: "transparent"; from: 0; }
            SkeletonGradientStop { color: "transparent"; from: 1; }
        }
    }

    OpacityMask {
        anchors.fill: parent
        source: gradient
        maskSource: root.mask
    }
}
