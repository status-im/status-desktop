import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

Rectangle {
    id: root

    border.color: 'red'
    color: 'transparent'

    QtObject {
        id: internal

        property Item originalParent
        property int counter: 0

        PropertyAnimation on counter {
            id: positionUpdater

            running: false
            from: 0
            to: 1000
            duration: 1000
            loops: Animation.Infinite
        }

        onCounterChanged: {
            const overlay = originalParent.Overlay.overlay

            if (!overlay)
                return

            root.parent = overlay
            root.visible = originalParent.visible
            const rect = originalParent.mapToItem(
                           overlay, 0, 0, originalParent.width, originalParent.height)
            root.x = rect.x
            root.y = rect.y
            root.width = rect.width
            root.height = rect.height
        }
    }

    Component.onCompleted: {
        if (parent instanceof ColumnLayout
                || parent instanceof RowLayout
                || parent instanceof GridLayout
                || parent instanceof Column
                || parent instanceof Row
                || parent instanceof Grid
                || parent instanceof Flow) {
            internal.originalParent = parent
            positionUpdater.running = true
        } else {
            if (!anchors.fill)
                anchors.fill = parent
        }
    }
}
