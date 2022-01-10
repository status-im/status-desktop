import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQml.Models 2.3

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

import utils 1.0

import "../../views"
import "../../panels/communities"

StatusModal {
    id: popup

    property var rootStore
    property var contactsStore
    property var community
    property bool hasAddedContacts

    onOpened: {
        contentItem.community = community;

        contentItem.contactListSearch.chatKey.text = "";
        contentItem.contactListSearch.pubKey = "";
        contentItem.contactListSearch.pubKeys = [];
        contentItem.contactListSearch.ensUsername = "";
        contentItem.contactListSearch.chatKey.forceActiveFocus(Qt.MouseFocusReason);
        contentItem.contactListSearch.existingContacts.visible = hasAddedContacts;
        contentItem.contactListSearch.noContactsRect.visible = !contentItem.contactListSearch.existingContacts.visible;
    }

    //% "Invite friends"
    header.title: qsTrId("invite-friends")

    contentItem: CommunityProfilePopupInviteFriendsPanel {
        id: contactFieldAndList
        rootStore: popup.rootStore
        contactsStore: popup.contactsStore
        community: popup.community
        contactListSearch.onUserClicked: {
            if (isAddedContact) {
                // those are just added to the list to be added by the bunch
                return
            }
            contactFieldAndList.sendInvites([pubKey])
        }
    }

    leftButtons: [
        StatusRoundButton {
            icon.name: "arrow-right"
            icon.height: 16
            icon.width: 20
            rotation: 180
            onClicked: {
                popup.close()
            }
        }
    ]

    rightButtons: [
        StatusButton {
            enabled: popup.contentItem.contactListSearch.pubKeys.length > 0
            //% "Invite"
            text: qsTrId("invite-button")
            onClicked : {
                popup.contentItem.sendInvites(popup.contentItem.contactListSearch.pubKeys)
            }
        }
    ]
}

