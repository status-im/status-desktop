import QtQuick
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Components

import utils
import shared.panels

import AppLayouts.stores

Item {
    id: root

    property int membershipStatus: ActivityCenterStore.ActivityCenterMembershipStatus.None
    property bool ctaAllowed: !acceptedPending && !declinedPending

    readonly property bool pending: membershipStatus === ActivityCenterStore.ActivityCenterMembershipStatus.Pending
    readonly property bool accepted: membershipStatus === ActivityCenterStore.ActivityCenterMembershipStatus.Accepted
    readonly property bool declined: membershipStatus === ActivityCenterStore.ActivityCenterMembershipStatus.Declined
    readonly property bool acceptedPending: membershipStatus === ActivityCenterStore.ActivityCenterMembershipStatus.AcceptedPending
    readonly property bool declinedPending: membershipStatus === ActivityCenterStore.ActivityCenterMembershipStatus.DeclinedPending

    signal acceptRequestToJoinCommunity()
    signal declineRequestToJoinCommunity()

    implicitWidth: Math.max(textItem.width, buttons.width)
    implicitHeight: Math.max(textItem.height, buttons.height)

    StatusBaseText {
        id: textItem
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: Theme.smallPadding
        visible: !pending
        text: {
            if (root.accepted) {
                return qsTr("Accepted")
            } 
            if (root.declined) {
                return qsTr("Declined")
            }
            return ""
        }
        color: {
            if (root.accepted) {
                return Theme.palette.successColor1
            }
            if (root.declined) {
                return Theme.palette.dangerColor1
            }
            return Theme.palette.directColor1
        }
    }

    RowLayout {
        id: buttons
        anchors.centerIn: parent
        visible: pending || acceptedPending || declinedPending
        spacing: Theme.halfPadding
        StatusFlatButton {
            icon.name: "checkmark-circle"
            icon.color: enabled ? Theme.palette.successColor1 : disabledTextColor
            onClicked: root.acceptRequestToJoinCommunity()
            enabled: !root.acceptedPending
            text: root.acceptedPending ? qsTr("Accept pending") : ""
            verticalPadding: 4
            horizontalPadding: 4
            visible: root.ctaAllowed || !enabled
        }

        StatusFlatButton {
            icon.name: "close-circle"
            icon.color: enabled ? Theme.palette.dangerColor1 : disabledTextColor
            onClicked: root.declineRequestToJoinCommunity()
            enabled: !root.declinedPending
            text: root.declinedPending ? qsTr("Reject pending") : ""
            verticalPadding: 4
            horizontalPadding: 4
            visible: root.ctaAllowed || !enabled
        }
    }
}
