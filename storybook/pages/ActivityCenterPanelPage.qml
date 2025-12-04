import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core.Theme

import AppLayouts.ActivityCenter.panels

import Storybook

import utils

import AppLayouts.ActivityCenter.helpers

SplitView {
    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Rectangle {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            color: Theme.palette.baseColor4

            ActivityCenterPanel {
                property int currentActiveGroup: ActivityCenterTypes.ActivityCenterGroup.All

                anchors.centerIn: parent
                width: slider.value

                hasAdmin: admin.checked
                hasMentions: mentions.checked
                hasReplies: replies.checked
                hasContactRequests: contactRequests.checked
                hasMembership: membership.checked
                activeGroup: currentActiveGroup

                onSetActiveGroupRequested: (group) => {
                                               logs.logEvent("ActivityCenterPanel::onSetActiveGroupRequested: " + group)
                                               currentActiveGroup = group
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

        ColumnLayout {
            Label {
                Layout.fillWidth: true
                text: "Panel dynamic width:"
                font.bold: true
            }
            Slider {
                id: slider
                Layout.fillWidth: true
                value: 200
                from: 200
                to: 600
            }

            Label {
                Layout.fillWidth: true
                text: "Type of notifications:"
                font.bold: true
            }

            CheckBox {
                id: admin
                Layout.fillWidth: true
                text: "Has admin notifications?"
            }

            CheckBox {
                id: mentions
                Layout.fillWidth: true
                text: "Has mentions notifications?"
            }

            CheckBox {
                id: replies
                Layout.fillWidth: true
                text: "Has replies notifications?"
            }

            CheckBox {
                id: contactRequests
                Layout.fillWidth: true
                text: "Has contact requests notifications?"
            }

            CheckBox {
                id: membership
                Layout.fillWidth: true
                text: "Has membership notifications?"
            }
        }
    }
}

// category: Panels
// status: good
// https://www.figma.com/design/SGyfSjxs5EbzimHDXTlj8B/Qt-Responsive---v?node-id=1868-52013&m=dev
// https://www.figma.com/design/SGyfSjxs5EbzimHDXTlj8B/Qt-Responsive---v?node-id=1902-48455&m=dev
