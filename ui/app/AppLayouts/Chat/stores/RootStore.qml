import QtQuick 2.13

import utils 1.0

QtObject {
    id: root

    // Important:
    // Each `ChatLayout` has its own chatCommunitySectionModule
    // (on the backend chat and community sections share the same module since they are actually the same)
    property var chatCommunitySectionModule
    // Since qml component doesn't follow encaptulation from the backend side, we're introducing
    // a method which will return appropriate chat content module for selected chat/channel
    function currentChatContentModule(){
        // When we decide to have the same struct as it's on the backend we will remove this function.
        // So far this is a way to deal with refactord backend from the current qml structure.
        if(chatCommunitySectionModule.activeItem.isSubItemActive)
            chatCommunitySectionModule.prepareChatContentModuleForChatId(chatCommunitySectionModule.activeItem.activeSubItem.id)
        else
            chatCommunitySectionModule.prepareChatContentModuleForChatId(chatCommunitySectionModule.activeItem.id)

        return chatCommunitySectionModule.getChatContentModule()
    }

    // Contact requests related part
    property var contactRequestsModel: chatCommunitySectionModule.contactRequestsModel

    function setActiveCommunity(communityId) {
        mainModule.setActiveSectionById(communityId);
    }

    function setObservedCommunity(communityId) {
        communitiesModuleInst.setObservedCommunity(communityId);
    }

    function acceptContactRequest(pubKey) {
        chatCommunitySectionModule.acceptContactRequest(pubKey)
    }

    function acceptAllContactRequests() {
        chatCommunitySectionModule.acceptAllContactRequests()
    }

    function rejectContactRequest(pubKey) {
        chatCommunitySectionModule.rejectContactRequest(pubKey)
    }

    function rejectAllContactRequests() {
        chatCommunitySectionModule.rejectAllContactRequests()
    }

    function blockContact(pubKey) {
        chatCommunitySectionModule.blockContact(pubKey)
    }


    property var messageStore: MessageStore { }

    property var emojiReactionsModel

    // Not Refactored Yet
//    property var chatsModelInst: chatsModel
    // Not Refactored Yet
//    property var utilsModelInst: utilsModel
    // Not Refactored Yet
//    property var walletModelInst: walletModel
    // Not Refactored Yet
//    property var profileModelInst: profileModel

    property var globalUtilsInst: globalUtils

    property var mainModuleInst: mainModule
    property var activityCenterModuleInst: activityCenterModule
    property var activityCenterList: activityCenterModuleInst.model

    property var communitiesModuleInst: communitiesModule
    property var communitiesList: communitiesModuleInst.model

    property var userProfileInst: userProfile

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

    property var stickersModuleInst: stickersModule

    // Not Refactored Yet
//    property var activeCommunity: chatsModelInst.communities.activeCommunity

    function sendSticker(channelId, hash, replyTo, pack) {
        stickersModuleInst.send(channelId, hash, replyTo, pack)
    }

    function copyToClipboard(text) {
        globalUtilsInst.copyToClipboard(text)
    }

    function copyImageToClipboard(content) {
        globalUtilsInst.copyImageToClipboard(content)
    }

    function downloadImage(content, path) {
        globalUtilsInst.downloadImage(content, path)
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
        communitiesModuleInst.createCommunity(communityName, communityDescription, checkedMembership, ensOnlySwitchChecked, communityColor, communityImage, imageCropperModalaX, imageCropperModalaY, imageCropperModalbX, imageCropperModalbY);
    }

    function createCommunityCategory(communityId, categoryName, channels) {
        // Not Refactored Yet
//        chatsModelInst.communities.createCommunityCategory(communityId, categoryName, channels);
    }

    function editCommunityCategory(communityId, categoryId, categoryName, channels) {
        communitiesModuleInst.editCommunityCategory(communityId, categoryId, categoryName, channels);
    }

    function deleteCommunityCategory(categoryId) {
        // Not Refactored Yet
//        chatsModelInst.communities.deleteCommunityCategory(chatsModelInst.communities.activeCommunity.id, categoryId);
    }

    function leaveCommunity() {
        chatCommunitySectionModule.leaveCommunity();
    }

    function createCommunityChannel(channelName, channelDescription) {
        chatCommunitySectionModule.createCommunityChannel(channelName, channelDescription);
    }

    function editCommunityChannel(communityId, channelId, channelName, channelDescription, channelCategoryId, popupPosition) {
        // TODO: pass the private value when private channels
        // are implemented
        //privateSwitch.checked)
        // Not Refactored Yet
//        chatsModelInst.editCommunityChannel(communityId, channelId, channelName, channelDescription, channelCategoryId, popupPosition);
    }

    function acceptRequestToJoinCommunity(requestId) {
        chatCommunitySectionModule.acceptRequestToJoinCommunity(requestId)
    }

    function declineRequestToJoinCommunity(requestId) {
        chatCommunitySectionModule.declineRequestToJoinCommunity(requestId)
    }

    function userNameOrAlias(pk) {
        // Not Refactored Yet
//        return chatsModelInst.userNameOrAlias(pk);
    }

    function generateAlias(pk) {
        return globalUtils.generateAlias(pk);
    }

    function generateIdenticon(pk) {
        return globalUtils.generateIdenticon(pk);
    }

    function plainText(text) {
        return globalUtils.plainText(text)
    }

    function removeCommunityChat(chatId) {
        chatCommunitySectionModule.removeCommunityChat(chatId)
    }
}
