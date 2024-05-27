import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1

import AppLayouts.Wallet.controls 1.0

import Storybook 1.0

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Vertical

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        SwapExchangeButton {
            id: button
            anchors.centerIn: parent
            onClicked: logs.logEvent("onClicked", [], arguments)
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText
    }
}

// category: Controls
