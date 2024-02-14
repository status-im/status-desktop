import QtQuick 2.15

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

    property bool isBridgedAccount: false

    readonly property bool isMe: {
        return root.selectedUserPublicKey === root.store.contactsStore.myPublicKey;
    }
    readonly property var contactDetails: {
        if (root.selectedUserPublicKey === "" || isMe) {
            return {}
        }
        return Utils.getContactDetailsAsJson(root.selectedUserPublicKey, true, true);
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
        Binding on onlineStatus {
            value: contactDetails.onlineStatus
            when: !root.isMe
        }
        isContact: root.isContact
        isBlocked: root.isBlockedContact
        isCurrentUser: root.isMe
        userIsEnsVerified: (!!contactDetails && contactDetails.ensVerified) || false
        isBridgedAccount: root.isBridgedAccount
    }

    StatusMenuSeparator {
        topPadding: root.topPadding
        visible: !root.isBridgedAccount
    }

    ViewProfileMenuItem {
        id: viewProfileAction
        objectName: "viewProfile_StatusItem"
        enabled: !root.isBridgedAccount
        onTriggered: {
            root.openProfileClicked(root.selectedUserPublicKey)
            root.close()
        }
    }

    // TODO Review contact request popup

    SendMessageMenuItem {
        id: sendMessageMenuItem
        objectName: "sendMessage_StatusItem"
        enabled: root.isContact && !root.isBlockedContact && !root.isBridgedAccount
        onTriggered: {
            root.createOneToOneChat("", root.selectedUserPublicKey, "")
            root.close()
        }
    }

    SendContactRequestMenuItem {
        id: sendContactRequestMenuItem
        objectName: "sendContactRequest_StatusItem"
        enabled: !root.isMe && !root.isContact
                                && !root.isBlockedContact && !root.hasPendingContactRequest && !root.isBridgedAccount
        onTriggered: {
            Global.openContactRequestPopup(root.selectedUserPublicKey, null)
            root.close()
        }
    }

    StatusAction {
        id: verifyIdentityAction
        text: qsTr("Request ID verification")
        objectName: "verifyIdentity_StatusItem"
        icon.name: "checkmark-circle"
        enabled: !root.isMe && root.isContact
                                && !root.isBlockedContact
                                && root.outgoingVerificationStatus === Constants.verificationStatus.unverified
                                && !root.hasActiveReceivedVerificationRequestFrom
                                && !root.isBridgedAccount
        onTriggered: {
            Global.openSendIDRequestPopup(root.selectedUserPublicKey, null)
            root.close()
        }
    }
    // TODO Mark as ID verified
    StatusAction {
        id: pendingIdentityAction
        objectName: "pendingIdentity_StatusItem"
        text: isVerificationRequestSent || root.incomingVerificationStatus === Constants.verificationStatus.verified ? qsTr("ID Request Pending...")
                                                                                                                     : qsTr("Respond to ID Request...")
        icon.name: "checkmark-circle"
        enabled: !root.isMe && root.isContact
                                && !root.isBlockedContact && !root.isTrusted
                                && (root.hasActiveReceivedVerificationRequestFrom
                                    || root.isVerificationRequestSent)
                                && !root.isBridgedAccount
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
        text: contactDetails.localNickname ? qsTr("Edit nickname") : qsTr("Add nickname")
        icon.name: "edit_pencil"
        enabled: !root.isMe && !root.isBridgedAccount
        onTriggered: {
            Global.openNicknamePopupRequested(root.selectedUserPublicKey, root.contactDetails)
            root.close()
        }
    }

    StatusMenuSeparator {
        visible: blockMenuItem.enabled
                 || markUntrustworthyMenuItem.enabled
                 || removeUntrustworthyMarkMenuItem.enabled
    }

    StatusAction {
        text: qsTr("Remove nickname")
        icon.name: "delete"
        type: StatusAction.Type.Danger
        enabled: !root.isMe && !!contactDetails.localNickname
        onTriggered: root.store.contactsStore.changeContactNickname(root.selectedUserPublicKey, "", root.selectedUserDisplayName, true)
    }

    StatusAction {
        id: unblockAction
        objectName: "unblock_StatusItem"
        text: qsTr("Unblock user")
        icon.name: "cancel"
        type: StatusAction.Type.Danger
        enabled: !root.isMe && root.isBlockedContact && !root.isBridgedAccount
        onTriggered: Global.unblockContactRequested(root.selectedUserPublicKey, root.selectedUserDisplayName)
    }

    // TODO Remove ID verification + confirmation dialog

    StatusAction {
        id: markUntrustworthyMenuItem
        objectName: "markUntrustworthy_StatusItem"
        text: qsTr("Mark as untrusted")
        icon.name: "warning"
        type: StatusAction.Type.Danger
        enabled: !root.isMe && root.userTrustIsUnknown && !root.isBridgedAccount && !root.isBlockedContact
        onTriggered: root.store.contactsStore.markUntrustworthy(root.selectedUserPublicKey)
    }

    StatusAction {
        id: removeUntrustworthyMarkMenuItem
        objectName: "removeUntrustworthy_StatusItem"
        text: qsTr("Remove untrusted mark")
        icon.name: "warning"
        type: StatusAction.Type.Danger
        enabled: !root.isMe && root.userIsUntrustworthy && !root.isBridgedAccount
        onTriggered: root.store.contactsStore.removeTrustStatus(root.selectedUserPublicKey)
    }

    StatusAction {
        text: qsTr("Remove contact")
        objectName: "removeContact_StatusItem"
        icon.name: "remove-contact"
        type: StatusAction.Type.Danger
        enabled: root.isContact && !root.isBlockedContact && !root.hasPendingContactRequest && !root.isBridgedAccount
        onTriggered: {
            Global.removeContactRequested(root.selectedUserDisplayName, root.selectedUserPublicKey)
            root.close()
        }
    }

    StatusAction {
        id: blockMenuItem
        objectName: "blockUser_StatusItem"
        text: qsTr("Block user")
        icon.name: "cancel"
        type: StatusAction.Type.Danger
        enabled: !root.isMe && !root.isBlockedContact && !root.isBridgedAccount
        onTriggered: Global.blockContactRequested(root.selectedUserPublicKey, root.selectedUserDisplayName)
    }
}
