import QtQuick 2.13

import utils 1.0

QtObject {
    id: root
    objectName: "hello!"
    property var messageStore
    property EmojiReactions emojiReactionsModel: EmojiReactions { }

    // Not Refactored Yet
//    property var chatsModelInst: chatsModel
    // Not Refactored Yet
//    property var utilsModelInst: utilsModel
    // Not Refactored Yet
//    property var walletModelInst: walletModel
    // Not Refactored Yet
//    property var profileModelInst: profileModel
    property var profileModuleInst: profileModule
    property var activityCenterModuleInst: activityCenterModule
    property var activityCenterList: activityCenterModuleInst.model

    property var communitiesModuleInst: communitiesModule
    property var communitiesList: communitiesModuleInst.model

    property var userProfileInst: userProfile

    property bool isDebugEnabled: profileSectionModule.isDebugEnabled

    property var accounts: walletSectionAccounts.model
    property var currentAccount: walletSectionCurrent
    property var currentCurrency: walletSection.currentCurrency

    property ListModel addToGroupContacts: ListModel {}

    function reCalculateAddToGroupContacts(channel) {
        const contacts = getContactListObject()

        if (channel) {
            contacts.forEach(function (contact) {
                if(channel.contains(contact.pubKey) ||
                        !contact.isContact) {
                    return;
                }
                addToGroupContacts.append(contact)
            })
        }
    }
    property var contactsModuleInst: contactsModule
    property var contactsModuleModel: contactsModuleInst.model || {}
    property var stickersModuleInst: stickersModule

    // Not Refactored Yet
//    property var activeCommunity: chatsModelInst.communities.activeCommunity

    property var contactRequests: contactsModuleModel.contactRequests
    property var addedContacts: contactsModuleModel.addedContacts
    property var allContacts: contactsModuleModel.list

    function sendSticker(channelId, hash, replyTo, pack) {
        stickersModuleInst.send(channelId, hash, replyTo, pack)
    }

    function copyToClipboard(text) {
        // Not Refactored Yet
//        chatsModelInst.copyToClipboard(text);
    }

    function deleteMessage(messageId) {
        // Not Refactored Yet
//        chatsModelInst.messageView.deleteMessage(messageId);
    }

    function getCommunity(communityId) {
        // Not Refactored Yet
//        try {
//            const communityJson = chatsModelInst.communities.list.getCommunityByIdJson(communityId);
//            if (!communityJson) {
//                return null;
//            }

//            let community = JSON.parse(communityJson);
//            if (community) {
//                community.nbMembers = community.members.length;
//            }
//            return community
//        } catch (e) {
//            console.error("Error parsing community", e);
//        }

       return null;
    }

    // Not Refactored Yet
    property var activeCommunityChatsModel: "" //chatsModelInst.communities.activeCommunity.chats

    function createCommunity(communityName, communityDescription, checkedMembership, ensOnlySwitchChecked, communityColor, communityImage, imageCropperModalaX, imageCropperModalaY, imageCropperModalbX, imageCropperModalbY) {
        // Not Refactored Yet
//        chatsModelInst.communities.createCommunity(communityName, communityDescription, checkedMembership, ensOnlySwitchChecked, communityColor, communityImage, imageCropperModalaX, imageCropperModalaY, imageCropperModalbX, imageCropperModalbY);
    }

    function editCommunity(communityId, communityName, communityDescription, checkedMembership, ensOnlySwitchChecked, communityColor, communityImage, imageCropperModalaX, imageCropperModalaY, imageCropperModalbX, imageCropperModalbY) {
        // Not Refactored Yet
//        chatsModelInst.communities.editCommunity(communityId, communityName, communityDescription, checkedMembership, ensOnlySwitchChecked, communityColor, communityImage, imageCropperModalaX, imageCropperModalaY, imageCropperModalbX, imageCropperModalbY);
    }

    function createCommunityCategory(communityId, categoryName, channels) {
        // Not Refactored Yet
//        chatsModelInst.communities.createCommunityCategory(communityId, categoryName, channels);
    }

    function editCommunityCategory(communityId, categoryId, categoryName, channels) {
        // Not Refactored Yet
//        chatsModelInst.communities.editCommunityCategory(communityId, categoryId, categoryName, channels);
    }

    function deleteCommunityCategory(categoryId) {
        // Not Refactored Yet
//        chatsModelInst.communities.deleteCommunityCategory(chatsModelInst.communities.activeCommunity.id, categoryId);
    }

    function leaveCommunity(communityId) {
        // Not Refactored Yet
//        chatsModelInst.communities.leaveCommunity(communityId);
    }

    function setCommunityMuted(communityId, checked) {
        // Not Refactored Yet
//        chatsModelInst.communities.setCommunityMuted(communityId, checked);
    }

    function exportCommunity() {
        // Not Refactored Yet
//        return chatsModelInst.communities.exportCommunity();
    }

    function createCommunityChannel(communityId, channelName, channelDescription, categoryId) {
        // TODO: pass the private value when private channels
        // are implemented
        //privateSwitch.checked)
        // Not Refactored Yet
//        chatsModelInst.createCommunityChannel(communityId, channelName, channelDescription, categoryId);
    }

    function editCommunityChannel(communityId, channelId, channelName, channelDescription, channelCategoryId, popupPosition) {
        // TODO: pass the private value when private channels
        // are implemented
        //privateSwitch.checked)
        // Not Refactored Yet
//        chatsModelInst.editCommunityChannel(communityId, channelId, channelName, channelDescription, channelCategoryId, popupPosition);
    }

    function acceptRequestToJoinCommunity(id) {
        // Not Refactored Yet
//        chatsModelInst.communities.acceptRequestToJoinCommunity(id);
    }

    function declineRequestToJoinCommunity(id) {
        // Not Refactored Yet
//        chatsModelInst.communities.declineRequestToJoinCommunity(id);
    }

    function userNameOrAlias(pk) {
        // Not Refactored Yet
//        return chatsModelInst.userNameOrAlias(pk);
    }

    function generateIdenticon(pk) {
        // Not Refactored Yet
//        return utilsModelInst.generateIdenticon(pk);
    }

    function addContact(pubKey) {
        contactsModuleInst.addContact(pubKey);
    }

    function isContactAdded(address) {
        return contactsModuleModel.isAdded(address);
    }

    function contactRequestReceived(pubkey) {
        return contactsModuleModel.contactRequestReceived(pubkey)
    }

    function isContactBlocked(pubkey) {
        return contactsModuleModel.isContactBlocked(pubkey)
    }

    function isEnsVerified(pubkey) {
        return contactsModuleInst.isEnsVerified(pubkey)
    }

    function alias(pubkey) {
        return contactsModuleInst.alias(pubkey)
    }

    function resolveENSWithUUID(value, uuid) {
        contactsModuleInst.resolveENSWithUUID(value, uuid)
    }
}
