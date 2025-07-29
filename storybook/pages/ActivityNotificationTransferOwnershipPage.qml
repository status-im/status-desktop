import QtQuick

import QtQuick.Controls
import QtQuick.Layouts

import AppLayouts.ActivityCenter.views

import Storybook

SplitView {
    id: root

    readonly property int leftPanelMaxWidth: 308 // It fits on mobile / portrait + desktop left panel

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true


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

            ActivityNotificationTransferOwnership {
                id: notification

                anchors.centerIn: parent
                width: root.leftPanelMaxWidth
                height: implicitHeight

                type: ActivityNotificationTransferOwnership.OwnershipState.Pending
                notification: notificationMock
                communityName: communityNameText.text
                communityColor: colorSwitch.checked ? "green" : "orange"
                showFullTimestamp: showFullTimestamp.checked

                onFinaliseOwnershipClicked: logs.logEvent("ActivityNotificationOwnerTokenReceived::onFinaliseOwnershipClicked")
                onNavigateToCommunityClicked: logs.logEvent("ActivityNotificationOwnerTokenReceived::onNavigateToCommunityClicked")
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
                text: "Community Name: "
                font.weight: Font.Bold
            }

            TextField {
                id: communityNameText
                Layout.fillWidth: true
                text: "Doodles"
            }

            Switch {
                id: colorSwitch
                Layout.fillWidth: true
                text: "Orange OR Green"
                checked: true
            }

            ColumnLayout {
                RadioButton {
                    text: "Pending"
                    checked: true
                    onCheckedChanged: if(checked) notification.type = ActivityNotificationTransferOwnership.OwnershipState.Pending
                }

                RadioButton {
                    text: "Declined"
                    onCheckedChanged: if(checked) notification.type = ActivityNotificationTransferOwnership.OwnershipState.Declined
                }

                RadioButton {
                    text: "Succeded"
                    onCheckedChanged: if(checked) notification.type = ActivityNotificationTransferOwnership.OwnershipState.Succeeded
                }

                RadioButton {
                    text: "Failed"
                    onCheckedChanged: if(checked) notification.type = ActivityNotificationTransferOwnership.OwnershipState.Failed
                }

                RadioButton {
                    text: "No longer control node"
                    onCheckedChanged: if(checked) notification.type = ActivityNotificationTransferOwnership.OwnershipState.NoLongerControlNode
                }
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

            Label {
                Layout.topMargin: 8
                Layout.fillWidth: true
                text: "Show full timestamp"
                font.weight: Font.Bold
            }

            Switch {
                id: showFullTimestamp
                checked: false
            }
        }
    }
}

// category: Activity Center
// https://www.figma.com/file/qHfFm7C9LwtXpfdbxssCK3/Kuba%E2%8E%9CDesktop---Communities?type=design&node-id=37206%3A86911&mode=design&t=LuuR3YcDBwDkWIBw-1
