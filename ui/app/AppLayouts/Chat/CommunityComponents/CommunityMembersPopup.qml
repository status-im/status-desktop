import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"
import "./"
import "../components"

ModalPopup {
    id: popup
    property QtObject community: chatsModel.communities.activeCommunity 

    header: Item {
        height: childrenRect.height
        width: parent.width
    
        StyledText {
            id: groupName
            //% "Members"
            text: qsTrId("members-title")
            anchors.top: parent.top
            anchors.topMargin: 2
            anchors.left: parent.left
            font.bold: true
            font.pixelSize: 14
            wrapMode: Text.WordWrap
        }

        StyledText {
            id: nbMembersText
            text: community.nbMembers.toString()
            width: 160
            anchors.left: parent.left
            anchors.top: groupName.bottom
            anchors.topMargin: 2
            font.pixelSize: 14
            color: Style.current.secondaryText
        }

        Separator {
            anchors.top: nbMembersText.bottom
            anchors.topMargin: Style.current.padding
            anchors.left: parent.left
            anchors.leftMargin: -Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: -Style.current.padding
        }
    }

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

    MembershipRequestsButton {
        id: membershipRequestsBtn
        anchors.top: sep.bottom
        anchors.topMargin: visible ? Style.current.smallPadding : 0
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: -Style.current.padding
        anchors.rightMargin: -Style.current.padding
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
        Layout.fillWidth: true
        Layout.fillHeight: true
        model: community.members
        delegate: Item {
            id: contactRow
            width: parent.width
            height: identicon.height

            property string nickname: appMain.getUserNickname(model.pubKey)

            StatusImageIdenticon {
                id: identicon
                anchors.left: parent.left
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
                font.pixelSize: 13
            }

            StyledText {
                id: moreActionsBtn
                text: "..."
                font.letterSpacing: 0.5
                font.bold: true
                lineHeight: 1.4
                font.pixelSize: 25
                anchors.right: parent.right
                anchors.rightMargin: Style.current.smallPadding
                anchors.verticalCenter: parent.verticalCenter
                MouseArea {
                    anchors.fill: parent
                    onClicked: contextMenu.popup(-contextMenu.width / 2 + moreActionsBtn.width / 2, moreActionsBtn.height)
                    cursorShape: Qt.PointingHandCursor
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
                        Action {
                            icon.source: "../../../img/communities/menu/roles.svg"
                            icon.width: 16
                            icon.height: 16
                            //% "Roles"
                            text: qsTrId("roles")
                            onTriggered: console.log("TODO")
                        }
                        Separator {}
                        Action {
                            icon.source: "../../../img/communities/menu/kick.svg"
                            icon.width: 16
                            icon.height: 16
                            icon.color: Style.current.red
                            //% "Kick"
                            text: qsTrId("kick")
                            onTriggered: chatsModel.removeUserFromCommunity(model.pubKey)
                        }
                        Action {
                            icon.source: "../../../img/communities/menu/ban.svg"
                            icon.width: 16
                            icon.height: 16
                            icon.color: Style.current.red
                            //% "Ban"
                            text: qsTrId("ban")
                            onTriggered: console.log("TODO")
                        }
                        Separator {}
                        Action {
                            icon.source: "../../../img/communities/menu/transfer-ownership.svg"
                            icon.width: 16
                            icon.height: 16
                            icon.color: Style.current.red
                            //% "Transfer ownership"
                            text: qsTrId("transfer-ownership")
                            onTriggered: console.log("TODO")
                        }
                    }
                }
            }
        }
    }

}
