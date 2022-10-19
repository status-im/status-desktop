import QtQuick 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
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

    width: Math.max(textItem.width, buttons.width)
    height: Math.max(textItem.height, buttons.height)

    StatusBaseText {
        id: textItem
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        visible: !pending
        text: {
            if (root.accepted) {
                return qsTr("Accepted")
            } else if (root.declined) {
                return qsTr("Declined")
            }
            return ""
        }
        color: {
            if (root.accepted) {
                return Theme.palette.successColor1
            } else if (root.declined) {
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

        StatusRoundIcon {
            asset.name: "thumbs-up"
            asset.color: Theme.palette.white
            asset.bgWidth: 28
            asset.bgHeight: 28
            asset.bgColor: Theme.palette.successColor1
            MouseArea {
                id: thumbsUpSensor
                hoverEnabled: true
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.acceptRequestToJoinCommunity()
            }
        }

        StatusRoundIcon {
            asset.name: "thumbs-down"
            asset.color: Theme.palette.white
            asset.bgWidth: 28
            asset.bgHeight: 28
            asset.bgColor: Theme.palette.dangerColor1
            MouseArea {
                id: thumbsDownSensor
                hoverEnabled: true
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.declineRequestToJoinCommunity()
            }
        }
    }
}