import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import shared 1.0

Item {
    id: root

    property bool hasAdmin: false
    property bool hasMentions: false
    property bool hasReplies: false
    property bool hasContactRequests: false
    property bool hasIdentityRequests: false
    property bool hasMembership: false

    property bool hideReadNotifications: false
    property int unreadNotificationsCount: 0

    property int activeGroup: Constants.ActivityCenterGroup.All

    property alias errorText: errorText.text

    signal groupTriggered(int group)
    signal markAllReadClicked()
    signal showHideReadNotifications(bool hideReadNotifications)

    height: 64

    RowLayout {
        id: row
        anchors.fill: parent
        anchors.leftMargin: Style.current.padding
        anchors.rightMargin: Style.current.padding
        spacing: Style.current.padding

        StatusRollArea {
            Layout.fillWidth: true

            content: RowLayout {
                spacing: 0

                Repeater {
                    // NOTE: some entries are hidden until implimentation
                    model: [ { text: qsTr("All"), group: Constants.ActivityCenterGroup.All, visible: true, enabled: true },
                             { text: qsTr("Admin"), group: Constants.ActivityCenterGroup.Admin, visible: root.hasAdmin, enabled: root.hasAdmin },
                             { text: qsTr("Mentions"), group: Constants.ActivityCenterGroup.Mentions, visible: true, enabled: root.hasMentions },
                             { text: qsTr("Replies"), group: Constants.ActivityCenterGroup.Replies, visible: true, enabled: root.hasReplies },
                             { text: qsTr("Contact requests"), group: Constants.ActivityCenterGroup.ContactRequests, visible: true, enabled: root.hasContactRequests },
                             { text: qsTr("Identity verification"), group: Constants.ActivityCenterGroup.IdentityVerification, visible: true, enabled: root.hasIdentityRequests },
                             { text: qsTr("Transactions"), group: Constants.ActivityCenterGroup.Transactions, visible: false, enabled: true },
                             { text: qsTr("Membership"), group: Constants.ActivityCenterGroup.Membership, visible: true, enabled: root.hasMembership },
                             { text: qsTr("System"), group: Constants.ActivityCenterGroup.System, visible: false, enabled: true } ]

                    StatusFlatButton {
                        enabled: modelData.enabled
                        visible: modelData.visible
                        text: modelData.text
                        size: StatusBaseButton.Size.Small
                        highlighted: modelData.group === root.activeGroup
                        onClicked: root.groupTriggered(modelData.group)
                        onEnabledChanged: if (!enabled && highlighted) root.groupTriggered(Constants.ActivityCenterGroup.All)
                        Layout.preferredWidth: visible ? implicitWidth : 0
                    }
                }
            }
        }

        StatusFlatRoundButton {
            id: markAllReadBtn
            enabled: root.unreadNotificationsCount > 0
            icon.name: "double-checkmark"
            onClicked: root.markAllReadClicked()

            StatusToolTip {
                visible: markAllReadBtn.hovered
                text: qsTr("Mark all as Read")
            }
        }

        StatusFlatRoundButton {
            id: hideReadNotificationsBtn
            icon.name: root.hideReadNotifications ? "hide" : "show"
            onClicked: root.showHideReadNotifications(!root.hideReadNotifications)

            StatusToolTip {
                visible: hideReadNotificationsBtn.hovered
                offset: width / 4
                text: root.hideReadNotifications ? qsTr("Show read notifications") : qsTr("Hide read notifications")
            }
        }
    }

    StatusBaseText {
        id: errorText
        visible: !!text
        anchors.top: parent.top
        anchors.topMargin: Style.current.smallPadding
        color: Theme.palette.dangerColor1
    }
}
