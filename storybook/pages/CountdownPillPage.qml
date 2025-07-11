import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Core.Theme

import shared.controls

import Storybook

SplitView {
    orientation: Qt.Horizontal

    Logs { id: logs }

    Pane {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        background: Rectangle {
            color: Theme.palette.baseColor4
        }

        CountdownPill {
            id: pill
            anchors.centerIn: parent
            timestamp: new Date()
            expirationSeconds: 300 // 5 minutes
        }
    }

    LogsAndControlsPanel {
        SplitView.fillHeight: true
        SplitView.preferredWidth: 300

        logsView.logText: logs.logText

        ColumnLayout {
            anchors.fill: parent

            Button {
                text: "Set 2 days, 2 hours, 10 minutes"
                onClicked: {
                    pill.timestamp = new Date()
                    pill.expirationSeconds = 180600
                }
            }
            Button {
                text: "Set 1.5 hrs"
                onClicked: {
                    pill.timestamp = new Date()
                    pill.expirationSeconds = 5400
                }
            }
            Button {
                text: "Set 3 mins"
                onClicked: {
                    pill.timestamp = new Date()
                    pill.expirationSeconds = 180
                }
            }
            Button {
                text: "Set 1 min"
                onClicked: {
                    pill.timestamp = new Date()
                    pill.expirationSeconds = 60
                }
            }
            Button {
                text: "Set 6 secs"
                onClicked: {
                    pill.timestamp = new Date()
                    pill.expirationSeconds = 6
                }
            }
            Button {
                text: "Set expired now"
                onClicked: {
                    pill.expirationSeconds = 0
                }
            }
            Button {
                text: "Set 5 minutes (10 minutes ago) -> expired"
                onClicked: {
                    const tenMinsAgo = new Date()
                    tenMinsAgo.setMinutes(tenMinsAgo.getMinutes() - 10)
                    pill.timestamp = tenMinsAgo
                    pill.expirationSeconds = 5*60
                }
            }
            Label {
                text: "Remaining secs: %1".arg(pill.remainingSeconds)
            }
            Label {
                text: "Expired: %1".arg(pill.isExpired ? "true" : "false")
            }

            Item { Layout.fillHeight: true }
        }
    }
}

// category: Controls

// https://www.figma.com/design/HrmZp1y4S77QJezRFRl6ku/dApp-Interactions---Milestone-1?node-id=3967-288229&node-type=frame&t=lHLlTZ0aJE0Uo3l9-0
