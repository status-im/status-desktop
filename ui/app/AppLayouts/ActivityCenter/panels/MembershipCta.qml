import QtQuick
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Components

import utils
import shared.panels

import AppLayouts.ActivityCenter.helpers

Item {
    id: root

    property int membershipStatus: ActivityCenterTypes.ActivityCenterMembershipStatus.None
    property bool ctaAllowed: !acceptedPending && !declinedPending

    readonly property bool pending: membershipStatus === ActivityCenterTypes.ActivityCenterMembershipStatus.Pending
    readonly property bool accepted: membershipStatus === ActivityCenterTypes.ActivityCenterMembershipStatus.Accepted
    readonly property bool declined: membershipStatus === ActivityCenterTypes.ActivityCenterMembershipStatus.Declined
    readonly property bool acceptedPending: membershipStatus === ActivityCenterTypes.ActivityCenterMembershipStatus.AcceptedPending
    readonly property bool declinedPending: membershipStatus === ActivityCenterTypes.ActivityCenterMembershipStatus.DeclinedPending

    signal acceptRequestToJoinCommunity()
    signal declineRequestToJoinCommunity()

    implicitWidth: Math.max(textItem.width, buttons.width)
    implicitHeight: Math.max(textItem.height, buttons.height)

    StatusBaseText {
        id: textItem
        anchors.verticalCenter: parent.verticalCenter
        visible: !pending
        font.pixelSize: Theme.additionalTextSize
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
        visible: pending || acceptedPending || declinedPending
        spacing: Theme.halfPadding
        StatusFlatButton {
            icon.name: "checkmark-circle"
            icon.color: enabled ? Theme.palette.successColor1 : disabledTextColor
            onClicked: root.acceptRequestToJoinCommunity()
            enabled: !root.acceptedPending
            text: root.acceptedPending ? qsTr("Accept pending") : ""
            font.pixelSize: Theme.additionalTextSize
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
            font.pixelSize: Theme.additionalTextSize
            verticalPadding: 4
            horizontalPadding: 4
            visible: root.ctaAllowed || !enabled
        }
    }
}
