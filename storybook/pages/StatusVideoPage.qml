import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Components 0.1

import Storybook 1.0

SplitView {
    id: root

    orientation: Qt.Vertical
    Logs { id: logs }

    Rectangle {

        anchors.fill: parent
        color: videoPlayer.isLoading ? "yellow" : "transparent"
        border.color: videoPlayer.isError ? "red" : "green"

        StatusVideo {
            id: videoPlayer

            anchors.fill: parent
            source: "qrc:/testData/file_example1.mov"
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 200
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText
    }
}

// category: Components
// status: good
