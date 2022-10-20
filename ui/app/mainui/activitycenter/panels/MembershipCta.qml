import QtQuick 2.14

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

    signal acceptRequestToJoinCommunity()
    signal declineRequestToJoinCommunity()

    implicitWidth: Math.max(textItem.width, buttons.width)
    implicitHeight: Math.max(textItem.height, buttons.height)

    StatusBaseText {
        id: textItem
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
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

    Row {
        id: buttons
        anchors.centerIn: parent
        visible: pending
        spacing: Style.current.padding

        StatusRoundButton {
            icon.name: "thumbs-up"
            icon.color: Style.current.white
            icon.hoverColor: Style.current.white
            implicitWidth: 28
            implicitHeight: 28
            color: Theme.palette.successColor1
            onClicked: root.acceptRequestToJoinCommunity()
        }

        StatusRoundButton {
            icon.name: "thumbs-down"
            icon.color: Style.current.white
            icon.hoverColor: Style.current.white
            implicitWidth: 28
            implicitHeight: 28
            color: Theme.palette.dangerColor1
            onClicked: root.declineRequestToJoinCommunity()
        }
    }
}