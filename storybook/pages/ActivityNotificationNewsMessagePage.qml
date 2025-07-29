import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Controls
import StatusQ.Core.Theme

import AppLayouts.ActivityCenter.views

import Storybook

SplitView {
    id: root

    readonly property int leftPanelMaxWidth: 308 // It fits on mobile / portrait + desktop left panel

    QtObject {
        id: notificationMock

        property string id: "1"
        property string newsTitle: title.text
        property string newsDescription: desc.text
        property double timestamp: timestamp.text
        property double previousTimestamp: 0
        property bool read: read.checked
        property bool dismissed: dismissed.checked
        property bool accepted: accepted.checked
    }


    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Logs { id: logs }


        Rectangle {
            SplitView.fillHeight: true
            SplitView.fillWidth: true

            ActivityNotificationNewsMessage {
                id: notification

                anchors.centerIn: parent
                width: root.leftPanelMaxWidth
                height: implicitHeight
                backgroundColor: Theme.palette.primaryColor3

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

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        ColumnLayout {
            spacing: 8
            width: parent.width

            Label {
                Layout.fillWidth: true
                Layout.topMargin: 8
                text: "Title:"
                font.weight: Font.Bold
            }

            TextField {
                id: title
                Layout.fillWidth: true
                text: "Swaps around the corner!"
            }

            Label {
                Layout.topMargin: 8
                Layout.fillWidth: true
                text: "Description:"
                font.weight: Font.Bold
            }

            TextField {
                id: desc
                Layout.fillWidth: true
                text: "Status Desktop’s next release brings the app up-to-speed with Status Mobile. That means: SWAPS!"
            }

            Label {
                Layout.topMargin: 8
                Layout.fillWidth: true
                text: "Timestamp:"
                font.weight: Font.Bold
            }

            TextField {
                id: timestamp
                Layout.fillWidth: true
                text: Date.now()
            }

            Label {
                Layout.topMargin: 8
                Layout.fillWidth: true
                text: "Notification Status:"
                font.weight: Font.Bold
            }

            ButtonGroup { id: read_dismissed_accepted }

            RadioButton {
                id: read
                Layout.fillWidth: true
                text: "Read"
            }

            RadioButton {
                id: dismissed
                Layout.fillWidth: true
                text: "Dismissed"
                checked: true
            }

            RadioButton {
                id: accepted
                Layout.fillWidth: true
                text: "Accepted"
            }
        }
    }
}

// category: Activity Center
// https://www.figma.com/design/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=39555-95032&m=dev
