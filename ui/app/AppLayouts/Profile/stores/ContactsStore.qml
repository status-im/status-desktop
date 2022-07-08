import QtQuick 2.13
import utils 1.0

QtObject {
    id: root

    property var contactsModule

    property var globalUtilsInst: globalUtils
    property var mainModuleInst: mainModule

    property string myPublicKey: userProfile.pubKey

    property var myContactsModel: contactsModule.myMutualContactsModel
    property var blockedContactsModel: contactsModule.blockedContactsModel
    property var receivedContactRequestsModel: contactsModule.receivedContactRequestsModel
    property var sentContactRequestsModel: contactsModule.sentContactRequestsModel

    // Temporary commented until we provide appropriate flags on the `status-go` side to cover all sections.
//    property var receivedButRejectedContactRequestsModel: contactsModule.receivedButRejectedContactRequestsModel
//    property var sentButRejectedContactRequestsModel: contactsModule.sentButRejectedContactRequestsModel

    function resolveENS(value) {
        root.mainModuleInst.resolveENS(value, "")
    }

    function generateAlias(pubKey) {
       return root.globalUtilsInst.generateAlias(pubKey)
    }

    function getFromClipboard() {
       return root.globalUtilsInst.getFromClipboard()
    }

    function isMyMutualContact(pubKey) {
       return root.contactsModule.isMyMutualContact(pubKey)
    }

    function isBlockedContact(pubKey) {
       return root.contactsModule.isBlockedContact(pubKey)
    }

    function hasPendingContactRequest(pubKey) {
       return root.contactsModule.hasPendingContactRequest(pubKey)
    }

    function joinPrivateChat(pubKey) {
        Global.changeAppSectionBySectionType(Constants.appSection.chat)
        root.contactsModule.switchToOrCreateOneToOneChat(pubKey)
    }

    function unblockContact(pubKey) {
        root.contactsModule.unblockContact(pubKey)
    }

    function blockContact(pubKey) {
        root.contactsModule.blockContact(pubKey)
    }

    function removeContact(pubKey) {
        root.contactsModule.removeContact(pubKey)
    }

    function changeContactNickname(pubKey, nickname) {
        root.contactsModule.changeContactNickname(pubKey, nickname)
    }

    function sendContactRequest(pubKey, message) {
        root.contactsModule.sendContactRequest(pubKey, message)
    }

    function acceptContactRequest(pubKey) {
        root.contactsModule.acceptContactRequest(pubKey)
    }

    function dismissContactRequest(pubKey) {
        root.contactsModule.dismissContactRequest(pubKey)
    }

    function removeContactRequestRejection(pubKey) {
        root.contactsModule.removeContactRequestRejection(pubKey)
    }

    function markUntrustworthy(pubKey) {
        root.contactsModule.markUntrustworthy(pubKey)
    }

    function removeTrustStatus(pubKey) {
        root.contactsModule.removeTrustStatus(pubKey)
    }

    function sendVerificationRequest(pubKey, challenge) {
        root.contactsModule.sendVerificationRequest(pubKey, challenge);
    }

    function cancelVerificationRequest(pubKey) {
        root.contactsModule.cancelVerificationRequest(pubKey);
    }

    function declineVerificationRequest(pubKey) {
        root.contactsModule.declineVerificationRequest(pubKey);
    }

    function acceptVerificationRequest(pubKey, response) {
        root.contactsModule.acceptVerificationRequest(pubKey, response);
    }

    function getVerificationDetailsFromAsJson(pubKey) {
        let resp = root.contactsModule.getVerificationDetailsFromAsJson(pubKey);
        return JSON.parse(resp);
    }

    function getSentVerificationDetailsAsJson(pubKey) {
        let resp = root.contactsModule.getSentVerificationDetailsAsJson(pubKey);
        return JSON.parse(resp);
    }

    function hasReceivedVerificationRequestFrom(pubKey) {
        return root.contactsModule.hasReceivedVerificationRequestFrom(pubKey);
    }

    function verifiedTrusted(pubKey) {
        root.contactsModule.verifiedTrusted(pubKey);
    }

    function verifiedUntrustworthy(pubKey) {
        root.contactsModule.verifiedUntrustworthy(pubKey);
    }
}
