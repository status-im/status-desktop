import QtQuick 2.13
import StatusQ.Core 0.1

StatusIcon {
    id: root
    icon: "loading"
    height: 17
    width: 17
    RotationAnimator {
        target: root
        from: 0
        to: 360
        duration: 1200
        running: visible
        loops: Animation.Infinite
    }
}
