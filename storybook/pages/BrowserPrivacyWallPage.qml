import QtQuick
import QtQuick.Controls

import AppLayouts.Browser

import Storybook

SplitView {
    id: root

    Logs { id: logs }

    BrowserPrivacyWall {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        onOpenThirdpartyServicesInfoPopupRequested: logs.logEvent("Enable third party services requested")
        onOpenDiscussPageRequested: logs.logEvent("Open discuss page requested")
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText
    }
}

// category: Layouts
// status: good
// https://www.figma.com/design/idUoxN7OIW2Jpp3PMJ1Rl8/Settings----Desktop-Legacy?node-id=27024-24709&m=dev
