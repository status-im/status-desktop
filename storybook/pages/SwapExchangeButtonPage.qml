import QtQuick
import QtQuick.Controls

import StatusQ.Core

import AppLayouts.Wallet.controls

import Storybook

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
