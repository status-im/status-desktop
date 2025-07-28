import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import AppLayouts.ActivityCenter.views

import Storybook

SplitView {
    id: root

    orientation: Qt.Vertical

    Logs { id: logs }

    QtObject {
        id: notificationMock

        property string id: "1"
        property string title: "Swaps around the corner!"
        property string description: "Status Desktop’s next release brings the app up-to-speed with Status Mobile. That means: SWAPS!"
        property double timestamp: Date.now()
        property double previousTimestamp: 0
        property bool read: false
        property bool dismissed: false
        property bool accepted: false
    }

    Item {
        SplitView.fillHeight: true
        SplitView.fillWidth: true

        ActivityNotificationNewsMessage {
            id: notification

            anchors.centerIn: parent
            width: 576
            height: implicitHeight

            notification: notificationMock

            onReadMoreClicked: logs.logEvent("ActivityNotificationNewsMessage::onReadMoreClicked")
        }

    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 160

        logsView.logText: logs.logText
    }
}

// category: Activity Center
// https://www.figma.com/design/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=39555-95032&m=dev
