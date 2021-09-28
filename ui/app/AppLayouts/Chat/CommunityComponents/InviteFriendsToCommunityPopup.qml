import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQml.Models 2.3

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1


import utils 1.0
import "../../../../shared"
import "../components"

StatusModal {
    id: popup

    property var community

    onOpened: {
        contentItem.community = community

        contentItem.contactListSearch.chatKey.text = ""
        contentItem.contactListSearch.pubKey = ""
        contentItem.contactListSearch.pubKeys = []
        contentItem.contactListSearch.ensUsername = ""
        contentItem.contactListSearch.chatKey.forceActiveFocus(Qt.MouseFocusReason)
        contentItem.contactListSearch.existingContacts.visible = profileModel.contacts.list.hasAddedContacts()
        contentItem.contactListSearch.noContactsRect.visible = !contentItem.contactListSearch.existingContacts.visible
    }

    //% "Invite friends"
    header.title: qsTrId("invite-friends")

    contentItem: CommunityProfilePopupInviteFriendsView {
        id: contactFieldAndList
        contactListSearch.onUserClicked: {
            if (isContact) {
                // those are just added to the list to by added by the bunch
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

