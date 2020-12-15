import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import "../../../../shared"
import "../../../../shared/status"
import "../../../../imports"
import "."

Rectangle {
    id: root
    height: visible ? 220 : 0
    anchors.left: parent.left
    anchors.leftMargin: Style.current.padding
    anchors.right: parent.right
    anchors.rightMargin: Style.current.padding
    border.color: Style.current.border
    radius: 16
    color: Style.current.transparent

    Component {
        id: inviteFriendsPopup
        InviteFriendsToCommunityPopup {
            onClosed: {
                destroy()
            }
        }
    }

    SVGImage {
        anchors.top: parent.top
        anchors.topMargin: -6
        anchors.horizontalCenter: parent.horizontalCenter
        source: "../../../img/chatEmptyHeader.svg"
        width: 66
        height: 50
    }

    StatusIconButton {
        icon.name: "close"
        id: closeImg
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 10
        icon.height: 20
        icon.width: 20
        iconColor: Style.current.darkGrey
        onClicked: {
            // TODO make this saved in the settings
            root.visible = false
        }
    }

    StyledText {
        id: welcomeText
        text: qsTr("Welcome to your community!")
        anchors.top: parent.top
        anchors.topMargin: 60
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 15
        wrapMode: Text.WordWrap
        anchors.right: parent.right
        anchors.rightMargin: Style.current.xlPadding
        anchors.left: parent.left
        anchors.leftMargin: Style.current.xlPadding
    }

    StatusButton {
        id: addMembersBtn
        text: qsTr("Add members")
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: manageBtn.top
        anchors.bottomMargin: Style.current.halfPadding
        onClicked: {
            openPopup(inviteFriendsPopup)
        }
    }

    StatusButton {
        id: manageBtn
        text: qsTr("Manage community")
        type: "secondary"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.current.padding
        onClicked: communityProfilePopup.open()
    }
}
