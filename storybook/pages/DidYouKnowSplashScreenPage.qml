import QtQuick 2.15
import QtQuick.Controls 2.15

import Storybook 1.0

import utils 1.0
import mainui 1.0
import shared.panels 1.0

SplitView {
    Logs { id: logs }
    SplitView {
        SplitView.fillHeight: true
        SplitView.fillWidth: true
        orientation: Qt.Vertical
        DidYouKnowSplashScreen {
            SplitView.fillHeight: true
            SplitView.fillWidth: true
            NumberAnimation on progress { from: 0.0; to: 1; duration: 10000; loops: Animation.Infinite}
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
