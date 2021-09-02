import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQml.Models 2.3

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

import "../../../../imports"
import "../../../../shared"
import "../components"

StatusModal {
    id: popup

    property var community

    onOpened: {
        contentComponent.community = community

        contentComponent.contactListSearch.chatKey.text = ""
        contentComponent.contactListSearch.pubKey = ""
        contentComponent.contactListSearch.pubKeys = []
        contentComponent.contactListSearch.ensUsername = ""
        contentComponent.contactListSearch.chatKey.forceActiveFocus(Qt.MouseFocusReason)
        contentComponent.contactListSearch.existingContacts.visible = profileModel.contacts.list.hasAddedContacts()
        contentComponent.contactListSearch.noContactsRect.visible = !contentComponent.contactListSearch.existingContacts.visible
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
            enabled: popup.contentComponent.contactListSearch.pubKeys.length > 0
            //% "Invite"
            text: qsTrId("invite-button")
            onClicked : {
                popup.contentComponent.sendInvites(popup.contentComponent.contactListSearch.pubKeys)
            }
        }
    ]
}

