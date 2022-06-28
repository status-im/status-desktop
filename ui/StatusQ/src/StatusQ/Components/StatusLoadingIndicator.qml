import QtQuick 2.13
import StatusQ.Core 0.1

StatusIcon {
    id: statusIcon
    icon: "loading"
    height: 17
    width: 17
    RotationAnimation {
        target: statusIcon;
        from: 0;
        to: 360;
        duration: 1200
        running: visible
        loops: Animation.Infinite
    }
}

