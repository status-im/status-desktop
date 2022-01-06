import QtQuick 2.12
import QtQuick.Controls 2.12

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1


import utils 1.0

import "../../panels/communities"

StatusModal {
    id: root

    property var store
    property var community

    onClosed: {
        while (contentItem.depth > 1) {
            contentItem.pop()
        }
    }

    header.title: contentItem.currentItem.headerTitle
    header.subTitle: contentItem.currentItem.headerSubtitle || ""
    header.image.source: contentItem.currentItem.headerImageSource || ""
    header.icon.isLetterIdenticon: contentItem.currentItem.headerTitle === root.community.name && !contentItem.currentItem.headerImageSource
    header.icon.background.color: root.community.color

    contentItem: StackView {
        id: stack
        initialItem: profileOverview
        width: root.width
        implicitHeight: currentItem.implicitHeight || currentItem.height

        pushEnter: Transition { enabled: false }
        pushExit: Transition { enabled: false }
        popEnter: Transition { enabled: false }
        popExit: Transition { enabled: false }

        Component {
            id: profileOverview
            CommunityProfilePopupOverviewPanel {
                width: stack.width

                headerTitle: root.community.name
                headerSubtitle: {
                    switch(root.community.access) {
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
                headerImageSource: root.community.image
                community: root.community

                onMembersListButtonClicked: root.contentItem.push(membersList)
                onNotificationsButtonClicked: {
                    root.store.setCommunityMuted(root.community.id, checked);
                }
                onEditButtonClicked: Global.openPopup(editCommunityPopup, {
                    store: root.store,
                    community: root.community,
                    onSave: root.close
                })
                onTransferOwnershipButtonClicked: Global.openPopup(transferOwnershiproot, {
                    privateKey: root.store.exportCommunity(),
                    store: root.store
                })
                onLeaveButtonClicked: {
                    root.store.leaveCommunity(root.community.id);
                    root.close();
                }
                onCopyToClipboard: {
                    root.store.copyToClipboard(link);
                }
            }
        }

        Component {
            id: transferOwnershiproot
            TransferOwnershipPopup {
                anchors.centerIn: parent
                onClosed: {
                    destroy()
                }
            }
        }

        Component {
            id: editCommunityroot
            CreateCommunityPopup {
                anchors.centerIn: parent
                store: root.store
                isEdit: true
                onClosed: {
                    destroy()
                }
            }
        }

        Component {
            id: membersList
            CommunityProfilePopupMembersListPanel {
                // TODO assign the store on open
                store: root.store
                width: stack.width
                //% "Members"
                headerTitle: qsTrId("members-label")
                headerSubtitle: root.community.nbMembers.toString()
                community: root.community
                onInviteButtonClicked: root.contentItem.push(inviteFriendsView)
            }
        }

        Component {
            id: inviteFriendsView
            CommunityProfilePopupInviteFriendsPanel {
                width: stack.width
                //% "Invite friends"
                headerTitle: qsTrId("invite-friends")
                community: root.community

                contactListSearch.chatKey.text: ""
                contactListSearch.pubKey: ""
                contactListSearch.pubKeys: []
                contactListSearch.ensUsername: ""
                // Not Refactored Yet
//                contactListSearch.existingContacts.visible: root.store.allContacts.hasAddedContacts()
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
            visible: root.contentItem.depth > 2
            height: !visible ? 0 : implicitHeight
            enabled: root.contentItem.currentItem.contactListSearch !== undefined && root.contentItem.currentItem.contactListSearch.pubKeys.length > 0
            onClicked: {
                root.contentItem.currentItem.sendInvites(root.contentItem.currentItem.contactListSearch.pubKeys)
                root.contentItem.pop()
            }
        }
    ]
}

