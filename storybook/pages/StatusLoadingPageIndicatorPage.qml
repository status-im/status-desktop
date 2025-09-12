import QtQuick
import QtQuick.Controls

import StatusQ.Components
import StatusQ.Core.Theme

import Storybook

SplitView {
    Logs { id: logs }

    Rectangle {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        color: Theme.palette.transparent

        StatusLoadingPageIndicator {
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: 50
            width: parent.width

            count: 4
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText
    }
}

// category: Components
// status: good
// https://www.figma.com/design/idUoxN7OIW2Jpp3PMJ1Rl8/Settings----Desktop-Legacy?node-id=26157-27034&m=dev
