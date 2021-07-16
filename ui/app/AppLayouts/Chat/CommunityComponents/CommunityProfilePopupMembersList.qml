import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import "../../../../imports"
import "../../../../shared"

Item {
    id: root
    height: childrenRect.height
    implicitWidth: 480

    property string headerTitle: ""
    property string headerSubtitle: ""
    property string headerImageSource: ""
    property alias members: memberList.model

    signal inviteButtonClicked()

    Column {

        id: memberSearchAndInviteButton

        Item {
            width: parent.width
            height: 76

            Input {
                id: memberSearch
                width: parent.width - 32
                anchors.centerIn: parent
                placeholderText: qsTr("Member name")
            }
        }

        StatusListItem {
            id: inviteButton
            anchors.horizontalCenter: parent.horizontalCenter
            visible: isAdmin
            title: qsTr("Invite People")
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

            property int nbRequests: chatsModel.communities.activeCommunity.communityMembershipRequests.nbRequests
            width: parent.width - 32
            visible: isAdmin && nbRequests > 0
            anchors.horizontalCenter: parent.horizontalCenter

            title: qsTr("Membership requests")
            requestsCount: nbRequests
            sensor.onClicked: membershipRequestPopup.open()
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
                text: qsTr("Community members will appear here")
                font.pixelSize: 15
                color: Theme.palette.baseColor1
            }
        }

        Item {
            width: parent.width
            height: 300
            visible: !!memberSearch.text && !!memberList.count && !memberListColumn.height

            StatusBaseText {
                anchors.centerIn: parent
                text: qsTr("No contacts found")
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
                delegate: StatusListItem {

                    id: memberItem

                    property string nickname: appMain.getUserNickname(model.pubKey)
                    property string profileImage: appMain.getProfileImage(model.pubKey)

                    visible: !!!memberSearch.text || 
                        model.userName.toLowerCase().includes(memberSearch.text.toLowerCase()) ||
                        nickname.toLowerCase().includes(memberSearch.text.toLowerCase())
                    anchors.horizontalCenter: parent.horizontalCenter

                    image.isIdenticon: !profileImage
                    image.source: profileImage || model.identicon

                    title: {
                        if (menuButton.visible) {
                            return !model.userName.endsWith(".eth") && !!nickname ?
                                nickname : Utils.removeStatusEns(model.userName)
                        }
                        return qsTr("You")
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
                                    text: qsTr("View Profile")
                                    icon.name: "channel"
                                    onTriggered: openProfilePopup(model.userName, model.pubKey, memberItem.image.source, '', memberItem.nickname)
                                }

                                StatusMenuSeparator {
                                    visible: chatsModel.communities.activeCommunity.admin
                                }

                                StatusMenuItem {
                                    text: qsTr("Kick")
                                    icon.name: "arrow-right"
                                    iconRotation: 180
                                    type: StatusMenuItem.Type.Danger
                                    enabled: chatsModel.communities.activeCommunity.admin
                                    onTriggered: chatsModel.communities.removeUserFromCommunity(model.pubKey)
                                }

                                StatusMenuItem {
                                    text: qsTr("Ban")
                                    icon.name: "cancel"
                                    type: StatusMenuItem.Type.Danger
                                    enabled: chatsModel.communities.activeCommunity.admin
                                    onTriggered: chatsModel.communities.banUserFromCommunity(model.pubKey, chatsModel.communities.activeCommunity.id)
                                }
                            }
                        }
                    ]
                }
            }
        }
    }
}
