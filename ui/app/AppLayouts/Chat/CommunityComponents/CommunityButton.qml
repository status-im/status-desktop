import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../../../shared"
import "../../../../shared/status/core"
import "../../../../shared/status/buttons"
import "../../../../shared/status"
import "../../../../imports"
import "../components"

StatusIconTabButton {
    property string communityId: ""
    property int unviewedMessagesCount: 0
    property string image
    property bool hasMentions: false

    id: communityButton
    anchors.horizontalCenter: parent.horizontalCenter
    icon.source: communityButton.image
    anchors.topMargin: 0

    checked: chatsModel.communities.activeCommunity.active && chatsModel.communities.activeCommunity.id === communityId

    StatusToolTip {
        visible: communityButton.hovered
        text: communityButton.name
        delay: 50
        orientation: "right"
        x: communityButton.width + Style.current.padding
        y: communityButton.height / 2 - height / 2 + 4
    }

    StatusBadge {
        id: chatBadge
        anchors.top: parent.top
        anchors.left: parent.right
        anchors.leftMargin: -17
        anchors.topMargin: 1
        border.color: communityButton.hovered ? Style.current.secondaryBackground : Style.current.mainMenuBackground
        border.width: 2
        visible: unviewedMessagesCount > 0
        value: unviewedMessagesCount
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: function (mouse) {
            if (mouse.button === Qt.RightButton) {
                commnunityMenu.communityId = communityButton.communityId
                commnunityMenu.popup()
                return
            }
            communityButton.clicked()
        }
    }
}
