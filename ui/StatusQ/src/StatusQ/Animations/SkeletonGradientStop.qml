import QtQuick 2.14
import QtGraphicalEffects 1.14

/*
    TODO:   This component should be implemented as inline component of `SkeletonAnimation.qml`
            when we use Qt > 5.15
*/

GradientStop {
    id: root

    property real from: 0

    color: "transparent"

    NumberAnimation on position {
        easing.type: Easing.Linear
        loops: Animation.Infinite
        running: visible
        from: root.from
        to: from + 4
        duration: 2000
    }
}
