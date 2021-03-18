import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"
import "./"
import "../components"

Item {
    property string headerTitle: ""
    property string headerDescription: ""
    property string headerImageSource: ""
    height: childrenRect.height

    CommunityPopupButton {
        id: inviteBtn
        //% "Invite People"
        label: qsTrId("invite-people")
        width: parent.width
        iconName: "invite"
        onClicked: openPopup(inviteFriendsPopup)
        Component {
            id: inviteFriendsPopup
            InviteFriendsToCommunityPopup {
                onClosed: {
                    destroy()
                }
            }
        }
    }

    Separator {
        id: sep
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: inviteBtn.bottom
        anchors.topMargin: Style.current.smallPadding
        anchors.leftMargin: -Style.current.padding
        anchors.rightMargin: -Style.current.padding
    }


    StatusSettingsLineButton {
        id: membershipRequestsBtn
        text: qsTr("Membership requests")
        badgeText: chatsModel.communities.activeCommunity.communityMembershipRequests.nbRequests.toString()
        visible: chatsModel.communities.activeCommunity.communityMembershipRequests.nbRequests > 0
        badgeSize: 22
        badgeRadius: badgeSize / 2
        isBadge: true
        height: 64
        anchors.top: sep.bottom
        anchors.topMargin: visible ? Style.current.smallPadding : 0
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        onClicked: membershipRequestPopup.open()
    }

    Separator {
        id: sep2
        visible: membershipRequestsBtn.visible
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: membershipRequestsBtn.bottom
        anchors.topMargin: Style.current.smallPadding
        anchors.leftMargin: -Style.current.padding
        anchors.rightMargin: -Style.current.padding
    }

    ListView {
        id: memberList
        anchors.top: sep2.visible ? sep2.bottom : sep.bottom
        anchors.topMargin: Style.current.smallPadding
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottomMargin: Style.current.halfPadding
        spacing: 4
        model: community.members
        delegate: Rectangle {
            id: contactRow
            width: parent.width
            height: 64
            radius: Style.current.radius
            color: isHovered ? Style.current.backgroundHover : Style.current.transparent

            property bool isHovered: false
            property string nickname: appMain.getUserNickname(model.pubKey)

            StatusImageIdenticon {
                id: identicon
                anchors.left: parent.left
                anchors.leftMargin: Style.current.padding
                anchors.verticalCenter: parent.verticalCenter
                source: model.identicon
            }

            StyledText {
                text: !model.userName.endsWith(".eth") && !!contactRow.nickname ?
                            contactRow.nickname : Utils.removeStatusEns(model.userName)
                anchors.left: identicon.right
                anchors.leftMargin: Style.current.smallPadding
                anchors.right: parent.right
                anchors.rightMargin: Style.current.smallPadding
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 15
            }

            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                hoverEnabled: true
                onEntered: contactRow.isHovered = true
                onExited: contactRow.isHovered = false
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: openProfilePopup(model.userName, model.pubKey, model.identicon, '', contactRow.nickname)
            }

            StatusContextMenuButton {
                id: moreActionsBtn
                anchors.right: parent.right
                anchors.rightMargin: Style.current.padding
                anchors.verticalCenter: parent.verticalCenter
                MouseArea {
                    anchors.fill: parent
                    onClicked: contextMenu.popup(-contextMenu.width + moreActionsBtn.width, moreActionsBtn.height + 4)
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onExited: {
                        contactRow.isHovered = false
                        moreActionsBtn.highlighted = false
                    }
                    onEntered: {
                        contactRow.isHovered = true
                        moreActionsBtn.highlighted = true
                    }
                    PopupMenu {
                        id: contextMenu
                        Action {
                            icon.source: "../../../img/communities/menu/view-profile.svg"
                            icon.width: 16
                            icon.height: 16
                            //% "View Profile"
                            text: qsTrId("view-profile")
                            onTriggered: openProfilePopup(model.userName, model.pubKey, model.identicon, '', contactRow.nickname)
                        }
                        /* Action { */
                        /*     icon.source: "../../../img/communities/menu/roles.svg" */
                        /*     icon.width: 16 */
                        /*     icon.height: 16 */
                        /*     //% "Roles" */
                        /*     text: qsTrId("roles") */
                        /*     onTriggered: console.log("TODO") */
                        /* } */
                        Separator {
                            height: 10
                        }
                        Action {
                            property string type: "danger"
                            icon.source: "../../../img/communities/menu/kick.svg"
                            icon.width: 16
                            icon.height: 16
                            icon.color: Style.current.red
                            //% "Kick"
                            text: qsTrId("kick")
                            onTriggered: chatsModel.removeUserFromCommunity(model.pubKey)
                        }
                        /* Action { */
                        /*     icon.source: "../../../img/communities/menu/ban.svg" */
                        /*     icon.width: 16 */
                        /*     icon.height: 16 */
                        /*     icon.color: Style.current.red */
                        /*     //% "Ban" */
                        /*     text: qsTrId("ban") */
                        /*     onTriggered: console.log("TODO") */
                        /* } */
                        /* Separator {} */
                        /* Action { */
                        /*     icon.source: "../../../img/communities/menu/transfer-ownership.svg" */
                        /*     icon.width: 16 */
                        /*     icon.height: 16 */
                        /*     icon.color: Style.current.red */
                        /*     //% "Transfer ownership" */
                        /*     text: qsTrId("transfer-ownership") */
                        /*     onTriggered: console.log("TODO") */
                        /* } */
                    }
                }
            }
        }
    }

}
