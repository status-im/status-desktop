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
    property var receivedButRejectedContactRequestsModel: contactsModule.receivedButRejectedContactRequestsModel
    property var sentButRejectedContactRequestsModel: contactsModule.sentButRejectedContactRequestsModel

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

    function joinPrivateChat(pubKey) {
        Global.changeAppSectionBySectionType(Constants.appSection.chat)
        root.contactsModule.addContact(pubKey)
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
        root.contactsModule.addContact(pubKey)
    }

    function rejectContactRequest(pubKey) {
        root.contactsModule.rejectContactRequest(pubKey)
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
}
