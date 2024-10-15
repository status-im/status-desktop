import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.controls.chat 1.0

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

Rectangle {
    property string contactPubKey
    property string contactName
    property string contactIcon
    signal openProfilePopup()
    signal blockContactActionTriggered()
    signal acceptClicked()
    signal declineClicked()
    property bool isHovered: false
    id: container

    height: visible ? 64 : 0
    anchors.right: parent.right
    anchors.left: parent.left
    border.width: 0
    radius: Theme.radius
    color: isHovered ? Theme.palette.backgroundHover : Theme.palette.transparent

    UserImage {
        id: accountImage

        anchors.left: parent.left
        anchors.leftMargin: Theme.padding
        anchors.verticalCenter: parent.verticalCenter

        name: contactName
        image: contactIcon
        pubkey: contactPubKey
    }

    StyledText {
        id: usernameText
        text: contactName
        elide: Text.ElideRight
        font.pixelSize: 17
        anchors.top: accountImage.top
        anchors.topMargin: Theme.smallPadding
        anchors.left: accountImage.right
        anchors.leftMargin: Theme.padding
        anchors.right: buttons.left
        anchors.rightMargin: Theme.padding
    }

    HoverHandler {
        onHoveredChanged: container.isHovered = hovered
    }

    AcceptRejectOptionsButtonsPanel {
        id: buttons
        anchors.right: parent.right
        anchors.rightMargin: Theme.padding
        anchors.verticalCenter: parent.verticalCenter
        onAcceptClicked: container.acceptClicked()
        onDeclineClicked: container.declineClicked()
        onProfileClicked: container.openProfilePopup()
        onBlockClicked: container.blockContactActionTriggered()
    }
}
