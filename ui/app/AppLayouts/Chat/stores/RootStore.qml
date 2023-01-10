import QtQuick 2.13

import utils 1.0
import StatusQ.Core.Utils 0.1 as StatusQUtils
import shared.stores 1.0

QtObject {
    id: root

    property string locale: localAppSettings.language

    property var contactsStore

    property bool openCreateChat: false
    property string createChatInitMessage: ""
    property var createChatFileUrls: []
    property bool createChatStartSendTransactionProcess: false
    property bool createChatStartReceiveTransactionProcess: false
    property string createChatStickerHashId: ""
    property string createChatStickerPackId: ""
    property string createChatStickerUrl: ""

    property var membershipRequestPopup
    property var contactsModel: root.contactsStore.myContactsModel

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

    property var loadingHistoryMessagesInProgress: chatCommunitySectionModule.loadingHistoryMessagesInProgress

    property var advancedModule: profileSectionModule.advancedModule

    signal importingCommunityStateChanged(string communityId, int state, string errorMsg)

    function setActiveCommunity(communityId) {
        mainModule.setActiveSectionById(communityId);
    }

    function activateStatusDeepLink(link) {
        mainModuleInst.activateStatusDeepLink(link)
    }

    function setObservedCommunity(communityId) {
        communitiesModuleInst.setObservedCommunity(communityId);
    }

    function getMySectionId() {
        return chatCommunitySectionModule.getMySectionId()
    }

    function amIChatAdmin() {
        return currentChatContentModule().amIChatAdmin()
    }

    function acceptContactRequest(pubKey) {
        chatCommunitySectionModule.acceptContactRequest(pubKey)
    }

    function acceptAllContactRequests() {
        chatCommunitySectionModule.acceptAllContactRequests()
    }

    function dismissContactRequest(pubKey) {
        chatCommunitySectionModule.dismissContactRequest(pubKey)
    }

    function dismissAllContactRequests() {
        chatCommunitySectionModule.dismissAllContactRequests()
    }

    function blockContact(pubKey) {
        chatCommunitySectionModule.blockContact(pubKey)
    }

    function interpretMessage(msg) {
        if (msg.startsWith("/shrug")) {
            return  msg.replace("/shrug", "") + " ¯\\\\\\_(ツ)\\_/¯"
        }
        if (msg.startsWith("/tableflip")) {
            return msg.replace("/tableflip", "") + " (╯°□°）╯︵ ┻━┻"
        }

        return msg
    }

    function sendMessage(chatId, event, text, replyMessageId, fileUrlsAndSources) {
        chatCommunitySectionModule.prepareChatContentModuleForChatId(chatId)
        const chatContentModule = chatCommunitySectionModule.getChatContentModule()
        var result = false

        if (fileUrlsAndSources.length > 0){
            chatContentModule.inputAreaModule.sendImages(JSON.stringify(fileUrlsAndSources))
            result = true
        }

        let msg = globalUtils.plainText(StatusQUtils.Emoji.deparse(text))
        if (msg.trim() !== "") {
            msg = interpretMessage(msg)

            chatContentModule.inputAreaModule.sendMessage(
                        msg,
                        replyMessageId,
                        Utils.isOnlyEmoji(msg) ? Constants.messageContentType.emojiType : Constants.messageContentType.messageType,
                        false)

            if (event)
                event.accepted = true

            result = true
        }
        return result
    }


    property var messageStore: MessageStore { }

    property var emojiReactionsModel

    property var globalUtilsInst: globalUtils

    property var mainModuleInst: mainModule

    property var communitiesModuleInst: communitiesModule
    property var communitiesList: communitiesModuleInst.model
    property bool communityPermissionsEnabled: localAccountSensitiveSettings.isCommunityPermissionsEnabled

    property var userProfileInst: userProfile

    property string signingPhrase: walletSection.signingPhrase

    property string channelEmoji: chatCommunitySectionModule && chatCommunitySectionModule.emoji ? chatCommunitySectionModule.emoji : ""

    property ListModel addToGroupContacts: ListModel {}

    property var walletSectionTransactionsInst: walletSectionTransactions

    property string communityTags: communitiesModule.tags

    property var stickersModuleInst: stickersModule

    property var stickersStore: StickersStore {
        stickersModule: stickersModuleInst
    }

    function sendSticker(channelId, hash, replyTo, pack, url) {
        stickersModuleInst.send(channelId, hash, replyTo, pack, url)
    }

    function copyToClipboard(text) {
        globalUtilsInst.copyToClipboard(text)
    }

    function copyImageToClipboardByUrl(content) {
        globalUtilsInst.copyImageToClipboardByUrl(content)
    }

    function downloadImageByUrl(url, path) {
        globalUtilsInst.downloadImageByUrl(url, path)
    }

    function isCurrentUser(pubkey) {
        return userProfileInst.pubKey === pubkey
    }

    function displayName(name, pubkey) {
        return isCurrentUser(pubkey) ? qsTr("You") : name
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

    function createCommunity(args = {
                                name: "",
                                description: "",
                                introMessage: "",
                                outroMessage: "",
                                color: "",
                                tags: "",
                                image: {
                                    src: "",
                                    AX: 0,
                                    AY: 0,
                                    BX: 0,
                                    BY: 0,
                                },
                                options: {
                                    historyArchiveSupportEnabled: false,
                                    checkedMembership: false,
                                    pinMessagesAllowedForMembers: false,
                                    encrypted: false
                                },
                                bannerJsonStr: ""
                             }) {
        return communitiesModuleInst.createCommunity(
                    args.name, args.description, args.introMessage, args.outroMessage,
                    args.options.checkedMembership, args.color, args.tags,
                    args.image.src, args.image.AX, args.image.AY, args.image.BX, args.image.BY,
                    args.options.historyArchiveSupportEnabled, args.options.pinMessagesAllowedForMembers,
                    args.bannerJsonStr, args.options.encrypted);
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

    function removeUserFromCommunity(pubKey) {
        chatCommunitySectionModule.removeUserFromCommunity(pubKey);
    }

    function banUserFromCommunity(pubKey) {
        chatCommunitySectionModule.banUserFromCommunity(pubKey);
    }

    function unbanUserFromCommunity(pubKey) {
        chatCommunitySectionModule.unbanUserFromCommunity(pubKey);
    }

    function createCommunityChannel(channelName, channelDescription, channelEmoji, channelColor,
            categoryId) {
        chatCommunitySectionModule.createCommunityChannel(channelName, channelDescription,
            channelEmoji, channelColor, categoryId);
    }

    function editCommunityChannel(chatId, newName, newDescription, newEmoji, newColor,
            newCategory, channelPosition) {
        chatCommunitySectionModule.editCommunityChannel(
                    chatId,
                    newName,
                    newDescription,
                    newEmoji,
                    newColor,
                    newCategory,
                    channelPosition
                )
    }

    function acceptRequestToJoinCommunity(requestId, communityId) {
        chatCommunitySectionModule.acceptRequestToJoinCommunity(requestId, communityId)
    }

    function declineRequestToJoinCommunity(requestId, communityId) {
        chatCommunitySectionModule.declineRequestToJoinCommunity(requestId, communityId)
    }

    function userNameOrAlias(pk) {
        // Not Refactored Yet
//        return chatsModelInst.userNameOrAlias(pk);
    }

    function generateAlias(pk) {
        return globalUtilsInst.generateAlias(pk);
    }

    function plainText(text) {
        return globalUtilsInst.plainText(text)
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

    function spectateCommunity(id, ensName) {
        return communitiesModuleInst.spectateCommunity(id, ensName)
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

    function cancelPendingRequest(id: string) {
        communitiesModuleInst.cancelRequestToJoinCommunity(id)
    }

    function getSectionNameById(id) {
        return communitiesList.getSectionNameById(id)
    }

    function getSectionByIdJson(id) {
        return communitiesList.getSectionByIdJson(id)
    }

    function requestCommunityInfo(id) {
        communitiesModuleInst.requestCommunityInfo(id)
    }

    function getCommunityDetailsAsJson(id) {
        const jsonObj = communitiesModuleInst.getCommunityDetails(id)
        try {
            return JSON.parse(jsonObj)
        }
        catch (e) {
            console.warn("error parsing community by id: ", id, " error: ", e.message)
            return {}
        }
    }

    function getChatDetails(id) {
        const jsonObj = activityCenterModule.getChatDetailsAsJson(id)
        try {
            return JSON.parse(jsonObj)
        }
        catch (e) {
            console.warn("error parsing chat by id: ", id, " error: ", e.message)
            return {}
        }
    }

    function getLinkTitleAndCb(link) {
        const result = {
            title: "Status",
            callback: null
        }

        // User profile
        // There is invitation bubble only for /c/ link for now
        /*let index = link.indexOf("/u/")
        if (index > -1) {
            //const pk = link.substring(index + 3)
            result.title = qsTr("Display user profile")
            result.callback = function () {
                mainModuleInst.activateStatusDeepLink(link)
            }
            return result
        }*/

        // Community
        const communityId = Utils.getCommunityIdFromShareLink(link)
        if (communityId !== "") {
            const communityName = getSectionNameById(communityId)

            if (!communityName) {
                // Unknown community, fetch the info if possible
                root.requestCommunityInfo(communityId)
                result.communityId = communityId
                result.fetching = true
                return result
            }

            result.title = qsTr("Join the %1 community").arg(communityName)
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
                    requestToJoinCommunity(communityId, userProfileInst.preferredName)
                }
            }
            return result
        }


        return result
    }

    function getLinkDataForStatusLinks(link) {
        if (!Utils.isStatusDeepLink(link)) {
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

    // Needed for TX in chat for stickers and via contact

    property var accounts: walletSectionAccounts.model
    property var currentAccount: walletSectionCurrent
    property string currentCurrency: walletSection.currentCurrency
    property CurrenciesStore currencyStore: CurrenciesStore { }
    property var allNetworks: networksModule.all
    property var savedAddressesModel: walletSectionSavedAddresses.model

    property var disabledChainIdsFromList: []
    property var disabledChainIdsToList: []

    function addRemoveDisabledFromChain(chainID, isDisabled) {
        if(isDisabled) {
            disabledChainIdsFromList.push(chainID)
        }
        else {
            for(var i = 0; i < disabledChainIdsFromList.length;i++) {
                if(disabledChainIdsFromList[i] === chainID) {
                    disabledChainIdsFromList.splice(i, 1)
                }
            }
        }
    }

    function addRemoveDisabledToChain(chainID, isDisabled) {
        if(isDisabled) {
            disabledChainIdsToList.push(chainID)
        }
        else {
            for(var i = 0; i < disabledChainIdsToList.length;i++) {
                if(disabledChainIdsToList[i] === chainID) {
                    disabledChainIdsToList.splice(i, 1)
                }
            }
        }
    }

    function getFiatValue(balance, cryptoSymbol, fiatSymbol) {
        return profileSectionModule.ensUsernamesModule.getFiatValue(balance, cryptoSymbol, fiatSymbol)
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

    function estimateGas(from_addr, to, assetSymbol, value, chainId, data) {
        return walletSectionTransactions.estimateGas(from_addr, to, assetSymbol, value === "" ? "0.00" : value, chainId, data)
    }

    function authenticateAndTransfer(from, to, tokenSymbol, amount, uuid, selectedRoutes) {
        walletSectionTransactions.authenticateAndTransfer(from, to, tokenSymbol, amount, uuid, selectedRoutes)
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

    function suggestedFees(chainId) {
        return JSON.parse(walletSectionTransactions.suggestedFees(chainId))
    }

    function suggestedRoutes(account, amount, token, disabledFromChainIDs, disabledToChainIDs, preferredChainIds, sendType, lockedInAmounts) {
        walletSectionTransactions.suggestedRoutes(account, amount, token, disabledFromChainIDs, disabledToChainIDs, preferredChainIds, sendType, lockedInAmounts)
    }

    function resolveENS(value) {
        mainModuleInst.resolveENS(value, "")
    }

    function getWei2Eth(wei) {
        return globalUtilsInst.wei2Eth(wei,18)
    }

    function getEth2Wei(eth) {
         return globalUtilsInst.eth2Wei(eth, 18)
    }

    function switchAccount(newIndex) {
        if(Constants.isCppApp)
            walletSectionAccounts.switchAccount(newIndex)
        else
            walletSection.switchAccount(newIndex)
    }

    function getEtherscanLink() {
        return profileSectionModule.ensUsernamesModule.getEtherscanLink()
    }

    function hex2Eth(value) {
        return globalUtilsInst.hex2Eth(value)
    }

    readonly property Connections communitiesModuleConnections: Connections {
      target: communitiesModuleInst
      function onImportingCommunityStateChanged(communityId, state, errorMsg) {
          root.importingCommunityStateChanged(communityId, state, errorMsg)
      }
    }
}
