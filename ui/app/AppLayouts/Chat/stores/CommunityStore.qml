import QtQuick 2.15

import SortFilterProxyModel 0.2

import shared.stores 1.0

import StatusQ 0.1

QtObject {
    id: root

    property CommunityTokensStore communityTokensStore

        property var communityItemsModel: chatCommunitySectionModule.model
    readonly property PermissionsStore permissionsStore: PermissionsStore {
        activeSectionId: mainModuleInst.activeSection.id
        activeChannelId: root.currentChatContentModule().chatDetails.id
        chatCommunitySectionModuleInst: chatCommunitySectionModule
    }

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


    readonly property bool permissionsCheckOngoing: chatCommunitySectionModule.permissionsCheckOngoing

    readonly property bool ensCommunityPermissionsEnabled: localAccountSensitiveSettings.ensCommunityPermissionsEnabled

    signal importingCommunityStateChanged(string communityId, int state, string errorMsg)

    signal communityAdded(string communityId)

    signal communityAccessRequested(string communityId)

    function setActiveCommunity(communityId) {
        mainModule.setActiveSectionById(communityId);
    }

    function setObservedCommunity(communityId) {
        communitiesModuleInst.setObservedCommunity(communityId);
    }

    signal goToMembershipRequestsPage()

    property var communitiesModuleInst: communitiesModule
    property var communitiesList: communitiesModuleInst.model

    property string channelEmoji: chatCommunitySectionModule && chatCommunitySectionModule.emoji ? chatCommunitySectionModule.emoji : ""

    property string communityTags: communitiesModule.tags

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

    // TO review
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

    function getSectionNameById(id) {
        return communitiesList.getSectionNameById(id)
    }

    function getSectionByIdJson(id) {
        return communitiesList.getSectionByIdJson(id)
    }


}
