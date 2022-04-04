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
    property var contactsStore
    property bool hasAddedContacts
    property var communitySectionModule

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
                        case Constants.communityChatPublicAccess: return qsTr("Public community");
                        case Constants.communityChatInvitationOnlyAccess: return qsTr("Invitation only community");
                        case Constants.communityChatOnRequestAccess: return qsTr("On request community");
                        default: return qsTr("Unknown community");
                    }
                }
                headerImageSource: root.community.image
                community: root.community

                onTransferOwnershipButtonClicked: Global.openPopup(transferOwnershiproot, {
                    privateKey: communitySectionModule.exportCommunity(root.community.id),
                    store: root.store
                })
                onLeaveButtonClicked: {
                    communitySectionModule.leaveCommunity();
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
            id: inviteFriendsView
            CommunityProfilePopupInviteFriendsPanel {
                width: stack.width
                headerTitle: qsTr("Invite friends")
                community: root.community
                contactsStore: root.contactsStore
                rootStore: root.store

                contactListSearch.chatKey.text: ""
                contactListSearch.pubKey: ""
                contactListSearch.pubKeys: []
                contactListSearch.ensUsername: ""
                contactListSearch.existingContacts.visible: root.hasAddedContacts
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
            text: qsTr("Invite")
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

