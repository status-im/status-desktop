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
        contactFieldAndList.chatKey.text = ""
        contactFieldAndList.pubKey = ""
        contactFieldAndList.pubKeys = []
        contactFieldAndList.ensUsername = ""
        contactFieldAndList.chatKey.forceActiveFocus(Qt.MouseFocusReason)
        contactFieldAndList.existingContacts.visible = profileModel.contacts.list.hasAddedContacts()
        contactFieldAndList.noContactsRect.visible = !contactFieldAndList.existingContacts.visible
    }

    //% "Invite friends"
    title: qsTrId("invite-friends")

    height: 630

    function sendInvites(pubKeys) {
        const error = chatsModel.communities.inviteUsersToCommunityById(popup.communityId, JSON.stringify(pubKeys))
        if (error) {
            console.error('Error inviting', error)
            contactFieldAndList.validationError = error
            return
        }
        contactFieldAndList.successMessage = qsTr("Invite successfully sent")
    }

    Item {
        anchors.fill: parent

        TextWithLabel {
            id: shareCommunity
            anchors.top: parent.top
            //% "Share community"
            label: qsTrId("share-community")
            text: `${Constants.communityLinkPrefix}${communityId.substring(0, 4)}...${communityId.substring(communityId.length -2)}`
            textToCopy: Constants.communityLinkPrefix + communityId
        }

        Separator {
            id: sep
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: shareCommunity.bottom
            anchors.topMargin: Style.current.smallPadding
            anchors.leftMargin: -Style.current.padding
            anchors.rightMargin: -Style.current.padding
        }

        ContactsListAndSearch {
            id: contactFieldAndList
            anchors.top: sep.bottom
            anchors.topMargin: Style.current.smallPadding
            anchors.bottom: parent.bottom
            showCheckbox: true
            onUserClicked: function (isContact, pubKey, ensName) {
                if (isContact) {
                    // those are just added to the list to by added by the bunch
                    return
                }
                sendInvites([pubKey])
            }
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
            enabled: contactFieldAndList.pubKeys.length > 0
            //% "Invite"
            text: qsTrId("invite-button")
            onClicked : {
                sendInvites(contactFieldAndList.pubKeys)
            }
        }
    }
}

