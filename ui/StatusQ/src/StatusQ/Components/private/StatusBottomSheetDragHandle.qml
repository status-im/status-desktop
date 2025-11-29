import QtQuick

import StatusQ.Core.Theme

Rectangle {
    id: root

    // To be used together with components deriving from QQC2.Popup

    // required to provide the drag/swipe functionality (must have a contentItem to parent to)
    // if not provided, acts just like a visual indicator
    property var dragObjectRoot

    // threshold in pixels after which the closeRequested() signal is emitted
    property int dragToCloseThreshold: 100

    // returns whether the drag operation is currently active
    readonly property bool active: dragHandler.active

    // emitted when dragToCloseThreshold has been reached
    signal closeRequested()

    // required to setup the "original" Y position, e.g. when switching to the `bottomSheet` mode
    // to be able to return to bounds if dropped when the dragToCloseThreshold hasn't been reached
    function setOriginalYPos(oldY) {
        d.accuY = 0
        d.oldY = oldY
    }

    implicitWidth: 64
    implicitHeight: 4
    radius: 2
    color: Theme.palette.baseColor1

    QtObject {
        id: d
        property int oldY

        property real accuY
        onAccuYChanged: if (accuY > dragToCloseThreshold) root.closeRequested()
    }

    Connections {
        target: root.dragObjectRoot ?? null
        function onOpened() { // reset the accumulated drag, and sets
            setOriginalYPos(root.dragObjectRoot.y)
        }
    }

    DragHandler {
        id: dragHandler
        target: null

        margin: 20
        onActiveChanged: {
            if (active) {
                root.dragObjectRoot.anchors.centerIn = undefined // tear out, start moving
            } else {
                root.dragObjectRoot.y = d.oldY // return to bounds
                d.accuY = 0
            }
        }

        xAxis.enabled: false
        yAxis.enabled: true
        yAxis.minimum: d.oldY
        yAxis.onActiveValueChanged: function(value) {
            if (value > 0) { // can't drag up
                root.dragObjectRoot.y += value
                d.accuY += value
            }
        }
    }
}
