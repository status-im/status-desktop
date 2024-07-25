import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Qt.labs.settings 1.0

import mainui.activitycenter.views 1.0
import mainui.activitycenter.stores 1.0

import Storybook 1.0

SplitView {
    id: root

    orientation: Qt.Vertical

    Logs { id: logs }

    QtObject {
        id: notificationMock

        property string id: "1"
        property string communityId: "1"
        property string sectionId: "1"
        property int notificationType: 1
        property int timestamp: Date.now()
        property int previousTimestamp: 0
        property bool read: false
        property bool dismissed: false
        property bool accepted: false
    }

    Item {
        SplitView.fillHeight: true
        SplitView.fillWidth: true

        ActivityNotificationNewDevice {
            id: notification

            anchors.centerIn: parent
            width: parent.width - 50
            height: implicitHeight

            type: ActivityNotificationNewDevice.InstallationType.Received
            accountName: "bob.eth"
            store: undefined
            notification: notificationMock

            onMoreDetailsClicked: logs.logEvent("ActivityNotificationNewDevice::onMoreDetailsClicked")
        }

    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 160

        logsView.logText: logs.logText

        Column {
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
        }
    }
}

// category: Activity Center
// https://www.figma.com/design/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=40765-355811&m=dev
