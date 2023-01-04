import QtQuick 2.14
import QtQuick.Controls 2.14

ApplicationWindow {
    id: monitorRoot

    width: 800
    height: 600

    visible: true
    title: "Status Monitor"

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            const xhr = new XMLHttpRequest()
            xhr.open("GET", "MonitorEntryPoint.qml", false)
            xhr.send()

            const content = xhr.responseText

            if (loader.source != content)
                loader.source = content
        }
    }

    HotLoader {
        id: loader

        anchors.fill: parent
    }
}
