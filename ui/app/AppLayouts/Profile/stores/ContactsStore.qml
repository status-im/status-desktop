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

    function lookupContact(value) {
        root.contactsModule.lookupContact(value)
    }

    function resolveENSWithUUID(value, uuid) {
        root.contactsModule.resolveENSWithUUID(value, uuid)
    }

    function generateAlias(pubKey) {
       return root.globalUtilsInst.generateAlias(pubKey)
    }

    function joinPrivateChat(pubKey) {
        Global.changeAppSectionBySectionType(Constants.appSection.chat)
        let chatCommunitySectionModule = root.mainModuleInst.getChatSectionModule()
        chatCommunitySectionModule.createOneToOneChat(pubKey, "")
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

    function isContactAdded(pubKey) {
        return root.contactsModule.isContactAdded(pubKey)
    }

    function isContactBlocked(pubKey) {
        return root.contactsModule.isContactBlocked(pubKey)
    }

    function removeContact(pubKey) {
        root.contactsModule.removeContact(pubKey)
    }

    function isEnsVerified(pubKey) {
        return root.contactsModule.isEnsVerified(pubKey)
    }

    function userAlias(pubKey) {
        return root.contactsModule.alias(pubKey)
    }

    function changeContactNickname(pubKey, nickname) {
        root.contactsModule.changeContactNickname(pubKey, nickname)
    }
}
