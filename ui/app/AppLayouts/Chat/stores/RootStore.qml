import QtQuick 2.15
import QtQml 2.15

import utils 1.0
import SortFilterProxyModel 0.2
import StatusQ.Core.Utils 0.1 as StatusQUtils
import shared.stores 1.0

QtObject {
    id: root

    property var contactsStore
    property var communityTokensStore

    property var networkConnectionStore

    readonly property PermissionsStore permissionsStore: PermissionsStore {
        activeSectionId: mainModuleInst.activeSection.id
        activeChannelId: root.currentChatContentModule().chatDetails.id
        chatCommunitySectionModuleInst: chatCommunitySectionModule
    }

    property bool openCreateChat: false

    property var contactsModel: root.contactsStore.myContactsModel

    // Important:
    // Each `ChatLayout` has its own chatCommunitySectionModule
    // (on the backend chat and community sections share the same module since they are actually the same)
    property var chatCommunitySectionModule
    readonly property var sectionDetails: _d.sectionDetailsInstantiator.count ? _d.sectionDetailsInstantiator.objectAt(0) : null

    property var communityItemsModel: chatCommunitySectionModule.model

    property var assetsModel: SortFilterProxyModel {
        sourceModel: communitiesModuleInst.tokenList

        proxyRoles: ExpressionRole {
            function tokenIcon(symbol) {
                return Constants.tokenIcon(symbol)
            }
            name: "iconSource"
            expression: !!model.icon ? model.icon : tokenIcon(model.symbol)
        }
    }

    property var collectiblesModel: SortFilterProxyModel {
        sourceModel: communitiesModuleInst.collectiblesModel

        proxyRoles: ExpressionRole {
            function collectibleIcon(icon) {
                return !!icon ? icon : Style.png("tokens/DEFAULT-TOKEN")
            }
            name: "iconSource"
            expression: collectibleIcon(model.icon)
        }
    }

    readonly property bool isUserAllowedToSendMessage: _d.isUserAllowedToSendMessage
    readonly property string chatInputPlaceHolderText: _d.chatInputPlaceHolderText
    readonly property var oneToOneChatContact: _d.oneToOneChatContact
    // Since qml component doesn't follow encaptulation from the backend side, we're introducing
    // a method which will return appropriate chat content module for selected chat/channel
    function currentChatContentModule(){
        // When we decide to have the same struct as it's on the backend we will remove this function.
        // So far this is a way to deal with refactored backend from the current qml structure.
        chatCommunitySectionModule.prepareChatContentModuleForChatId(chatCommunitySectionModule.activeItem.id)
        return chatCommunitySectionModule.getChatContentModule()
    }

    // Contact requests related part
    property var contactRequestsModel: chatCommunitySectionModule.contactRequestsModel

    property bool loadingHistoryMessagesInProgress: chatCommunitySectionModule.loadingHistoryMessagesInProgress

    property var advancedModule: profileSectionModule.advancedModule

    signal importingCommunityStateChanged(string communityId, int state, string errorMsg)

    signal communityInfoAlreadyRequested()

    signal communityAccessRequested(string communityId)

    signal goToMembershipRequestsPage()

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

    function acceptContactRequest(pubKey, contactRequestId) {
        chatCommunitySectionModule.acceptContactRequest(pubKey, contactRequestId)
    }

    function acceptAllContactRequests() {
        chatCommunitySectionModule.acceptAllContactRequests()
    }

    function dismissContactRequest(pubKey, contactRequestId) {
        chatCommunitySectionModule.dismissContactRequest(pubKey, contactRequestId)
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

        let textMsg = globalUtilsInst.plainText(StatusQUtils.Emoji.deparse(text))
        if (textMsg.trim() !== "") {
            textMsg = interpretMessage(textMsg)

            if (event) {
                event.accepted = true
            }
        }

        if (fileUrlsAndSources.length > 0) {
            chatContentModule.inputAreaModule.sendImages(JSON.stringify(fileUrlsAndSources), textMsg.trim(), replyMessageId)
            result = true

        } else {
            if (textMsg.trim() !== "") {
                chatContentModule.inputAreaModule.sendMessage(
                            textMsg,
                            replyMessageId,
                            Utils.isOnlyEmoji(textMsg) ? Constants.messageContentType.emojiType : Constants.messageContentType.messageType,
                            false)

                result = true
            }
        }

        return result
    }

    function openCloseCreateChatView() {
        if (root.openCreateChat) {
             Global.closeCreateChatView()
        } else {
            Global.openCreateChatView()
        }
    }

    property var messageStore: MessageStore { }

    property var emojiReactionsModel

    property var globalUtilsInst: globalUtils

    property var mainModuleInst: mainModule

    property var communitiesModuleInst: communitiesModule
    property var communitiesList: communitiesModuleInst.model

    property var userProfileInst: userProfile

    property string signingPhrase: walletSection.signingPhrase

    property string channelEmoji: chatCommunitySectionModule && chatCommunitySectionModule.emoji ? chatCommunitySectionModule.emoji : ""

    property ListModel addToGroupContacts: ListModel {}

    property var walletSectionSendInst: walletSectionSend

    property bool isWakuV2StoreEnabled: advancedModule ? advancedModule.isWakuV2StoreEnabled : false

    property string communityTags: communitiesModule.tags

    property var stickersModuleInst: stickersModule

    property bool isDebugEnabled: advancedModule ? advancedModule.isDebugEnabled : false

    readonly property int loginType: getLoginType()

    property var stickersStore: StickersStore {
        stickersModule: stickersModuleInst
    }

    function sendSticker(channelId, hash, replyTo, pack, url) {
        stickersModuleInst.send(channelId, hash, replyTo, pack, url)
    }

    // TODO: This seems to be better in Utils.qml
    function copyToClipboard(text) {
        globalUtilsInst.copyToClipboard(text)
    }

    function isCurrentUser(pubkey) {
        return userProfileInst.pubKey === pubkey
    }

    function displayName(name, pubkey) {
        return isCurrentUser(pubkey) ? qsTr("You") : name
    }

    function myPublicKey() {
        return userProfileInst.pubKey
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

    function requestToJoinCommunityWithAuthentication(ensName) {
        chatCommunitySectionModule.requestToJoinCommunityWithAuthentication(ensName)
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

    function requestCommunityInfo(id, importing = false) {
        communitiesModuleInst.requestCommunityInfo(id, importing)
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
            callback: null,
            fetching: true,
            communityId: ""
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
        result.communityId = Utils.getCommunityIdFromShareLink(link)
        if(!result.communityId) return result

        const communityName = getSectionNameById(result.communityId)
        if (!communityName) {
            // Unknown community, fetch the info if possible
            root.requestCommunityInfo(result.communityId)
            return result
        }

        result.title = qsTr("Join the %1 community").arg(communityName)
        result.fetching = false
        result.callback = function () {
            const isUserMemberOfCommunity = isUserMemberOfCommunity(result.communityId)
            if (isUserMemberOfCommunity) {
                setActiveCommunity(result.communityId)
                return
            }

            const userCanJoin = userCanJoin(result.communityId)
            // TODO find what to do when you can't join
            if (userCanJoin) {
                requestToJoinCommunityWithAuthentication(userProfileInst.preferredName)
            }
        }
        return result
    }

    function getLinkDataForStatusLinks(link) {
        if (!Utils.isStatusDeepLink(link)) {
            return
        }

        const result = getLinkTitleAndCb(link)

        return {
            site: Constants.externalStatusLinkWithHttps,
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

    property var accounts: walletSectionSendInst.accounts
    property string currentCurrency: walletSection.currentCurrency
    property CurrenciesStore currencyStore: CurrenciesStore {}
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
        return walletSectionSendInst.estimateGas(from_addr, to, assetSymbol, value === "" ? "0.00" : value, chainId, data)
    }

    function authenticateAndTransfer(from, to, tokenSymbol, amount, uuid, selectedRoutes) {
        walletSectionSendInst.authenticateAndTransfer(from, to, tokenSymbol, amount, uuid, selectedRoutes)
    }

    function suggestedFees(chainId) {
        return JSON.parse(walletSectionSendInst.suggestedFees(chainId))
    }

    function suggestedRoutes(account, amount, token, disabledFromChainIDs, disabledToChainIDs, preferredChainIds, sendType, lockedInAmounts) {
        walletSectionSendInst.suggestedRoutes(account, amount, token, disabledFromChainIDs, disabledToChainIDs, preferredChainIds, sendType, lockedInAmounts)
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

    function getEtherscanLink() {
        return profileSectionModule.ensUsernamesModule.getEtherscanLink()
    }

    function hex2Eth(value) {
        return globalUtilsInst.hex2Eth(value)
    }

    function getLoginType() {
        if(!userProfileInst)
            return Constants.LoginType.Password

        if(userProfileInst.usingBiometricLogin)
            return Constants.LoginType.Biometrics
        else if(userProfileInst.isKeycardUser)
            return Constants.LoginType.Keycard
        else return Constants.LoginType.Password
    }

    readonly property Connections communitiesModuleConnections: Connections {
      target: communitiesModuleInst
      function onImportingCommunityStateChanged(communityId, state, errorMsg) {
          root.importingCommunityStateChanged(communityId, state, errorMsg)
      }

      function onCommunityInfoAlreadyRequested() {
          root.communityInfoAlreadyRequested()
      }

      function onCommunityAccessRequested(communityId) {
          root.communityAccessRequested(communityId)
      }
    }

    readonly property Connections mainModuleInstConnections: Connections {
        target: mainModuleInst
        enabled: !!chatCommunitySectionModule
        function onOpenCommunityMembershipRequestsView(sectionId: string) {
            if(root.getMySectionId() != sectionId)
                return

            root.goToMembershipRequestsPage()
        }
    }

    readonly property QtObject _d: QtObject {
        readonly property var sectionDetailsInstantiator: Instantiator {
            model: SortFilterProxyModel {
                sourceModel: mainModuleInst.sectionsModel
                filters: ValueFilter {
                    roleName: "id"
                    value: chatCommunitySectionModule.getMySectionId()
                }
            }
            delegate: QtObject {
                readonly property string id: model.id
                readonly property int sectionType: model.sectionType
                readonly property string name: model.name
                readonly property bool joined: model.joined
                readonly property bool amIBanned: model.amIBanned
                // add others when needed..
            }
        }

        readonly property string activeChatId: chatCommunitySectionModule && chatCommunitySectionModule.activeItem ? chatCommunitySectionModule.activeItem.id : ""
        readonly property int activeChatType: chatCommunitySectionModule && chatCommunitySectionModule.activeItem ? chatCommunitySectionModule.activeItem.type : -1
        readonly property bool amIMember: chatCommunitySectionModule ? chatCommunitySectionModule.amIMember : false

        property var oneToOneChatContact: undefined
        readonly property string oneToOneChatContactName: !!_d.oneToOneChatContact ? ProfileUtils.displayName(_d.oneToOneChatContact.localNickname, 
                                                                                                    _d.oneToOneChatContact.name, 
                                                                                                    _d.oneToOneChatContact.displayName, 
                                                                                                    _d.oneToOneChatContact.alias) : ""

        //Update oneToOneChatContact when the contact is updated
        readonly property var myContactsModelConnection: Connections {
            target: root.contactsStore.myContactsModel ?? null
            enabled: _d.activeChatType === Constants.chatType.oneToOne

            function onItemChanged(pubKey) {
                if (pubKey === _d.activeChatId) {
                    _d.oneToOneChatContact = Utils.getContactDetailsAsJson(pubKey, false)
                }
            }
        }

        readonly property var receivedContactsReqModelConnection: Connections {
            target: root.contactsStore.receivedContactRequestsModel ?? null
            enabled: _d.activeChatType === Constants.chatType.oneToOne

            function onItemChanged(pubKey) {
                if (pubKey === _d.activeChatId) {
                    _d.oneToOneChatContact = Utils.getContactDetailsAsJson(pubKey, false)
                }
            }
        }

        readonly property var sentContactReqModelConnection: Connections {
            target: root.contactsStore.sentContactRequestsModel ?? null
            enabled: _d.activeChatType === Constants.chatType.oneToOne

            function onItemChanged(pubKey) {
                if (pubKey === _d.activeChatId) {
                    _d.oneToOneChatContact = Utils.getContactDetailsAsJson(pubKey, false)
                }
            }
        }

        readonly property bool isUserAllowedToSendMessage: {
            if (_d.activeChatType === Constants.chatType.oneToOne && _d.oneToOneChatContact) {
                return _d.oneToOneChatContact.contactRequestState === Constants.ContactRequestState.Mutual
            }
            else if(_d.activeChatType === Constants.chatType.privateGroupChat) {
                return _d.amIMember
            }

            return true
        }

        readonly property string chatInputPlaceHolderText: {
            if(!_d.isUserAllowedToSendMessage && _d.activeChatType === Constants.chatType.privateGroupChat) {
                return qsTr("You need to be a member of this group to send messages")
            } else if(!_d.isUserAllowedToSendMessage && _d.activeChatType === Constants.chatType.oneToOne) {
                return qsTr("Add %1 as a contact to send a message").arg(_d.oneToOneChatContactName)
            }

            return qsTr("Message")
        }

        //Update oneToOneChatContact when activeChat id changes
        Binding on oneToOneChatContact {
            when: _d.activeChatId && _d.activeChatType === Constants.chatType.oneToOne 
            value: Utils.getContactDetailsAsJson(_d.activeChatId, false)
            restoreMode: Binding.RestoreBindingOrValue
        }
    }
}
