import QtQuick 2.13
import QtQml.Models 2.2

import utils 1.0

QtObject {
    id: root

    property var communitiesModuleInst: communitiesModule
    property var mainModuleInst: mainModule

    readonly property var curatedCommunitiesModel: root.communitiesModuleInst.curatedCommunities
    readonly property bool curatedCommunitiesLoading: root.communitiesModuleInst.curatedCommunitiesLoading

    property var discordFileList: root.communitiesModuleInst.discordFileList
    property var discordCategoriesModel: root.communitiesModuleInst.discordCategories
    property var discordChannelsModel: root.communitiesModuleInst.discordChannels
    property int discordOldestMessageTimestamp: root.communitiesModuleInst.discordOldestMessageTimestamp
    property bool discordDataExtractionInProgress: root.communitiesModuleInst.discordDataExtractionInProgress
    property int discordImportErrorsCount: root.communitiesModuleInst.discordImportErrorsCount
    property int discordImportWarningsCount: root.communitiesModuleInst.discordImportWarningsCount
    property int discordImportProgress: root.communitiesModuleInst.discordImportProgress
    property bool discordImportInProgress: root.communitiesModuleInst.discordImportInProgress
    property bool discordImportCancelled: root.communitiesModuleInst.discordImportCancelled
    property bool discordImportProgressStopped: root.communitiesModuleInst.discordImportProgressStopped
    property int discordImportProgressTotalChunksCount: root.communitiesModuleInst.discordImportProgressTotalChunksCount
    property int discordImportProgressCurrentChunk: root.communitiesModuleInst.discordImportProgressCurrentChunk
    property string discordImportCommunityId: root.communitiesModuleInst.discordImportCommunityId
    property string discordImportCommunityName: root.communitiesModuleInst.discordImportCommunityName
    property url discordImportCommunityImage: root.communitiesModuleInst.discordImportCommunityImage
    property bool discordImportHasCommunityImage: root.communitiesModuleInst.discordImportHasCommunityImage
    property var discordImportTasks: root.communitiesModuleInst.discordImportTasks
    property bool downloadingCommunityHistoryArchives: root.communitiesModuleInst.downloadingCommunityHistoryArchives
    property var advancedModule: profileSectionModule.advancedModule

    // TODO: Could the backend provide directly 2 filtered models??
    //property var featuredCommunitiesModel: root.communitiesModuleInst.curatedFeaturedCommunities
    //property var popularCommunitiesModel: root.communitiesModuleInst.curatedPopularCommunities
    property ListModel tagsModel: ListModel {}//root.notionsTagsModel

    // TO DO: Complete list can be added in backend or here: https://www.notion.so/Category-tags-339b2e699e7c4d36ab0608ab00b99111
    property ListModel notionsTagsModel : ListModel {
        ListElement { name: "gaming"; emoji: "🎮"}
        ListElement { name: "art"; emoji: "🖼️️"}
        ListElement { name: "crypto"; emoji: "💸"}
        ListElement { name: "nsfw"; emoji: "🍆"}
        ListElement { name: "markets"; emoji: "💎"}
        ListElement { name: "defi"; emoji: "📈"}
        ListElement { name: "travel"; emoji: "🚁"}
        ListElement { name: "web3"; emoji: "🗺"}
        ListElement { name: "sport"; emoji: "🎾"}
        ListElement { name: "food"; emoji: "🥑"}
        ListElement { name: "enviroment"; emoji: "☠️"}
        ListElement { name: "privacy"; emoji: "👻"}
    }

    property string communityTags: communitiesModuleInst.tags

    signal importingCommunityStateChanged(string communityId, int state, string errorMsg)

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
                                    encrypted: false,
                                },
                                bannerJsonStr: ""
                             }) {
        return communitiesModuleInst.createCommunity(
                    args.name, args.description, args.introMessage, args.outroMessage, args.options.checkedMembership,
                    args.color, args.tags,
                    args.image.src, args.image.AX, args.image.AY, args.image.BX, args.image.BY,
                    args.options.historyArchiveSupportEnabled, args.options.pinMessagesAllowedForMembers,
                    args.bannerJsonStr, args.options.encrypted);
    }

    function importCommunity(communityKey) {
        root.communitiesModuleInst.importCommunity(communityKey);
    }

    function requestCommunityInfo(communityKey, importing = false) {
        const publicKey = Utils.isCompressedPubKey(communityKey)
                            ? Utils.changeCommunityKeyCompression(communityKey)
                            : communityKey
        root.mainModuleInst.setCommunityIdToSpectate(publicKey)
        root.communitiesModuleInst.requestCommunityInfo(publicKey, importing)
    }

    function setActiveCommunity(communityId) {
        root.mainModuleInst.setActiveSectionById(communityId);
    }

    function navigateToCommunity(communityId) {
        root.communitiesModuleInst.navigateToCommunity(communityId)
    }

    function removeFileListItem(filePath) {
        root.communitiesModuleInst.removeFileListItem(filePath)
    }
    function setFileListItems(filePaths) {
        root.communitiesModuleInst.setFileListItems(filePaths)
    }

    function clearFileList() {
        root.communitiesModuleInst.clearFileList()
    }

    function requestExtractChannelsAndCategories() {
        root.communitiesModuleInst.requestExtractDiscordChannelsAndCategories()
    }

    function clearDiscordCategoriesAndChannels() {
        root.communitiesModuleInst.clearDiscordCategoriesAndChannels()
    }

    function toggleDiscordCategory(id, selected) {
        root.communitiesModuleInst.toggleDiscordCategory(id, selected)
    }

    function toggleDiscordChannel(id, selected) {
        root.communitiesModuleInst.toggleDiscordChannel(id, selected)
      }

    function requestCancelDiscordCommunityImport(id) {
        root.communitiesModuleInst.requestCancelDiscordCommunityImport(id)
    }

    function resetDiscordImport() {
        root.communitiesModuleInst.resetDiscordImport(false)
    }

    function requestImportDiscordCommunity(args = {
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
                                }
                             }, from = 0) {
        return communitiesModuleInst.requestImportDiscordCommunity(
                    args.name, args.description, args.introMessage, args.outroMessage, args.options.checkedMembership,
                    args.color, args.tags,
                    args.image.src, args.image.AX, args.image.AY, args.image.BX, args.image.BY,
                    args.options.historyArchiveSupportEnabled, args.options.pinMessagesAllowedForMembers, from);
    }


    readonly property Connections connections: Connections {
        target: communitiesModuleInst
        function onImportingCommunityStateChanged(communityId, state, errorMsg) {
            root.importingCommunityStateChanged(communityId, state, errorMsg)
        }
    }
}
