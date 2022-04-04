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
    property var communitySectionModule
    property bool hasAddedContacts

    signal sendInvites(var pubKeys)

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

    margins: 32
    height: 550

    header.title: qsTr("Invite friends")

    function processInviteResult(error) {
        if (error) {
            console.error('Error inviting', error)
            contactFieldAndList.validationError = error
            return
        }
        popup.contentItem.contactListSearch.successMessage = qsTr("Invite successfully sent")
    }

    contentItem: CommunityProfilePopupInviteFriendsPanel {
        id: contactFieldAndList
        rootStore: popup.rootStore
        contactsStore: popup.contactsStore
        community: popup.community
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
            text: qsTr("Invite")
            onClicked : {
                popup.sendInvites(popup.contentItem.contactListSearch.pubKeys)
            }
        }
    ]
}

