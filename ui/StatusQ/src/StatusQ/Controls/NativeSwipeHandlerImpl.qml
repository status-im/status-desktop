import QtQuick 2.15

Item {
    id: root

    // See NativeSwipeHandler.qml
    property real openDistance: 0

    signal swipeStarted(real from, real to)
    signal swipeProgress(real position, real from, real to, real velocity)
    signal swipeEnded(bool committed, real from, real to, real velocity)

    QtObject {
        id: d
        property bool active: false
        property real startX: 0
        property real startTime: 0
        property real from: 0
        property real to: 1

        function nowMs() { return Date.now() }

        function effectiveOpenDistance() {
            return root.openDistance > 0 ? root.openDistance : 280
        }

        function velocityPxPerSec(deltaX) {
            const dt = Math.max(1, nowMs() - startTime)
            return (deltaX / dt) * 1000.0
        }
    }

    MouseArea {
        anchors.fill: parent
        preventStealing: false
        propagateComposedEvents: true

        onPressed: (mouse) => {
            d.active = true
            d.startX = mouse.x
            d.startTime = d.nowMs()

            // Infer direction from current position (based on x/openDistance).
            const dist = d.effectiveOpenDistance()
            const currentPos = Math.max(0.0, Math.min(1.0, root.x / Math.max(1.0, dist)))
            if (currentPos >= 0.5) {
                d.from = 1.0
                d.to = 0.0
            } else {
                d.from = 0.0
                d.to = 1.0
            }

            root.swipeStarted(d.from, d.to)
            mouse.accepted = true
        }

        onPositionChanged: (mouse) => {
            if (!d.active) {
                mouse.accepted = false
                return
            }

            const dx = mouse.x - d.startX
            const v = d.velocityPxPerSec(dx)
            const dist = Math.max(1.0, d.effectiveOpenDistance())

            let pos = 0.0
            if (d.from < d.to) {
                pos = Math.max(0.0, Math.min(1.0, dx / dist))
            } else {
                pos = Math.max(0.0, Math.min(1.0, 1.0 + (dx / dist)))
            }

            root.swipeProgress(pos, d.from, d.to, v)
            mouse.accepted = true
        }

        onReleased: (mouse) => {
            if (!d.active) {
                mouse.accepted = false
                return
            }

            const dx = mouse.x - d.startX
            const v = d.velocityPxPerSec(dx)
            const dist = Math.max(1.0, d.effectiveOpenDistance())

            const committed = Math.abs(dx) > (dist * 0.5) || Math.abs(v) > 500

            d.active = false
            root.swipeEnded(committed, d.from, d.to, v)
            mouse.accepted = true
        }

        onCanceled: {
            if (d.active) {
                d.active = false
                root.swipeEnded(false, d.from, d.to, 0)
            }
        }
    }
}


