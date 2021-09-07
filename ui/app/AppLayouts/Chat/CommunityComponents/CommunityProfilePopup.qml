import QtQuick 2.12
import QtQuick.Controls 2.12

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import "../../../../imports"

StatusModal {

    property var community

    id: popup

    onClosed: {
        while (contentItem.depth > 1) {
            contentItem.pop()
        }
    }

    header.title: contentItem.currentItem.headerTitle
    header.subTitle: contentItem.currentItem.headerSubtitle || ""
    header.image.source: contentItem.currentItem.headerImageSource || ""
    header.icon.isLetterIdenticon: contentItem.currentItem.headerTitle == popup.community.name && !contentItem.currentItem.headerImageSource
    header.icon.background.color: popup.community.communityColor

    contentItem: StackView {
        id: stack
        initialItem: profileOverview
        width: popup.width
        implicitHeight: currentItem.implicitHeight || currentItem.height

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

                onMembersListButtonClicked: popup.contentItem.push(membersList)
                onNotificationsButtonClicked: {
                    chatsModel.communities.setCommunityMuted(popup.community.id, checked)
                }
                onEditButtonClicked: openPopup(editCommunityPopup, {
                    community: popup.community
                })
                onTransferOwnershipButtonClicked: openPopup(transferOwnershipPopup, {privateKey: chatsModel.communities.exportCommunity()})
                onLeaveButtonClicked: {
                    chatsModel.communities.leaveCommunity(popup.community.id)
                    popup.close()
                }
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
                onInviteButtonClicked: popup.contentItem.push(inviteFriendsView)
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
            visible: contentItem.depth > 1
            height: !visible ? 0 : implicitHeight
            onClicked: {
                contentItem.pop()
            }
        }
    ]

    rightButtons: [
        StatusButton {
            //% "Invite"
            text: qsTrId("community-invite-title")
            visible: popup.contentItem.depth > 2
            height: !visible ? 0 : implicitHeight
            enabled: popup.contentItem.currentItem.contactListSearch !== undefined && popup.contentItem.currentItem.contactListSearch.pubKeys.length > 0
            onClicked: {
                popup.contentItem.currentItem.sendInvites(popup.contentItem.currentItem.contactListSearch.pubKeys)
                popup.contentItem.pop()
            }
        }
    ]
}

