import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core.Theme

import AppLayouts.ActivityCenter.helpers
import AppLayouts.ActivityCenter.panels

import Storybook

import utils

SplitView {
    Logs { id: logs }

    ListModel {
        id: notificationsMock

        ListElement {
            idValue: "notificationID-111"
            notificationType: 0
            communityId: "communityID-222"
            previousTimestamp: 0

            read: false
            selected: false
            avatarSource: "https://i.pravatar.cc/128?img=5"
            badgeIconName: "action-mention"
            isCircularAvatar: true
            title: "Notification 2"
            chatKey: "zQ3saskd11lfkjs1dkf5Rj9"
            isContact: true
            trustIndicator: 0
            primaryText: "Some notification description 2"
        }

        ListElement {
            idValue: "notificationID-222"
            notificationType: 1
            communityId: "communityID-333"
            previousTimestamp: 0

            read: true
            selected: true
            avatarSource: "https://i.pravatar.cc/128?img=5"
            badgeIconName: "action-mention"
            isCircularAvatar: false
            title: "Notification 2"
            chatKey: "zQ3saskd11lfkjs1dkf5Rj9"
            isContact: true
            trustIndicator: 1
            primaryText: "Some notification description 2"
        }

        ListElement {
            idValue: "notificationID-333"
            notificationType: 0
            communityId: "communityID-444"
            previousTimestamp: 0

            read: false
            selected: false
            avatarSource: "https://i.pravatar.cc/128?img=5"
            badgeIconName: "action-mention"
            isCircularAvatar: true
            title: "Notification 3"
            chatKey: "zQ3saskd11lfkjs1dkf5Rj9"
            isContact: true
            trustIndicator: 2
            primaryText: "Some notification description 2"
        }

        ListElement {
            idValue: "notificationID-111"
            notificationType: 0
            communityId: "communityID-222"
            previousTimestamp: 0

            read: false
            selected: false
            avatarSource: "https://i.pravatar.cc/128?img=5"
            badgeIconName: "action-reply"
            isCircularAvatar: false
            title: "Notification 4"
            chatKey: "zQ3saskd11lfkjs1dkf5Rj9"
            isContact: false
            trustIndicator: 0
            primaryText: "Some notification description 2"
        }

        ListElement {
            idValue: "notificationID-222"
            notificationType: 1
            communityId: "communityID-333"
            previousTimestamp: 0


            read: true
            selected: false
            avatarSource: "https://i.pravatar.cc/128?img=5"
            badgeIconName: "action-mention"
            isCircularAvatar: true
            title: "Notification 5"
            chatKey: "zQ3saskd11lfkjs1dkf5Rj9"
            isContact: true
            trustIndicator: 0
            primaryText: "Some notification description 2"
        }

        ListElement {
            idValue: "notificationID-333"
            notificationType: 0
            communityId: "communityID-444"
            previousTimestamp: 0

            read: false
            selected: false
            avatarSource: "https://i.pravatar.cc/128?img=5"
            badgeIconName: "action-reply"
            isCircularAvatar: true
            title: "Notification 6"
            chatKey: "zQ3saskd11lfkjs1dkf5Rj9"
            isContact: false
            trustIndicator: 1
            primaryText: "Some notification description 2"
        }
    }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Rectangle {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            color: Theme.palette.baseColor4

            ActivityCenterPanel {
                Tracer{}
                property int currentActiveGroup: ActivityCenterTypes.ActivityCenterGroup.All

                anchors.centerIn: parent
                width: slider.value
                height: sliderHeight.value

                hasAdmin: admin.checked
                hasMentions: mentions.checked
                hasReplies: replies.checked
                hasContactRequests: contactRequests.checked
                hasMembership: membership.checked
                activeGroup: currentActiveGroup

                notificationsModel: notificationsMock

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
                value: 300
                from: 200
                to: 600
            }

            Label {
                Layout.fillWidth: true
                text: "Panel dynamic height:"
                font.bold: true
            }
            Slider {
                id: sliderHeight
                Layout.fillWidth: true
                value: 400
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
