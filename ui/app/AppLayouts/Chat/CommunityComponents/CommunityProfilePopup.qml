import QtQuick 2.12
import QtQuick.Controls 2.12

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import "../../../../imports"

StatusModal {

    property var community

    id: popup

    onClosed: {
        while (contentComponent.depth > 1) {
            contentComponent.pop()
        }
    }

    header.title: contentComponent.currentItem.headerTitle
    header.subTitle: contentComponent.currentItem.headerSubtitle || ""
    header.image.source: contentComponent.currentItem.headerImageSource || ""
    header.icon.isLetterIdenticon: contentComponent.currentItem.headerTitle == popup.community.name && !contentComponent.currentItem.headerImageSource
    header.icon.background.color: popup.community.communityColor

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

                headerTitle: popup.community.name
                headerSubtitle: {
                    switch(popup.community.access) {
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
                headerImageSource: popup.community.thumbnailImage
                community: popup.community

                onMembersListButtonClicked: popup.contentComponent.push(membersList)
                onNotificationsButtonClicked: {
                    chatsModel.communities.setCommunityMuted(popup.community.id, checked)
                }
                onEditButtonClicked: openPopup(editCommunityPopup, {
                    community: popup.community
                })
                onTransferOwnershipButtonClicked: openPopup(transferOwnershipPopup, {privateKey: chatsModel.communities.exportCommunity()})
                onLeaveButtonClicked: chatsModel.communities.leaveCommunity(popup.community.id)
            }
        }

        Component {
            id: transferOwnershipPopup
            TransferOwnershipPopup {
                anchors.centerIn: parent
                onClosed: {
                    destroy()
                }
            }
        }

        Component {
            id: membersList
            CommunityProfilePopupMembersList {
                width: stack.width
                //% "Members"
                headerTitle: qsTrId("members-label")
                headerSubtitle: popup.community.nbMembers.toString()
                community: popup.community
                onInviteButtonClicked: popup.contentComponent.push(inviteFriendsView)
            }
        }

        Component {
            id: inviteFriendsView
            CommunityProfilePopupInviteFriendsView {
                width: stack.width
                //% "Invite friends"
                headerTitle: qsTrId("invite-friends")
                community: popup.community

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
            //% "Invite"
            text: qsTrId("community-invite-title")
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

