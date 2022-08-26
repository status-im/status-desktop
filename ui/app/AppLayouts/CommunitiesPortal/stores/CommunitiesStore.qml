import QtQuick 2.13
import QtQml.Models 2.2

QtObject {
    id: root

    property var communitiesModuleInst: communitiesModule
    property var curatedCommunitiesModel: root.communitiesModuleInst.curatedCommunities
    property var discordFileList: root.communitiesModuleInst.discordFileList
    property var discordCategoriesModel: root.communitiesModuleInst.discordCategories
    property var discordChannelsModel: root.communitiesModuleInst.discordChannels
    property int discordOldestMessageTimestamp: root.communitiesModuleInst.discordOldestMessageTimestamp
    property bool discordDataExtractionInProgress: root.communitiesModuleInst.discordDataExtractionInProgress
    property int discordImportErrorsCount: root.communitiesModuleInst.discordImportErrorsCount
    property int discordImportWarningsCount: root.communitiesModuleInst.discordImportWarningsCount
    property string locale: localAppSettings.language
    property var advancedModule: profileSectionModule.advancedModule
    property bool isCommunityHistoryArchiveSupportEnabled: advancedModule? advancedModule.isCommunityHistoryArchiveSupportEnabled : false

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
                                    pinMessagesAllowedForMembers: false
                                },
                                bannerJsonStr: ""
                             }) {
        return communitiesModuleInst.createCommunity(
                    args.name, args.description, args.introMessage, args.outroMessage, args.options.checkedMembership,
                    args.color, args.tags,
                    args.image.src, args.image.AX, args.image.AY, args.image.BX, args.image.BY,
                    args.options.historyArchiveSupportEnabled, args.options.pinMessagesAllowedForMembers, args.bannerJsonStr);
    }

    function importCommunity(communityKey) {
        root.communitiesModuleInst.importCommunity(communityKey);
    }

    function setActiveCommunity(communityId) {
        mainModule.setActiveSectionById(communityId);
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
}
