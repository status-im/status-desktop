import QtQuick 2.12
import QtQuick.Controls 2.12

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import "../../../../imports"

StatusModal {
    property string communityId: chatsModel.communities.activeCommunity.id
    property string name: chatsModel.communities.activeCommunity.name
    property string description: chatsModel.communities.activeCommunity.description
    property int access: chatsModel.communities.activeCommunity.access
    property string source: chatsModel.communities.activeCommunity.source
    property string communityColor: chatsModel.communities.activeCommunity.communityColor
    property int nbMembers: chatsModel.communities.activeCommunity.nbMembers
    property bool isAdmin: chatsModel.communities.activeCommunity.isAdmin
    id: popup

    onClosed: {
        while (contentComponent.depth > 1) {
            contentComponent.pop()
        }
    }

    header.title: contentComponent.currentItem.headerTitle
    header.subTitle: contentComponent.currentItem.headerSubtitle || ""
    header.image.source: contentComponent.currentItem.headerImageSource || ""

    content: StackView {
        id: stack
        initialItem: profileOverview
        anchors.centerIn: parent
        width: popup.width
        height: currentItem.implicitHeight || currentItem.height

        pushEnter: Transition { enabled: false }
        pushExit: Transition { enabled: false }
        popEnter: Transition { enabled: false }
        popExit: Transition { enabled: false }

        Component {
            id: profileOverview
            CommunityProfilePopupOverview {
                width: stack.width

                headerTitle: chatsModel.communities.activeCommunity.name
                headerSubtitle: {
                    switch(access) {
                        //% "Public community"
                        case Constants.communityChatPublicAccess: return qsTrId("public-community");
                        //% "Invitation only community"
                        case Constants.communityChatInvitationOnlyAccess: return qsTrId("invitation-only-community");
                        //% "On request community"
                        case Constants.communityChatOnRequestAccess: return qsTrId("on-request-community");
                        //% "Unknown community"
                        default: return qsTrId("unknown-community");
                    }
                }
                headerImageSource: chatsModel.communities.activeCommunity.thumbnailImage
                description: chatsModel.communities.activeCommunity.description

                onMembersListButtonClicked: popup.contentComponent.push(membersList)
                onNotificationsButtonClicked: {
                    chatsModel.communities.setCommunityMuted(chatsModel.communities.activeCommunity.id, checked)
                }
                onEditButtonClicked: openPopup(editCommunityPopup)
                onTransferOwnershipButtonClicked: openPopup(transferOwnershipPopup, {privateKey: chatsModel.communities.exportComumnity()})
                onLeaveButtonClicked: chatsModel.communities.leaveCommunity(communityId)
            }
        }

        Component {
            id: membersList
            CommunityProfilePopupMembersList {
                width: stack.width
                headerTitle: qsTr("Members")
                headerSubtitle: popup.nbMembers.toString()
                members: chatsModel.communities.activeCommunity.members
                onInviteButtonClicked: popup.contentComponent.push(inviteFriendsView)
            }
        }

        Component {
            id: inviteFriendsView
            CommunityProfilePopupInviteFriendsView {
                width: stack.width
                headerTitle: qsTr("Invite friends")

                contactListSearch.chatKey.text: ""
                contactListSearch.pubKey: ""
                contactListSearch.pubKeys: []
                contactListSearch.ensUsername: ""
                contactListSearch.existingContacts.visible: profileModel.contacts.list.hasAddedContacts()
                contactListSearch.noContactsRect.visible: !contactListSearch.existingContacts.visible
            }
        }
    }

    leftButtons: [
        StatusRoundButton {
            id: backButton
            icon.name: "arrow-right"
            icon.height: 16
            icon.width: 20
            rotation: 180
            visible: contentComponent.depth > 1
            height: !visible ? 0 : implicitHeight
            onClicked: {
                contentComponent.pop()
            }
        }
    ]

    rightButtons: [
        StatusButton {
            id: inviteButton
            text: qsTr("Invite")
            visible: popup.contentComponent.depth > 2
            height: !visible ? 0 : implicitHeight
            enabled: popup.contentComponent.currentItem.contactListSearch !== undefined && popup.contentComponent.currentItem.contactListSearch.pubKeys.length > 0
            onClicked: {
                popup.contentComponent.currentItem.sendInvites(popup.contentComponent.currentItem.contactListSearch.pubKeys)
                popup.contentComponent.pop()
            }
        }
    ]
}

