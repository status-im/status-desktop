import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import utils 1.0
import shared 1.0
import shared.popups 1.0
import shared.stores 1.0
import shared.views 1.0 as SharedViews
import shared.controls.chat 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

StatusModal {
    id: popup

    property Popup parentPopup

    property var profileStore
    property var contactsStore

    property string userPublicKey: ""
    property string userDisplayName: ""
    property string userName: ""
    property string userNickname: ""
    property string userEnsName: ""
    property string userIcon: ""

    property bool userIsEnsVerified: false
    property bool userIsBlocked: false
    property bool isCurrentUser: false
    property bool isAddedContact: false

    signal contactUnblocked(publicKey: string)
    signal contactBlocked(publicKey: string)

    function openPopup(publicKey, state = "") {
        // All this should be improved more, but for now we leave it like this.
        const contactDetails = Utils.getContactDetailsAsJson(publicKey);
        userPublicKey = publicKey;
        userDisplayName = contactDetails.displayName;
        userName = contactDetails.alias;
        userNickname = contactDetails.localNickname;
        userEnsName = contactDetails.name;
        userIcon = contactDetails.displayIcon;
        userIsEnsVerified = contactDetails.ensVerified;
        userIsBlocked = contactDetails.isBlocked;
        isAddedContact = contactDetails.isContact;
        isCurrentUser = popup.profileStore.pubkey === publicKey;

        showFooter = !isCurrentUser;
        popup.open();

        if (state == "openNickname") {
            nicknamePopup.open();
        } else if (state == "contactRequest") {
            sendContactRequestModal.open()
        } else if (state == "blockUser") {
            blockUser();
        } else if (state == "unblockUser") {
            unblockUser();
        }
    }

    function blockUser() {
        profileView.blockContactConfirmationDialog.contactName = userName;
        profileView.blockContactConfirmationDialog.contactAddress = userPublicKey;
        profileView.blockContactConfirmationDialog.open();
    }

    function unblockUser() {
        profileView.unblockContactConfirmationDialog.contactName = userName;
        profileView.unblockContactConfirmationDialog.contactAddress = userPublicKey;
        profileView.unblockContactConfirmationDialog.open();
    }

    header.title: userDisplayName + qsTr("'s Profile")
    header.subTitle: userIsEnsVerified ? userName : Utils.getElidedCompressedPk(userPublicKey)
    header.subTitleElide: Text.ElideMiddle
    padding: 8

    QtObject {
        id: d

        readonly property int contentSpacing: 5
        readonly property int contentMargins: 16
    }

    headerActionButton: StatusFlatRoundButton {
        type: StatusFlatRoundButton.Type.Secondary
        width: 32
        height: 32

        icon.width: 20
        icon.height: 20
        icon.name: "qr"
        onClicked: profileView.qrCodePopup.open()
    }

    SharedViews.ProfileView {
        id: profileView
        anchors.fill: parent

        profileStore: popup.profileStore
        contactsStore: popup.contactsStore

        userPublicKey: popup.userPublicKey
        userDisplayName: popup.userDisplayName
        userName: popup.userName
        userNickname: popup.userNickname
        userEnsName: popup.userEnsName
        userIcon: popup.userIcon
        userIsEnsVerified: popup.userIsEnsVerified
        userIsBlocked: popup.userIsBlocked
        isAddedContact: popup.isAddedContact
        isCurrentUser: popup.isCurrentUser

        onContactUnblocked: {
            popup.close()
            popup.contactUnblocked(publicKey)
        }

        onContactBlocked: {
            popup.close()
            popup.contactBlocked(publicKey)
        }

        onContactAdded: {
            popup.close()
            popup.contactAdded(publicKey)
        }

        onContactRemoved: {
            popup.close()
        }
        
        onNicknameEdited: {
            popup.close()
        }
    }

    // TODO: replace with StatusStackModal
    SendContactRequestModal {
        id: sendContactRequestModal
        anchors.centerIn: parent
        width: popup.width
        height: popup.height
        visible: false
        header.title: qsTr("Send Contact Request to") + " " + userDisplayName
        userPublicKey: popup.userPublicKey
        userDisplayName: popup.userDisplayName
        userIcon: popup.userIcon
        onAccepted: popup.contactsStore.sendContactRequest(userPublicKey, message)
        onClosed: popup.close()
    }

    rightButtons: [
        StatusFlatButton {
            text: userIsBlocked ?
                qsTr("Unblock User") :
                qsTr("Block User")
            type: StatusBaseButton.Type.Danger
            onClicked: userIsBlocked ? unblockUser() : blockUser()
        },

        StatusFlatButton {
            visible: !userIsBlocked && isAddedContact
            type: StatusBaseButton.Type.Danger
            text: qsTr('Remove Contact')
            onClicked: {
                profileView.removeContactConfirmationDialog.parentPopup = popup;
                profileView.removeContactConfirmationDialog.open();
            }
        },

        StatusButton {
            text: qsTr("Send Contact Request")
            visible: !userIsBlocked && !isAddedContact
            onClicked: sendContactRequestModal.open()
        }
    ]
}
