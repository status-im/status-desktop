import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root

    z: 1000
    border.color: 'red'
    color: 'transparent'

    QtObject {
        id: d

        property Item originalParent
    }

    Timer {
        id: positionUpdateTimer

        interval: 500
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            const overlay = d.originalParent.Overlay.overlay

            if (!overlay)
                return

            root.parent = overlay
            root.visible = d.originalParent.visible
            const rect = d.originalParent.mapToItem(overlay, 0, 0,
                                                    d.originalParent.width,
                                                    d.originalParent.height)
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
                || parent instanceof StackLayout
                || parent instanceof Column
                || parent instanceof Row
                || parent instanceof Grid
                || parent instanceof Flow) {
            d.originalParent = parent
            positionUpdateTimer.running = true
        } else {
            if (!anchors.fill)
                anchors.fill = parent
        }
    }
}
