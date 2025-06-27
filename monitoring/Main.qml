import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Core.Utils 0.1 as SQUtils

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
            const content = SQUtils.StringUtils.readTextFile(
                              Qt.resolvedUrl("MonitorEntryPoint.qml"))

            if (loader.source !== content)
                loader.source = content
        }
    }

    HotLoader {
        id: loader

        anchors.fill: parent
    }
}
