import QtQuick 2.14
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import utils 1.0
import shared.panels 1.0

Item {
    id: root

    property bool pending: false
    property bool accepted: false
    property bool declined: false
    property bool acceptedPending: false
    property bool declinedPending: false
    property bool ctaAllowed: true

    signal acceptRequestToJoinCommunity()
    signal declineRequestToJoinCommunity()

    implicitWidth: Math.max(textItem.width, buttons.width)
    implicitHeight: Math.max(textItem.height, buttons.height)

    StatusBaseText {
        id: textItem
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: Style.current.smallPadding
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
        spacing: Style.current.halfPadding
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
