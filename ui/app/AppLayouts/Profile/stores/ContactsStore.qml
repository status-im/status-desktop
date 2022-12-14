import QtQuick 2.13

import SortFilterProxyModel 0.2

import utils 1.0

QtObject {
    id: root

    property var contactsModule

    property var globalUtilsInst: globalUtils
    property var mainModuleInst: mainModule

    property string myPublicKey: userProfile.pubKey

    property var allContactsModel: contactsModule.contactsModel

    property var mutualContactsModel: SortFilterProxyModel {
        sourceModel: root.allContactsModel
        filters: ExpressionFilter { expression: model.isContact }
    }

    property var blockedContactsModel: SortFilterProxyModel {
        sourceModel: root.allContactsModel
        filters: ExpressionFilter { expression: model.isBlocked }
    }

    property var receivedRequestsModel: SortFilterProxyModel {
        sourceModel: root.allContactsModel
        filters: ExpressionFilter { expression: _filterReceivedRequests(model) }
    }

    property var sentRequestsModel: SortFilterProxyModel {
        sourceModel: root.allContactsModel
        filters: ExpressionFilter { expression: _filterSentRequests(model) }
    }

    function _filterReceivedRequests(contact) {
        return contact.contactRequestStatus === Constants.contactRequestStatus.incomingPending ||
               contact.incomingVerificationStatus === Constants.verificationStatus.verifying
    }

    function _filterSentRequests(contact) {
        return contact.contactRequestStatus === Constants.contactRequestStatus.outgoingPending ||
               contact.outgoingVerificationStatus === Constants.verificationStatus.verifying
    }

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
       return root.allContactsModel.isMyMutualContact(pubKey)
    }

    function isBlockedContact(pubKey) {
       return root.allContactsModel.isBlockedContact(pubKey)
    }

    function hasPendingContactRequest(pubKey) {
       return root.allContactsModel.hasPendingContactRequest(pubKey)
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

    function verifiedTrusted(pubKey) {
        root.contactsModule.verifiedTrusted(pubKey);
    }

    function verifiedUntrustworthy(pubKey) {
        root.contactsModule.verifiedUntrustworthy(pubKey);
    }
}
