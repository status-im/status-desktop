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

    property var globalUtilsInst: globalUtils

    property var mainModuleInst: mainModule
    property var activityCenterModuleInst: activityCenterModule
    property var activityCenterList: activityCenterModuleInst.model

    property var communitiesModuleInst: communitiesModule
    property var communitiesList: communitiesModuleInst.model

    property var userProfileInst: userProfile

    property var accounts: walletSectionAccounts.model
    property var currentAccount: walletSectionCurrent

    property string currentCurrency: walletSection.currentCurrency
    property string signingPhrase: walletSection.signingPhrase

    property string gasPrice: profileSectionModule.ensUsernamesModule.gasPrice

    property ListModel addToGroupContacts: ListModel {}

    property var walletSectionTransactionsInst: walletSectionTransactions

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

    function importCommunity(communityKey) {
        root.communitiesModuleInst.importCommunity(communityKey);
    }

    function createCommunityCategory(categoryName, channels) {
        chatCommunitySectionModule.createCommunityCategory(categoryName, channels)
    }

    function editCommunityCategory(categoryId, categoryName, channels) {
        chatCommunitySectionModule.editCommunityCategory(categoryId, categoryName, channels);
    }

    function deleteCommunityCategory(categoryId) {
        chatCommunitySectionModule.deleteCommunityCategory(categoryId);
    }

    function prepareEditCategoryModel(categoryId) {
        chatCommunitySectionModule.prepareEditCategoryModel(categoryId);
    }

    function leaveCommunity() {
        chatCommunitySectionModule.leaveCommunity();
    }

    function createCommunityChannel(channelName, channelDescription, categoryId) {
        chatCommunitySectionModule.createCommunityChannel(channelName, channelDescription, categoryId);
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

    function reorderCommunityCategories(categoryId, to) {
        chatCommunitySectionModule.reorderCommunityCategories(categoryId, to)
    }

    function reorderCommunityChat(categoryId, chatId, to) {
        chatCommunitySectionModule.reorderCommunityChat(categoryId, chatId, to)
    }

    function joinCommunity(id) {
        return communitiesModuleInst.joinCommunity(id)
    }

    function requestToJoinCommunity(id, ensName) {
        return communitiesModuleInst.requestToJoinCommunity(id, ensName)
    }

    function userCanJoin(id) {
        return communitiesModuleInst.userCanJoin(id)
    }

    function isUserMemberOfCommunity(id) {
        return communitiesModuleInst.isUserMemberOfCommunity(id)
    }

    function isCommunityRequestPending(id) {
        return communitiesModuleInst.isCommunityRequestPending(id)
    }

    function getSectionNameById(id) {
        return communitiesList.getSectionNameById(id)
    }

    function getSectionByIdJson(id) {
        return communitiesList.getSectionByIdJson(id)
    }

    function getLinkTitleAndCb(link) {
        const result = {
            title: "Status",
            callback: null
        }

        // Link to send a direct message
        let index = link.indexOf("/u/")
        if (index === -1) {
            // Try /p/ as well
            index = link.indexOf("/p/")
        }
        if (index > -1) {
            const pk = link.substring(index + 3)
            //% "Start a 1-on-1 chat with %1"
            result.title = qsTrId("start-a-1-on-1-chat-with--1")
                            .arg(isChatKey(pk) ? globalUtils.generateAlias(pk) : ("@" + removeStatusEns(pk)))
            result.callback = function () {
                if (isChatKey(pk)) {
                    chatCommunitySectionModule.createOneToOneChat(pk, "")
                } else {
                // Not Refactored Yet
//                    chatsModel.channelView.joinWithENS(pk);
                }
            }
            return result
        }

        // Community
        index = link.lastIndexOf("/c/")
        if (index > -1) {
            const communityId = link.substring(index + 3)

            const communityName = getSectionNameById(communityId)

            if (!communityName) {
                // Unknown community, fetch the info if possible
                communitiesModuleInst.requestCommunityInfo(communityId)
                result.communityId = communityId
                result.fetching = true
                return result
            }

            //% "Join the %1 community"
            result.title = qsTrId("join-the--1-community").arg(communityName)
            result.communityId = communityId
            result.callback = function () {
                const isUserMemberOfCommunity = isUserMemberOfCommunity(communityId)
                if (isUserMemberOfCommunity) {
                    setActiveCommunity(communityId)
                    return
                }

                const userCanJoin = userCanJoin(communityId)
                // TODO find what to do when you can't join
                if (userCanJoin) {
                    joinCommunity(communityId, true)
                }
            }
            return result
        }

        // Group chat
        index = link.lastIndexOf("/g/")
        if (index > -1) {
            let indexAdminPk = link.lastIndexOf("a=")
            let indexChatName = link.lastIndexOf("a1=")
            let indexChatId = link.lastIndexOf("a2=")
            const pubKey = link.substring(indexAdminPk + 2, indexChatName - 1)
            const chatName = link.substring(indexChatName + 3, indexChatId - 1)
            const chatId = link.substring(indexChatId + 3, link.length)
            //% "Join the %1 group chat"
            result.title = qsTrId("join-the--1-group-chat").arg(chatName)
            result.callback = function () {
                // Not Refactored Yet
//                chatsModel.groups.joinGroupChatFromInvitation(chatName, chatId, pubKey);
            }

            return result
        }

        // Not Refactored Yet (when we get to this we will most likely remove it, since other approach will be used)
//        // Public chat
//        // This needs to be the last check because it is as VERY loose check
//        index = link.lastIndexOf("/")
//        if (index > -1) {
//            const chatId = link.substring(index + 1)
//            //% "Join the %1 public channel"
//            result.title = qsTrId("join-the--1-public-channel").arg(chatId)
//            result.callback = function () {
//                chatsModel.channelView.joinPublicChat(chatId);
//            }
//            return result
//        }

        return result
    }

    function getLinkDataForStatusLinks(link) {
        if (!link.includes(Constants.deepLinkPrefix) && !link.includes(Constants.joinStatusLink)) {
            return
        }

        const result = getLinkTitleAndCb(link)

        return {
            site: "https://join.status.im",
            title: result.title,
            communityId: result.communityId,
            fetching: result.fetching,
            thumbnailUrl: Style.png("status"),
            contentType: "",
            height: 0,
            width: 0,
            callback: result.callback
        }
    }

    function getPubkey() {
        return userProfile.getPubKey()
    }

    function getFiatValue(balance, cryptoSymbo, fiatSymbol) {
        return profileSectionModule.ensUsernamesModule.getFiatValue(balance, cryptoSymbo, fiatSymbol)
    }

    function acceptRequestTransaction(transactionHash, messageId, signature) {
        return currentChatContentModule().inputAreaModule.acceptRequestTransaction(transactionHash, messageId, signature)
    }

    function acceptAddressRequest(messageId, address) {
        currentChatContentModule().inputAreaModule.acceptAddressRequest(messageId, address)
    }

    function declineAddressRequest(messageId) {
        currentChatContentModule().inputAreaModule.declineAddressRequest(messageId)
    }

    function declineRequest(messageId) {
        currentChatContentModule().inputAreaModule.declineRequest(messageId)
    }

    function getGasEthValue(gweiValue, gasLimit) {
        return profileSectionModule.ensUsernamesModule.getGasEthValue(gweiValue, gasLimit)
    }

    function estimateGas(from_addr, to, assetAddress, value, data) {
        return walletSectionTransactions.estimateGas(from_addr, to, assetAddress, value, data)
    }

    function transferEth(from, to, amount, gasLimit, gasPrice, tipLimit, overallLimit, password, uuid) {
        return walletSectionTransactions.transferEth(from, to, amount, gasLimit, gasPrice, tipLimit,
                                                     overallLimit, password, uuid);
    }

    function transferTokens(from, to, address, amount, gasLimit, gasPrice, tipLimit, overallLimit, password, uuid) {
        return walletSectionTransactions.transferTokens(from, to, address, amount, gasLimit,
                                                        gasPrice, tipLimit, overallLimit, password, uuid);
    }

    function getAccountNameByAddress(address) {
        return walletSectionAccounts.getAccountNameByAddress(address)
    }

    function getAccountIconColorByAddress(address) {
        return walletSectionAccounts.getAccountIconColorByAddress(address)
    }

    function getAccountAssetsByAddress(address) {
        walletSectionAccounts.setAddressForAssets(address)
        return walletSectionAccounts.getAccountAssetsByAddress()
    }

    function fetchGasPrice() {
        profileSectionModule.ensUsernamesModule.fetchGasPrice()
    }
}
