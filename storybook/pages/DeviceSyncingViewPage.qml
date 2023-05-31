import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import StatusQ.Core 0.1

import Storybook 1.0
import Models 1.0
import utils 1.0

import shared.views 1.0

SplitView {
    id: root

    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        DeviceSyncingView {
            devicesModel: ListModel {
                ListElement {
                    name: "Device 1"
                    deviceType: "osx"
                    timestamp: 0
                    isCurrentDevice: false
                }
                ListElement {
                    name: "Device 2"
                    deviceType: "windows"
                    timestamp: 0
                    isCurrentDevice: false
                }
                ListElement {
                    name: "Device 3"
                    deviceType: "android"
                    timestamp: 0
                    isCurrentDevice: false
                }
                ListElement {
                    name: "Device 4"
                    deviceType: "ios"
                    timestamp: 0
                    isCurrentDevice: false
                }
                ListElement {
                    name: "Device 5"
                    deviceType: "desktop"
                    timestamp: 0
                    isCurrentDevice: false
                }
            }
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
