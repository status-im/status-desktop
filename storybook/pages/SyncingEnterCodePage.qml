import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Storybook 1.0

import mainui 1.0
import shared.views 1.0
import shared.stores 1.0

SplitView {
    id: root
    orientation: Qt.Vertical

    Logs { id: logs }

    Popups {
        popupParent: root
        rootStore: QtObject {}
        communityTokensStore: CommunityTokensStore {}
    }

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        SyncingEnterCode {
            id: syncView
            width: 400
            anchors.horizontalCenter: parent.horizontalCenter
            validateConnectionString: (stringValue) => !Number.isNaN(parseInt(stringValue))

            onDisplayInstructions: logs.logEvent("SyncingEnterCode::displayInstructions")
            onProceed: (connectionString) => logs.logEvent("SyncingEnterCode::proceed", ["connectionString"], arguments)
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText
    }
}

// category: Views

// "https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?type=design&node-id=1930-136137&mode=design&t=RSriG02fbmVOMAEx-0"
// "https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?type=design&node-id=13578-276069&mode=design&t=RSriG02fbmVOMAEx-0"
