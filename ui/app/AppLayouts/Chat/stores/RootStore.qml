import QtQuick 2.15
import QtQml 2.15

import QtModelsToolkit 1.0
import SortFilterProxyModel 0.2

import StatusQ 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Core.Theme 0.1

import AppLayouts.Profile.stores 1.0
import AppLayouts.Wallet.stores 1.0 as WalletStore
import shared.stores 1.0

import utils 1.0

QtObject {
    id: root

    // Backend Entry Point:
    // Important:
    // Each `ChatLayout` has its own chatCommunitySectionModule
    // (on the backend chat and community sections share the same module since they are actually the same)
    property var chatCommunitySectionModule

    readonly property var activeChatContentModule: root.currentChatContentModule()

    property ContactsStore contactsStore
    property CommunityTokensStore communityTokensStore
    property WalletStore.RootStore walletStore
    property CurrenciesStore currencyStore
    property NetworkConnectionStore networkConnectionStore

    readonly property PermissionsStore permissionsStore: PermissionsStore {
        activeSectionId: mainModuleInst.activeSection.id
        activeChannelId: root.currentChatContentModule().chatDetails.id
        chatCommunitySectionModuleInst: chatCommunitySectionModule
    }

    // Unique instance for all the chat / channel related low-level UI components
    readonly property UsersStore usersStore: UsersStore {
        property var chatDetails: !!root.activeChatContentModule ? root.activeChatContentModule.chatDetails : null

        isFullCommunityMembers: chatDetails.belongsToCommunity && !chatDetails.requiresPermissions
        usersModule: !!root.activeChatContentModule ? root.activeChatContentModule.usersModule : null
        chatCommunitySectionModule: root.chatCommunitySectionModule
    }

    property bool openCreateChat: false

    readonly property var sectionDetails: d.sectionDetailsInstantiator.count ? d.sectionDetailsInstantiator.objectAt(0) : null

    property var communityItemsModel: chatCommunitySectionModule.model

    property var assetsModel: SortFilterProxyModel {
        sourceModel: communitiesModuleInst.tokenList

        proxyRoles: FastExpressionRole {
            function tokenIcon(symbol) {
                return Constants.tokenIcon(symbol)
            }
            name: "iconSource"
            expression: !!model.icon ? model.icon : tokenIcon(model.symbol)
            expectedRoles: ["icon", "symbol"]
        }
    }

    readonly property var communityCollectiblesModelWithCollectionRoles: SortFilterProxyModel {
        sourceModel: communitiesModuleInst.collectiblesModel

        proxyRoles: [
            FastExpressionRole {
                function collectibleIcon(icon) {
                    return !!icon ? icon : Theme.png("tokens/DEFAULT-TOKEN")
                }
                name: "iconSource"
                expression: collectibleIcon(model.icon)
                expectedRoles: ["icon"]
            },
            FastExpressionRole {
                name: "collectionUid"
                expression: model.key
                expectedRoles: ["key"]
            },
            FastExpressionRole {
                function collectibleIcon(icon) {
                    return !!icon ? icon : Theme.png("tokens/DEFAULT-TOKEN")
                }
                name: "collectionImageUrl"
                expression: collectibleIcon(model.icon)
                expectedRoles: ["icon"]
            }
        ]
    }

    readonly property var walletCollectiblesModel: ObjectProxyModel {

        sourceModel: WalletStore.RootStore.collectiblesStore.allCollectiblesModel

        delegate: QtObject {
            readonly property string key: model.symbol ?? ""
            readonly property string shortName: model.collectionName ? model.collectionName : model.collectionUid ? model.collectionUid : ""
            readonly property string symbol: shortName
            readonly property string name: shortName
            readonly property int category: 1 // Own
        }

        exposedRoles: ["key", "symbol", "shortName", "name", "category"]
        expectedRoles: ["symbol", "collectionName", "collectionUid"]
    }

    readonly property var walletCollectiblesGroupingModel: GroupingModel {
        sourceModel: walletCollectiblesModel

        groupingRoleName: "collectionUid"
        submodelRoleName: "subnames"
    }

    readonly property var walletNonCommunityCollectiblesModel: SortFilterProxyModel {
        sourceModel: walletCollectiblesGroupingModel

        filters: ValueFilter {
            roleName: "communityId"
            value: ""
        }
    }

    property var walletCollectiblesWithIconSourceModel: RolesRenamingModel {
        sourceModel: walletNonCommunityCollectiblesModel

        mapping: RoleRename {
            from: "mediaUrl"
            to: "iconSource"
        }
    }

    property var collectiblesModel: ConcatModel {
        sources: [
            SourceModel {
                model: communityCollectiblesModelWithCollectionRoles
            },
            SourceModel {
                model: walletCollectiblesWithIconSourceModel
            }
        ]
    }

    function prepareTokenModelForCommunity(publicKey) {
        root.communitiesModuleInst.prepareTokenModelForCommunity(publicKey)
    }

    function prepareTokenModelForCommunityChat(publicKey, chatId) {
        root.communitiesModuleInst.prepareTokenModelForCommunityChat(publicKey, chatId)
    }

    readonly property bool allChannelsAreHiddenBecauseNotPermitted: root.chatCommunitySectionModule.allChannelsAreHiddenBecauseNotPermitted &&
                                                                    !root.chatCommunitySectionModule.requiresTokenPermissionToJoin

    readonly property int communityMemberReevaluationStatus: root.chatCommunitySectionModule && root.chatCommunitySectionModule.communityMemberReevaluationStatus

    readonly property bool requirementsCheckPending: root.communitiesModuleInst.requirementsCheckPending

    readonly property var permissionsModel: !!root.communitiesModuleInst.spectatedCommunityPermissionModel ?
                                     root.communitiesModuleInst.spectatedCommunityPermissionModel : null

    readonly property string overviewChartData: chatCommunitySectionModule.overviewChartData

    readonly property bool isUserAllowedToSendMessage: d.isUserAllowedToSendMessage
    readonly property string chatInputPlaceHolderText: d.chatInputPlaceHolderText
    readonly property var oneToOneChatContact: d.oneToOneChatContact
    // Since qml component doesn't follow encaptulation from the backend side, we're introducing
    // a method which will return appropriate chat content module for selected chat/channel
    function currentChatContentModule() {
        // When we decide to have the same struct as it's on the backend we will remove this function.
        // So far this is a way to deal with refactored backend from the current qml structure.
        chatCommunitySectionModule.prepareChatContentModuleForChatId(chatCommunitySectionModule.activeItem.id)
        return chatCommunitySectionModule.getChatContentModule()
    }

    // Contact requests related part
    property var contactRequestsModel: chatCommunitySectionModule.contactRequestsModel

    property bool loadingHistoryMessagesInProgress: chatCommunitySectionModule.loadingHistoryMessagesInProgress

    property var advancedModule: profileSectionModule.advancedModule

    property var privacyModule: profileSectionModule.privacyModule

    readonly property bool permissionsCheckOngoing: chatCommunitySectionModule.permissionsCheckOngoing

    readonly property bool ensCommunityPermissionsEnabled: localAccountSensitiveSettings.ensCommunityPermissionsEnabled

    signal importingCommunityStateChanged(string communityId, int state, string errorMsg)

    signal communityAdded(string communityId)

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

    function cleanMessageText(formattedMessage) {
        const text = StatusQUtils.StringUtils.plainText(StatusQUtils.Emoji.deparse(formattedMessage))
        return interpretMessage(text)
    }

    function sendMessage(chatId, event, text, replyMessageId, fileUrlsAndSources) {
        chatCommunitySectionModule.prepareChatContentModuleForChatId(chatId)
        const chatContentModule = chatCommunitySectionModule.getChatContentModule()
        var result = false

        const textMsg = cleanMessageText(text)
        if (textMsg.trim() !== "") {
            if (event)
                event.accepted = true
        }

        if (fileUrlsAndSources.length > 0) {
            const convertedImagePaths = UrlUtils.convertUrlsToLocalPaths(fileUrlsAndSources)
            chatContentModule.inputAreaModule.sendImages(JSON.stringify(convertedImagePaths), textMsg.trim(), replyMessageId)
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

    property MessageStore messageStore: MessageStore { }

    property var emojiReactionsModel

    property var globalUtilsInst: globalUtils

    property var mainModuleInst: mainModule

    readonly property string appNetworkId: mainModuleInst.appNetworkId

    property var communitiesModuleInst: communitiesModule
    property var communitiesList: communitiesModuleInst.model

    property string channelEmoji: chatCommunitySectionModule && chatCommunitySectionModule.emoji ? chatCommunitySectionModule.emoji : ""

    property ListModel addToGroupContacts: ListModel {}

    property var walletSectionSendInst: walletSectionSend

    property string communityTags: communitiesModule.tags

    property var stickersModuleInst: stickersModule

    property bool isDebugEnabled: advancedModule ? advancedModule.isDebugEnabled : false

    readonly property int loginType: getLoginType()

    property string name: d.userProfileInst.name

    property StickersStore stickersStore: StickersStore {
        stickersModule: stickersModuleInst
    }

    function sendSticker(channelId, hash, replyTo, pack, url) {
        stickersModuleInst.send(channelId, hash, replyTo, pack, url)
    }

    function isCurrentUser(pubkey) {
        return d.userProfileInst.pubKey === pubkey
    }

    function displayName(name, pubkey) {
        return isCurrentUser(pubkey) ? qsTr("You") : name
    }

    function myPublicKey() {
        return d.userProfileInst.pubKey
    }

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

    function loadCommunityMemberMessages(communityId, pubKey) {
        chatCommunitySectionModule.loadCommunityMemberMessages(communityId, pubKey);
    }

    function banUserFromCommunity(pubKey, deleteAllMessages) {
        chatCommunitySectionModule.banUserFromCommunity(pubKey, deleteAllMessages);
    }

    function unbanUserFromCommunity(pubKey) {
        chatCommunitySectionModule.unbanUserFromCommunity(pubKey);
    }

    function createCommunityChannel(channelName, channelDescription, channelEmoji, channelColor,
            categoryId, viewersCanPostReactions, hideIfPermissionsNotMet) {
        chatCommunitySectionModule.createCommunityChannel(channelName, channelDescription,
            channelEmoji.trim(), channelColor, categoryId, viewersCanPostReactions, hideIfPermissionsNotMet);
    }

    function editCommunityChannel(chatId, newName, newDescription, newEmoji, newColor,
            newCategory, channelPosition, viewOnlyCanAddReaction, hideIfPermissionsNotMet) {
        chatCommunitySectionModule.editCommunityChannel(
                    chatId,
                    newName,
                    newDescription,
                    newEmoji,
                    newColor,
                    newCategory,
                    channelPosition,
                    viewOnlyCanAddReaction,
                    hideIfPermissionsNotMet
                )
    }

    function acceptRequestToJoinCommunity(requestId, communityId) {
        chatCommunitySectionModule.acceptRequestToJoinCommunity(requestId, communityId)
    }

    function declineRequestToJoinCommunity(requestId, communityId) {
        chatCommunitySectionModule.declineRequestToJoinCommunity(requestId, communityId)
    }

    function removeCommunityChat(chatId) {
        chatCommunitySectionModule.removeCommunityChat(chatId)
    }

    function reorderCommunityCategories(categoryId, to) {
        chatCommunitySectionModule.reorderCommunityCategories(categoryId, to)
    }

    function toggleCollapsedCommunityCategory(categoryId, collapsed) {
        chatCommunitySectionModule.toggleCollapsedCommunityCategory(categoryId, collapsed)
    }

    function reorderCommunityChat(categoryId, chatId, to) {
        chatCommunitySectionModule.reorderCommunityChat(categoryId, chatId, to)
    }

    function spectateCommunity(id, ensName) {
        return communitiesModuleInst.spectateCommunity(id, ensName)
    }

    function prepareKeypairsForSigning(communityId, ensName, addressesToShare = [], airdropAddress = "", editMode = false) {
        communitiesModuleInst.prepareKeypairsForSigning(communityId, ensName, JSON.stringify(addressesToShare), airdropAddress, editMode)
    }

    function signProfileKeypairAndAllNonKeycardKeypairs() {
        communitiesModuleInst.signProfileKeypairAndAllNonKeycardKeypairs()
    }

    function signSharedAddressesForKeypair(keyUid) {
        communitiesModuleInst.signSharedAddressesForKeypair(keyUid)
    }

    function joinCommunityOrEditSharedAddresses() {
        communitiesModuleInst.joinCommunityOrEditSharedAddresses()
    }

    function cleanJoinEditCommunityData() {
        communitiesModuleInst.cleanJoinEditCommunityData()
    }

    function userCanJoin(id) {
        return communitiesModuleInst.userCanJoin(id)
    }

    function isUserMemberOfCommunity(id) {
        return communitiesModuleInst.isUserMemberOfCommunity(id)
    }

    function isMyCommunityRequestPending(id) {
        return communitiesModuleInst.isMyCommunityRequestPending(id)
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

    // intervals is a string containing json array [{startTimestamp: 1690548852, startTimestamp: 1690547684}, {...}]
    function collectCommunityMetricsMessagesTimestamps(intervals) {
        chatCommunitySectionModule.collectCommunityMetricsMessagesTimestamps(intervals)
    }

    function collectCommunityMetricsMessagesCount(intervals) {
        chatCommunitySectionModule.collectCommunityMetricsMessagesCount(intervals)
    }

    function requestCommunityInfo(id, shardCluster, shardIndex, importing = false) {
        communitiesModuleInst.requestCommunityInfo(id, shardCluster, shardIndex, importing)
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

    function getPubkey() {
        return userProfile.getPubKey()
    }

    // Needed for TX in chat for stickers and via contact
    readonly property var accounts: walletSectionAccounts.accounts
    property string currentCurrency: walletSection.currentCurrency
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

    function resolveENS(value) {
        mainModuleInst.resolveENS(value, "")
    }

    function getWei2Eth(wei) {
        return globalUtilsInst.wei2Eth(wei,18)
    }

    function getEtherscanTxLink() {
        return profileSectionModule.ensUsernamesModule.getEtherscanTxLink()
    }

    function getLoginType() {
        if(!d.userProfileInst)
            return Constants.LoginType.Password

        if(d.userProfileInst.usingBiometricLogin)
            return Constants.LoginType.Biometrics
        if(d.userProfileInst.isKeycardUser)
            return Constants.LoginType.Keycard
        return Constants.LoginType.Password
    }

    readonly property Connections communitiesModuleConnections: Connections {
      target: communitiesModuleInst
      function onImportingCommunityStateChanged(communityId, state, errorMsg) {
          root.importingCommunityStateChanged(communityId, state, errorMsg)
      }

      function onCommunityAccessRequested(communityId) {
          root.communityAccessRequested(communityId)
      }

      function onCommunityAdded(communityId) {
          root.communityAdded(communityId)
      }
    }

    readonly property Connections mainModuleInstConnections: Connections {
        target: mainModuleInst
        enabled: !!chatCommunitySectionModule
        function onOpenCommunityMembershipRequestsView(sectionId: string) {
            if(root.getMySectionId() !== sectionId)
                return

            root.goToMembershipRequestsPage()
        }
    }

    readonly property QtObject _d: StatusQUtils.QObject {
        id: d

        readonly property var userProfileInst: userProfile

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
                readonly property string image: model.image
                readonly property bool joined: model.joined
                readonly property bool amIBanned: model.amIBanned
                readonly property string introMessage: model.introMessage
                // add others when needed..
            }
        }

        readonly property string activeChatId: chatCommunitySectionModule && chatCommunitySectionModule.activeItem ? chatCommunitySectionModule.activeItem.id : ""
        readonly property int activeChatType: chatCommunitySectionModule && chatCommunitySectionModule.activeItem ? chatCommunitySectionModule.activeItem.type : -1
        readonly property bool amIMember: chatCommunitySectionModule ? chatCommunitySectionModule.amIMember : false

        property var oneToOneChatContact: undefined
        readonly property string oneToOneChatContactName: !!d.oneToOneChatContact ? ProfileUtils.displayName(d.oneToOneChatContact.localNickname,
                                                                                                    d.oneToOneChatContact.name,
                                                                                                    d.oneToOneChatContact.displayName,
                                                                                                    d.oneToOneChatContact.alias) : ""

        StatusQUtils.ModelEntryChangeTracker {
            model: root.contactsStore.contactsModel
            role: "pubKey"
            key: d.activeChatId

            onItemChanged: d.oneToOneChatContact = Utils.getContactDetailsAsJson(d.activeChatId, false)
        }

        readonly property bool isUserAllowedToSendMessage: {
            if (d.activeChatType === Constants.chatType.oneToOne && d.oneToOneChatContact) {
                return d.oneToOneChatContact.contactRequestState === Constants.ContactRequestState.Mutual
            } else if (d.activeChatType === Constants.chatType.privateGroupChat) {
                return d.amIMember
            } else if (d.activeChatType === Constants.chatType.communityChat) {
                return currentChatContentModule().chatDetails.canPost
            }

            return true
        }

        readonly property string chatInputPlaceHolderText: {
            if(!d.isUserAllowedToSendMessage && d.activeChatType === Constants.chatType.privateGroupChat) {
                return qsTr("You need to be a member of this group to send messages")
            } else if(!d.isUserAllowedToSendMessage && d.activeChatType === Constants.chatType.oneToOne) {
                return qsTr("Add %1 as a contact to send a message").arg(d.oneToOneChatContactName)
            }

            return qsTr("Message")
        }

        //Update oneToOneChatContact when activeChat id changes
        Binding on oneToOneChatContact {
            when: d.activeChatId && d.activeChatType === Constants.chatType.oneToOne
            value: Utils.getContactDetailsAsJson(d.activeChatId, false)
            restoreMode: Binding.RestoreBindingOrValue
        }
    }

    function updatePermissionsModel(communityId, sharedAddresses) {
        communitiesModuleInst.checkPermissions(communityId, JSON.stringify(sharedAddresses))
    }

    function removeMemberFromGroupChat(publicKey) {
        const chatId = chatCommunitySectionModule.activeItem.id
        chatCommunitySectionModule.removeMemberFromGroupChat("", chatId, publicKey)
    }
}
