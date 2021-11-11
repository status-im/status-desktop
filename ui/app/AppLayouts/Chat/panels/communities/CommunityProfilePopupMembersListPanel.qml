import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import utils 1.0
import shared 1.0

import "../../popups"
import "../../popups/community"

Item {
    id: root
    implicitHeight: childrenRect.height
    implicitWidth: 480

    property string headerTitle: ""
    property string headerSubtitle: ""
    property string headerImageSource: ""
    property alias members: memberList.model
    property var community
    property var store

    signal inviteButtonClicked()

    Column {

        id: memberSearchAndInviteButton

        StatusInput {
            id: memberSearch
            input.placeholderText: qsTr("Member name")
        }

        StatusListItem {
            id: inviteButton
            anchors.horizontalCenter: parent.horizontalCenter
            visible: !!(root.community.admin || root.community.isAdmin)
            //% "Invite People"
            title: qsTrId("invite-people")
            icon.name: "share-ios"
            type: StatusListItem.Type.Secondary
            sensor.onClicked: root.inviteButtonClicked()
        }

        StatusModalDivider {
            visible: inviteButton.visible && memberRequestsButton.visible
            topPadding: 8
            bottomPadding: 8
        }

        StatusContactRequestsIndicatorListItem {

            id: memberRequestsButton

            property int nbRequests: root.community.communityMembershipRequests.nbRequests
            width: parent.width - 32
            visible: (root.community.isAdmin || root.community.admin) && nbRequests > 0
            anchors.horizontalCenter: parent.horizontalCenter

            //% "Membership requests"
            title: qsTrId("membership-requests")
            requestsCount: nbRequests
            sensor.onClicked: openPopup(membershipRequestPopup)
        }

        StatusModalDivider {
            topPadding: !memberRequestsButton.visible && !inviteButton.visible ? 0 : 8
            bottomPadding: 8
        }
    }

    ScrollView {
        id: scrollView
        width: parent.width
        height: 300
        anchors.top: memberSearchAndInviteButton.bottom

        contentHeight: Math.max(300, memberListColumn.height)
        bottomPadding: 8
        clip: true

        Item {
            width: parent.width
            height: 300
            visible: memberList.count === 0

            StatusBaseText {
                anchors.centerIn: parent
                //% "Community members will appear here"
                text: qsTrId("community-members-will-appear-here")
                font.pixelSize: 15
                color: Theme.palette.baseColor1
            }
        }

        Item {
            width: parent.width
            height: 300
            visible: !!memberSearch.input.text && !!memberList.count && !memberListColumn.height

            StatusBaseText {
                anchors.centerIn: parent
                //% "No contacts found"
                text: qsTrId("no-contacts-found")
                font.pixelSize: 15
                color: Theme.palette.baseColor1
            }
        }

        Column {
            id: memberListColumn
            width: parent.width
            visible: memberList.count > 0 || height > 0
            anchors.horizontalCenter: parent.horizontalCenter

            Repeater {
                id: memberList
                model: root.community.members
                delegate: StatusListItem {

                    id: memberItem

                    property string nickname: appMain.getUserNickname(model.pubKey)
                    property string profileImage: appMain.getProfileImage(model.pubKey) || ""

                    visible: !!!memberSearch.input.text || 
                        model.userName.toLowerCase().includes(memberSearch.input.text.toLowerCase()) ||
                        nickname.toLowerCase().includes(memberSearch.input.text.toLowerCase())
                    anchors.horizontalCenter: parent.horizontalCenter

                    image.isIdenticon: !profileImage
                    image.source: profileImage || model.identicon

                    title: {
                        if (menuButton.visible) {
                            return !model.userName.endsWith(".eth") && !!nickname ?
                                nickname : Utils.removeStatusEns(model.userName)
                        }
                        //% "You"
                        return qsTrId("You")
                    }

                    components: [
                        StatusFlatRoundButton {
                            id: menuButton
                            width: 32
                            height: 32
                            visible: model.pubKey.toLowerCase() !== profileModel.profile.pubKey.toLowerCase()
                            icon.name: "more"
                            type: StatusFlatRoundButton.Type.Secondary
                            onClicked: {
                                highlighted = true
                                communityMemberContextMenu.popup(-communityMemberContextMenu.width+menuButton.width, menuButton.height + 4)
                            }

                            StatusPopupMenu {

                                id: communityMemberContextMenu

                                onClosed: {
                                    menuButton.highlighted = false
                                }

                                StatusMenuItem {
                                    //% "View Profile"
                                    text: qsTrId("view-profile")
                                    icon.name: "channel"
                                    onTriggered: openPopup(profilePopup, {
                                       noFooter: profileModel.profile.pubKey !== model.pubKey,
                                       userName: model.userName,
                                       fromAuthor: model.pubKey, 
                                       identicon: memberItem.image.source,
                                       text: '', 
                                       nickname: memberItem.nickname
                                    })
                                }

                                StatusMenuSeparator {
                                    visible: root.community.admin
                                }

                                StatusMenuItem {
                                    //% "Kick"
                                    text: qsTrId("kick")
                                    icon.name: "arrow-right"
                                    iconRotation: 180
                                    type: StatusMenuItem.Type.Danger
                                    enabled: root.community.admin
                                    onTriggered: chatsModel.communities.removeUserFromCommunity(model.pubKey)
                                }

                                StatusMenuItem {
                                    //% "Ban"
                                    text: qsTrId("ban")
                                    icon.name: "cancel"
                                    type: StatusMenuItem.Type.Danger
                                    enabled: root.community.admin
                                    onTriggered: chatsModel.communities.banUserFromCommunity(model.pubKey, root.community.id)
                                }
                            }
                        }
                    ]
                }
            }
        }
    }

    Component {
        id: membershipRequestPopup
        MembershipRequestsPopup {
            anchors.centerIn: parent
            onClosed: {
                destroy()
            }
        }
    }

    Component {
        id: profilePopup
        ProfilePopup {
            store: root.store
            onClosed: {
                destroy()
            }
        }
    }
}
