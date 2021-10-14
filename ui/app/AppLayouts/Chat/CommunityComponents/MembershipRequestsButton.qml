import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../../../../shared"
import "../../../../shared/panels"

import utils 1.0
import "../components"
import "./"

Rectangle {
    property int nbRequests: chatsModel.communities.activeCommunity.communityMembershipRequests.nbRequests

    id: membershipRequestsBtn
    visible: nbRequests > 0
    width: parent.width
    height: visible ? 52 : 0
    color: Style.current.secondaryBackground

    StyledText {
        //% "Membership requests"
        text: qsTrId("membership-requests")
        font.pixelSize: 15
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        anchors.verticalCenter: parent.verticalCenter
    }

    Rectangle {
        id: badge
        anchors.right: caret.left
        anchors.rightMargin: Style.current.padding
        anchors.verticalCenter: parent.verticalCenter
        color: Style.current.blue
        width: 22
        height: 22
        radius: width / 2
        Text {
            font.pixelSize: 12
            color: Style.current.white
            anchors.centerIn: parent
            text: membershipRequestsBtn.nbRequests.toString()
        }
    }

    SVGImage {
        id: caret
        source: Style.svg("caret")
        fillMode: Image.PreserveAspectFit
        rotation: -90
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        anchors.verticalCenter: parent.verticalCenter
        width: 13
        height: 7

        ColorOverlay {
            anchors.fill: parent
            source: parent
            color: Style.current.darkGrey
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: membershipRequestPopup.open()
    }
}
