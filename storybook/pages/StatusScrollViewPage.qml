import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import StatusQ.Core 0.1

import Storybook 1.0
import Models 1.0
import utils 1.0

SplitView {
    id: root

    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Loader {
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            sourceComponent: StatusScrollView {
                anchors.fill: parent
                anchors.margins: 8
                contentWidth: parent.width
                contentHeight: rect.height
                Rectangle {
                    id: rect
                    width: 300
                    height: 800
                    color: Qt.rgba(Math.random(), Math.random(), Math.random(), 255)
                }
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 200

            logsView.logText: logs.logText
        }
    }

    Pane {
         SplitView.minimumWidth: 300
         SplitView.preferredWidth: 300
     }
}
