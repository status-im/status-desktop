import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import utils

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components
import StatusQ.Controls
import StatusQ.Popups

import "../stores"

Item {
    id: root

    property bool hasAdmin: false
    property bool hasMentions: false
    property bool hasReplies: false
    property bool hasContactRequests: false
    property bool hasMembership: false

    property bool hideReadNotifications: false
    property int unreadNotificationsCount: 0

    property int activeGroup: ActivityCenterStore.ActivityCenterGroup.All

    property alias errorText: errorText.text

    signal groupTriggered(int group)
    signal markAllReadClicked()
    signal showHideReadNotifications(bool hideReadNotifications)

    height: 64

    RowLayout {
        id: row
        anchors.fill: parent
        anchors.leftMargin: Theme.padding
        anchors.rightMargin: Theme.padding
        spacing: Theme.padding

        StatusRollArea {
            Layout.fillWidth: true

            content: RowLayout {
                spacing: 0

                Repeater {
                    // NOTE: some entries are hidden until implimentation
                    model: [ { text: qsTr("All"), group: ActivityCenterStore.ActivityCenterGroup.All, visible: true, enabled: true },
                             { text: qsTr("News"), group: ActivityCenterStore.ActivityCenterGroup.NewsMessage, visible: true, enabled: true },
                             { text: qsTr("Admin"), group: ActivityCenterStore.ActivityCenterGroup.Admin, visible: root.hasAdmin, enabled: root.hasAdmin },
                             { text: qsTr("Mentions"), group: ActivityCenterStore.ActivityCenterGroup.Mentions, visible: true, enabled: root.hasMentions },
                             { text: qsTr("Replies"), group: ActivityCenterStore.ActivityCenterGroup.Replies, visible: true, enabled: root.hasReplies },
                             { text: qsTr("Contact requests"), group: ActivityCenterStore.ActivityCenterGroup.ContactRequests, visible: true, enabled: root.hasContactRequests },
                             { text: qsTr("Transactions"), group: ActivityCenterStore.ActivityCenterGroup.Transactions, visible: false, enabled: true },
                             { text: qsTr("Membership"), group: ActivityCenterStore.ActivityCenterGroup.Membership, visible: true, enabled: root.hasMembership },
                             { text: qsTr("System"), group: ActivityCenterStore.ActivityCenterGroup.System, visible: false, enabled: true } ]

                    StatusFlatButton {
                        objectName: "activityCenterGroupButton"
                        enabled: modelData.enabled
                        visible: modelData.visible
                        text: modelData.text
                        size: StatusBaseButton.Size.Small
                        highlighted: modelData.group === root.activeGroup
                        onClicked: root.groupTriggered(modelData.group)
                        onEnabledChanged: if (!enabled && highlighted) root.groupTriggered(ActivityCenterStore.ActivityCenterGroup.All)
                        Layout.preferredWidth: visible ? implicitWidth : 0
                    }
                }
            }
        }
    }

    StatusBaseText {
        id: errorText
        visible: !!text
        anchors.top: parent.top
        anchors.topMargin: Theme.smallPadding
        color: Theme.palette.dangerColor1
    }
}
