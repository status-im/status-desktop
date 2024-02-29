import QtQuick 2.13
import utils 1.0

QtObject {
    id: root

    property var contactsModule

    property var globalUtilsInst: globalUtils
    property var mainModuleInst: Global.appIsReady? mainModule : null

    property string myPublicKey: !!Global.userProfile? Global.userProfile.pubKey : ""

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

    function changeContactNickname(pubKey, nickname, displayName, isEdit) {
        root.contactsModule.changeContactNickname(pubKey, nickname)

        let message = ""
        if (nickname === "") { // removed nickname
            message = qsTr("Nickname for %1 removed").arg(displayName)
        } else {
            if (isEdit)
                message = qsTr("Nickname for %1 changed").arg(displayName) // changed nickname
            else
                message = qsTr("Nickname for %1 added").arg(displayName) // added a new nickname
        }
        if (!!message) {
            Global.displaySuccessToastMessage(message)
        }
    }

    function sendContactRequest(pubKey, message) {
        root.contactsModule.sendContactRequest(pubKey, message)
        Global.displaySuccessToastMessage(qsTr("Contact request sent"))
    }

    function acceptContactRequest(pubKey, contactRequestId) {
        root.contactsModule.acceptContactRequest(pubKey, contactRequestId)
    }

    function dismissContactRequest(pubKey, contactRequestId) {
        root.contactsModule.dismissContactRequest(pubKey, contactRequestId)
    }

    function getLatestContactRequestForContactAsJson(pubKey) {
        let resp = root.contactsModule.getLatestContactRequestForContactAsJson(pubKey)
        return JSON.parse(resp)
    }

    function markAsTrusted(pubKey) {
        root.contactsModule.markAsTrusted(pubKey)
    }

    function markUntrustworthy(pubKey) {
        root.contactsModule.markUntrustworthy(pubKey)
    }

    function removeTrustStatus(pubKey) {
        root.contactsModule.removeTrustStatus(pubKey)
    }

    function sendVerificationRequest(pubKey, challenge) {
        root.contactsModule.sendVerificationRequest(pubKey, challenge);
        Global.displaySuccessToastMessage(qsTr("ID verification request sent"))
    }

    function cancelVerificationRequest(pubKey) {
        root.contactsModule.cancelVerificationRequest(pubKey);
        Global.displaySuccessToastMessage(qsTr("ID verification request cancelled"))
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

    function verifiedTrusted(pubKey) {
        root.contactsModule.verifiedTrusted(pubKey);
    }

    function verifiedUntrustworthy(pubKey) {
        root.contactsModule.verifiedUntrustworthy(pubKey);
    }

    function requestContactInfo(publicKey) {
        root.contactsModule.requestContactInfo(publicKey)
    }

    function getContactPublicKeyByAddress(address) {
        return "" // TODO retrive contact public key from address
    }

    function getLinkToProfile(publicKey) {
        return root.contactsModule.shareUserUrlWithData(publicKey)
    }
}
