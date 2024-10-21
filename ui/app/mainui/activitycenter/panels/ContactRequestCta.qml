import QtQuick 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0
import shared.panels 1.0

Item {
    id: root

    property bool isOutgoingRequest: false
    property bool pending: false
    property bool accepted: false
    property bool dismissed: false
    property bool blocked: false

    signal acceptClicked()
    signal declineClicked()
    signal blockClicked()
    signal profileClicked()
    signal detailsClicked()

    implicitWidth: Math.max(textItem.width, buttons.width)
    implicitHeight: Math.max(textItem.height, buttons.height)

    StatusBaseText {
        id: textItem
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: Theme.smallPadding
        visible: !buttons.visible
        text: {
            if (root.accepted) {
                return qsTr("Accepted")
            } else if (root.pending) {
                return qsTr("Pending")
            } else if (root.dismissed) {
                return blocked ? qsTr("Declined & Blocked") : qsTr("Declined")
            }
            return ""
        }
        color: {
            if (root.accepted) {
                return Theme.palette.successColor1
            } else if (root.pending) {
                return Theme.palette.baseColor1
            } else if (root.dismissed) {
                return Theme.palette.dangerColor1
            }
            return Theme.palette.directColor1
        }
    }

    AcceptRejectOptionsButtonsPanel {
        id: buttons
        visible: pending && !isOutgoingRequest
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        onAcceptClicked: root.acceptClicked()
        onDeclineClicked: root.declineClicked()
        onProfileClicked: root.profileClicked()
        onBlockClicked: root.blockClicked()
        onDetailsClicked: root.detailsClicked()
    }
}
