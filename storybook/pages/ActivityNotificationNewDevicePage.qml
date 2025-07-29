import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import AppLayouts.ActivityCenter.views

import Storybook

SplitView {
    id: root

    orientation: Qt.Vertical

    readonly property int leftPanelMaxWidth: 308 // It fits on mobile / portrait + desktop left panel

    Logs { id: logs }

    QtObject {
        id: notificationMock

        property string id: "1"
        property string communityId: "1"
        property string sectionId: "1"
        property int notificationType: 1
        property int timestamp: Date.now()
        property int previousTimestamp: 0
        property bool read: read.checked
        property bool dismissed: dismissed.checked
        property bool accepted: accepted.checked
    }

    Item {
        SplitView.fillHeight: true
        SplitView.fillWidth: true

        ActivityNotificationNewDevice {
            id: notification

            anchors.centerIn: parent
            width: root.leftPanelMaxWidth
            height: implicitHeight

            type: ActivityNotificationNewDevice.InstallationType.Received
            accountName: accountName.text
            notification: notificationMock

            onMoreDetailsClicked: logs.logEvent("ActivityNotificationNewDevice::onMoreDetailsClicked")
        }

    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 160

        logsView.logText: logs.logText

        ColumnLayout {
            RowLayout {
                Label {
                    Layout.topMargin: 8
                    text: "Account name:"
                    font.weight: Font.Bold
                }

                TextField {
                    id: accountName
                    Layout.fillWidth: true
                    text: "bob.eth"
                }
            }
            Row {
                RadioButton {
                    text: "Received"
                    checked: true
                    onCheckedChanged: if(checked) notification.type = ActivityNotificationNewDevice.InstallationType.Received
                }

                RadioButton {
                    text: "Created"
                    onCheckedChanged: if(checked) notification.type = ActivityNotificationNewDevice.InstallationType.Created
                }
            }
            RowLayout {

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
}

// category: Activity Center
// https://www.figma.com/design/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=40765-355811&m=dev
