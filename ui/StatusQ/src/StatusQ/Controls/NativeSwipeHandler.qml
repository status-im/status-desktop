import QtQuick 2.15
import StatusQ.Controls 0.1

Item {
    id: root

    // Normalization distance for swipe progress (logical units). Set this to the drawer width.
    // If 0, native impl uses its internal heuristics.
    property real openDistance: 0

    signal swipeStarted(real from, real to)
    signal swipeProgress(real position, real from, real to, real velocity)
    signal swipeEnded(bool committed, real from, real to, real velocity)

    Loader {
        id: implLoader
        anchors.fill: parent

        sourceComponent: Qt.platform.os === "ios" || Qt.platform.os === "android" || Qt.platform.os === "osx"
                         ? nativeComponent
                         : qmlComponent
    }

    Component {
        id: nativeComponent
        NativeSwipeHandlerNative { anchors.fill: parent }
    }

    Component {
        id: qmlComponent
        NativeSwipeHandlerImpl { anchors.fill: parent }
    }

    Binding { target: implLoader.item; property: "visible"; value: root.visible; when: implLoader.item !== null }
    Binding { target: implLoader.item; property: "enabled"; value: root.enabled; when: implLoader.item !== null }
    Binding { target: implLoader.item; property: "openDistance"; value: root.openDistance; when: implLoader.item !== null }

    Connections {
        target: implLoader.item
        enabled: implLoader.item !== null && implLoader.status === Loader.Ready

        function onSwipeStarted(from, to) { root.swipeStarted(from, to) }
        function onSwipeProgress(position, from, to, velocity) { root.swipeProgress(position, from, to, velocity) }
        function onSwipeEnded(committed, from, to, velocity) { root.swipeEnded(committed, from, to, velocity) }
    }
}


