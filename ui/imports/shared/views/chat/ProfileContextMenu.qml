import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQml.Models 2.3

import StatusQ.Popups 0.1
import StatusQ.Components 0.1

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.status 1.0
import shared.controls.chat 1.0
import shared.controls.chat.menuItems 1.0

StatusMenu {
    id: root

    property var store

    property string myPublicKey: ""

    property string selectedUserPublicKey: ""
    property string selectedUserDisplayName: ""
    property string selectedUserIcon: ""

    readonly property bool isMe: {
        return root.selectedUserPublicKey === root.store.contactsStore.myPublicKey;
    }
    readonly property var contactDetails: {
        if (root.selectedUserPublicKey === "" || isMe) {
            return {}
        }
        return Utils.getContactDetailsAsJson(root.selectedUserPublicKey);
    }
    readonly property bool isContact: {
        return root.selectedUserPublicKey !== "" && !!contactDetails.isContact
    }
    readonly property bool isBlockedContact: (!!contactDetails && contactDetails.isBlocked) || false

    readonly property int outgoingVerificationStatus: {
        if (root.selectedUserPublicKey === "" || root.isMe || !root.isContact) {
            return 0
        }
        return contactDetails.verificationStatus
    }
    readonly property int incomingVerificationStatus: {
        if (root.selectedUserPublicKey === "" || root.isMe || !root.isContact) {
            return 0
        }
        return contactDetails.incomingVerificationStatus
    }
    readonly property bool hasPendingContactRequest: {
        return !root.isMe && root.selectedUserPublicKey !== "" &&
            root.store.contactsStore.hasPendingContactRequest(root.selectedUserPublicKey);
    }
    readonly property bool hasActiveReceivedVerificationRequestFrom: {
        if (!root.selectedUserPublicKey || root.isMe || !root.isContact) {
            return false
        }
        return contactDetails.incomingVerificationStatus === Constants.verificationStatus.verifying ||
                contactDetails.incomingVerificationStatus === Constants.verificationStatus.verified
    }
    readonly property bool isVerificationRequestSent: {
        if (!root.selectedUserPublicKey || root.isMe || !root.isContact) {
            return false
        }
        return root.outgoingVerificationStatus !== Constants.verificationStatus.unverified &&
                root.outgoingVerificationStatus !== Constants.verificationStatus.verified &&
                root.outgoingVerificationStatus !== Constants.verificationStatus.trusted
    }
    readonly property bool isTrusted: {
        if (!root.selectedUserPublicKey || root.isMe || !root.isContact) {
            return false
        }
        return root.outgoingVerificationStatus === Constants.verificationStatus.trusted ||
                root.incomingVerificationStatus === Constants.verificationStatus.trusted
    }

    readonly property bool userTrustIsUnknown: contactDetails && contactDetails.trustStatus === Constants.trustStatus.unknown
    readonly property bool userIsUntrustworthy: contactDetails && contactDetails.trustStatus === Constants.trustStatus.untrustworthy

    signal openProfileClicked(string publicKey)
    signal createOneToOneChat(string communityId, string chatId, string ensName)

    onClosed: {
        // Reset selectedUserPublicKey so that associated properties get recalculated on re-open
        selectedUserPublicKey = ""
    }

    ProfileHeader {
        width: parent.width
        height: visible ? implicitHeight : 0

        displayNameVisible: false
        displayNamePlusIconsVisible: true
        editButtonVisible: false
        displayName: root.selectedUserDisplayName
        pubkey: root.selectedUserPublicKey
        icon: root.selectedUserIcon
        trustStatus: contactDetails && contactDetails.trustStatus ? contactDetails.trustStatus
                                                                  : Constants.trustStatus.unknown
        isContact: root.isContact
        isCurrentUser: root.isMe
        userIsEnsVerified: (!!contactDetails && contactDetails.ensVerified) || false
    }

    StatusMenuSeparator {
        topPadding: root.topPadding
    }

    ViewProfileMenuItem {
        id: viewProfileAction
        objectName: "viewProfile_StatusItem"
        onTriggered: {
            root.openProfileClicked(root.selectedUserPublicKey)
            root.close()
        }
    }

    SendMessageMenuItem {
        id: sendMessageMenuItem
        objectName: "sendMessage_StatusItem"
        enabled: root.isContact && !root.isBlockedContact
        onTriggered: {
            root.createOneToOneChat("", root.selectedUserPublicKey, "")
            root.close()
        }
    }

    SendContactRequestMenuItem {
        id: sendContactRequestMenuItem
        objectName: "sendContactRequest_StatusItem"
        enabled: !root.isMe && !root.isContact
                                && !root.isBlockedContact && !root.hasPendingContactRequest
        onTriggered: {
            Global.openContactRequestPopup(root.selectedUserPublicKey, null)
            root.close()
        }
    }

    StatusAction {
        id: verifyIdentityAction
        text: qsTr("Verify Identity")
        objectName: "verifyIdentity_StatusItem"
        icon.name: "checkmark-circle"
        enabled: !root.isMe && root.isContact
                                && !root.isBlockedContact
                                && root.outgoingVerificationStatus === Constants.verificationStatus.unverified
                                && !root.hasActiveReceivedVerificationRequestFrom
        onTriggered: {
            Global.openSendIDRequestPopup(root.selectedUserPublicKey, null)
            root.close()
        }
    }

    StatusAction {
        id: pendingIdentityAction
        objectName: "pendingIdentity_StatusItem"
        text: isVerificationRequestSent ||
            root.incomingVerificationStatus === Constants.verificationStatus.verified ?
            qsTr("ID Request Pending....") :
            qsTr("Respond to ID Request...")
        icon.name: "checkmark-circle"
        enabled: !root.isMe && root.isContact
                                && !root.isBlockedContact && !root.isTrusted
                                && (root.hasActiveReceivedVerificationRequestFrom
                                    || root.isVerificationRequestSent)
        onTriggered: {
            if (hasActiveReceivedVerificationRequestFrom) {
                Global.openIncomingIDRequestPopup(root.selectedUserPublicKey, null)
            } else if (root.isVerificationRequestSent) {
                Global.openOutgoingIDRequestPopup(root.selectedUserPublicKey, null)
            }

            root.close()
        }
    }

    StatusAction {
        id: renameAction
        objectName: "rename_StatusItem"
        text: qsTr("Rename")
        icon.name: "edit_pencil"
        enabled: !root.isMe
        onTriggered: {
            Global.openNicknamePopupRequested(root.selectedUserPublicKey, contactDetails.localNickname,
                                              "%1 (%2)".arg(root.selectedUserDisplayName).arg(Utils.getElidedCompressedPk(root.selectedUserPublicKey)))
            root.close()
        }
    }

    StatusAction {
        id: unblockAction
        objectName: "unblock_StatusItem"
        text: qsTr("Unblock User")
        icon.name: "remove-circle"
        enabled: !root.isMe && root.isBlockedContact
        onTriggered: Global.unblockContactRequested(root.selectedUserPublicKey, root.selectedUserDisplayName)
    }

    StatusMenuSeparator {
        visible: blockMenuItem.enabled
                 || markUntrustworthyMenuItem.enabled
                 || removeUntrustworthyMarkMenuItem.enabled
    }

    StatusAction {
        id: markUntrustworthyMenuItem
        objectName: "markUntrustworthy_StatusItem"
        text: qsTr("Mark as Untrustworthy")
        icon.name: "warning"
        type: StatusAction.Type.Danger
        enabled: !root.isMe && root.userTrustIsUnknown
        onTriggered: root.store.contactsStore.markUntrustworthy(root.selectedUserPublicKey)
    }

    StatusAction {
        id: removeUntrustworthyMarkMenuItem
        objectName: "removeUntrustworthy_StatusItem"
        text: qsTr("Remove Untrustworthy Mark")
        icon.name: "warning"
        enabled: !root.isMe && root.userIsUntrustworthy
        onTriggered: root.store.contactsStore.removeTrustStatus(root.selectedUserPublicKey)
    }

    StatusAction {
        text: qsTr("Remove Contact")
        objectName: "removeContact_StatusItem"
        icon.name: "remove-contact"
        type: StatusAction.Type.Danger
        enabled: root.isContact && !root.isBlockedContact && !root.hasPendingContactRequest
        onTriggered: {
            Global.removeContactRequested(root.selectedUserDisplayName, root.selectedUserPublicKey)
            root.close()
        }
    }

    StatusAction {
        id: blockMenuItem
        objectName: blockUser_StatusItem
        text: qsTr("Block User")
        icon.name: "cancel"
        type: StatusAction.Type.Danger
        enabled: !root.isMe && !root.isBlockedContact
        onTriggered: Global.blockContactRequested(root.selectedUserPublicKey, root.selectedUserDisplayName)
    }

}
