import QtQuick 2.15

import StatusQ.Core.Theme 0.1

SequentialAnimation {
    id: root

    property var target: null
    property color fromColor: Theme.palette.directColor1
    property color toColor: Theme.palette.getColor(fromColor, 0.1)
    property int duration: 500 // in milliseconds

    loops: 3

    ColorAnimation {
        target: root.target
        property: "color"
        from: root.fromColor
        to: root.toColor
        duration: root.duration
    }

    ColorAnimation {
        target: root.target
        property: "color"
        from: root.toColor
        to: root.fromColor
        duration: root.duration
    }
}
