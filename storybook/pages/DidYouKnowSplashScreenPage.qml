import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Storybook

import utils
import mainui
import shared.panels

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
            messagesEnabled: ctrlMessagesEnabled.checked
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300
        ColumnLayout {
            Layout.fillWidth: true
            Label {
                text: "Progress"
            }
            Slider {
                id: progressSlider
            }
            Switch {
                id: ctrlMessagesEnabled
                text: "Messages enabled"
            }
        }
    }
}

// category: Panels
// status: good
// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba⎜Desktop?node-id=25878%3A518438&t=C7xTpNib38t7s7XU-4
