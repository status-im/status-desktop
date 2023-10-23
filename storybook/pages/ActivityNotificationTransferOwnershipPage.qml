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

        ActivityNotificationTransferOwnership {
            id: notification

            anchors.centerIn: parent
            width: parent.width - 50
            height: implicitHeight

            type: ActivityNotificationTransferOwnership.OwnershipState.Pending
            store: undefined
            notification: notificationMock
            communityName: communityNameText.text
            communityColor: colorSwitch.checked ? "green" : "orange"

            onFinaliseOwnershipClicked: logs.logEvent("ActivityNotificationOwnerTokenReceived::onFinaliseOwnershipClicked")
            onNavigateToCommunityClicked: logs.logEvent("ActivityNotificationOwnerTokenReceived::onNavigateToCommunityClicked")
        }

    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 160

        logsView.logText: logs.logText

        Column {
            Row {
                Label {
                    text: "Community Name: "
                }

                TextInput {
                    id: communityNameText

                    text: "Doodles"
                }
            }

            Switch {
                id: colorSwitch

                text: "Orange OR Green"
                checked: true
            }

            Row {
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
        }
    }
}

// category: Activity Center
// https://www.figma.com/file/qHfFm7C9LwtXpfdbxssCK3/Kuba%E2%8E%9CDesktop---Communities?type=design&node-id=37206%3A86911&mode=design&t=LuuR3YcDBwDkWIBw-1
