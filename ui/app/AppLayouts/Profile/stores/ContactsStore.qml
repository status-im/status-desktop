import QtQuick 2.13
import utils 1.0

QtObject {
    id: root

    property var contactsModule

    property var globalUtilsInst: globalUtils
    property var mainModuleInst: mainModule

    property string myPublicKey: userProfile.pubKey
    property var myContactsModel: contactsModule.myContactsModel
    property var blockedContactsModel: contactsModule.blockedContactsModel

    // TODO move contact requests back to the contacts module since we need them in the Profile 
    // also, having them in the chat section creates some waste, since no community has it
    property var chatSectionModule: mainModule.getChatSectionModule()
    property var contactRequestsModel: chatSectionModule.contactRequestsModel

    function resolveENS(value) {
        root.mainModuleInst.resolveENS(value, "")
    }

    function generateAlias(pubKey) {
       return root.globalUtilsInst.generateAlias(pubKey)
    }

    function joinPrivateChat(pubKey) {
        Global.changeAppSectionBySectionType(Constants.appSection.chat)
        let chatCommunitySectionModule = root.mainModuleInst.getChatSectionModule()
        chatCommunitySectionModule.createOneToOneChat("", pubKey, "")
    }

    function addContact(pubKey) {
        root.contactsModule.addContact(pubKey)
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
    
    function acceptContactRequest(pubKey) {
        chatSectionModule.acceptContactRequest(pubKey)
    }

    function acceptAllContactRequests() {
        chatSectionModule.acceptAllContactRequests()
    }

    function rejectContactRequest(pubKey) {
        chatSectionModule.rejectContactRequest(pubKey)
    }

    function rejectAllContactRequests() {
        chatSectionModule.rejectAllContactRequests()
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
