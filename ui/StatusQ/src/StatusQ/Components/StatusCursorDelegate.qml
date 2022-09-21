import QtQuick 2.14
import StatusQ.Core.Theme 0.1

Rectangle {
    id: root
    color: Theme.palette.primaryColor1
    implicitWidth: 2
    implicitHeight: 22
    radius: 1

    SequentialAnimation on visible {
        loops: Animation.Infinite
        running: parent.visible
        PropertyAnimation { to: false; duration: 600; }
        PropertyAnimation { to: true; duration: 600; }
    }
}
