import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import mainui.activitycenter.views 1.0

import Storybook 1.0

SplitView {
    id: root

    orientation: Qt.Vertical

    Logs { id: logs }

    QtObject {
        id: notificationMock

        property string id: "1"
        property string title: "Swaps around the corner!"
        property string description: "Status Desktop’s next release brings the app up-to-speed with Status Mobile. That means: SWAPS!"
        property int timestamp: Date.now()
        property int previousTimestamp: 0
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

            onLearnMoreClicked: logs.logEvent("ActivityNotificationNewsMessages::onLearnMoreClicked")
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
