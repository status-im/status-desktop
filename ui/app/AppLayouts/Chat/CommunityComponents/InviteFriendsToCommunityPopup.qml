import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQml.Models 2.3
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"
import "./"
import "../components"

ModalPopup {
    id: popup

    property string communityId: chatsModel.communities.activeCommunity.id
    property var goBack

    onOpened: {
        contactFieldAndList.contactListSearch.chatKey.text = ""
        contactFieldAndList.contactListSearch.pubKey = ""
        contactFieldAndList.contactListSearch.pubKeys = []
        contactFieldAndList.contactListSearch.ensUsername = ""
        contactFieldAndList.contactListSearch.chatKey.forceActiveFocus(Qt.MouseFocusReason)
        contactFieldAndList.contactListSearch.existingContacts.visible = profileModel.contacts.list.hasAddedContacts()
        contactFieldAndList.contactListSearch.noContactsRect.visible = !contactFieldAndList.contactListSearch.existingContacts.visible
    }

    //% "Invite friends"
    title: qsTrId("invite-friends")

    height: 630

    CommunityProfilePopupInviteFriendsView {
        id: contactFieldAndList
        anchors.fill: parent
        contactListSearch.onUserClicked: {
            if (isContact) {
                // those are just added to the list to by added by the bunch
                return
            }
            contactFieldAndList.sendInvites([pubKey])
        }
    }

    footer: Item {
        width: parent.width
        height: inviteBtn.height

        StatusRoundButton {
            id: btnBack
            anchors.left: parent.left
            visible: !!popup.goBack
            icon.name: "arrow-right"
            icon.width: 20
            icon.height: 16
            rotation: 180
            onClicked: {
                // Go back? Make it work when it's
                popup.goBack()
            }
        }

        StatusButton {
            id: inviteBtn
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            enabled: contactFieldAndList.contactListSearch.pubKeys.length > 0
            //% "Invite"
            text: qsTrId("invite-button")
            onClicked : {
                contactFieldAndList.sendInvites(contactFieldAndList.contactListSearch.pubKeys)
            }
        }
    }
}

