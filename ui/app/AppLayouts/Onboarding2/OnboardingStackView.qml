import QtQuick 2.15
import QtQuick.Controls 2.15


StackView {
    id: root

    QtObject {
        id: d

        readonly property int opacityDuration: 50
        readonly property int swipeDuration: 400
    }

    pushEnter: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 0; to: 1
                duration: d.opacityDuration
                easing.type: Easing.InQuint
            }
            NumberAnimation {
                property: "x"
                from: (root.mirrored ? -0.3 : 0.3) * root.width; to: 0
                duration: d.swipeDuration
                easing.type: Easing.OutCubic
            }
        }
    }
    pushExit: Transition {
        NumberAnimation {
            property: "opacity"; from: 1; to: 0
            duration: d.opacityDuration
            easing.type: Easing.OutQuint
        }
    }
    popEnter: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 0; to: 1
                duration: d.opacityDuration
                easing.type: Easing.InQuint
            }
            NumberAnimation {
                property: "x"
                from: (root.mirrored ? -0.3 : 0.3) * -root.width; to: 0
                duration: d.swipeDuration; easing.type: Easing.OutCubic
            }
        }
    }
    popExit: pushExit
    replaceEnter: pushEnter
    replaceExit: pushExit
}
