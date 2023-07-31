import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

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
            id: splashScreen
            SplitView.fillHeight: true
            SplitView.fillWidth: true
            progress: progressSlider.position
        }
    }

    Pane {
         SplitView.minimumWidth: 300
         SplitView.preferredWidth: 300
         RowLayout {
             Label {
                 text: "Progress"
             }
             Slider {
                id: progressSlider
             }
         }
    }
}

// category: Panels
