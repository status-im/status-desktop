import QtQuick 2.13
import QtQml.Models 2.2

QtObject {
    id: root

    property var communitiesModuleInst: communitiesModule
    property var curatedCommunitiesModel: root.communitiesModuleInst.curatedCommunities
    property var locale: appSettings.locale

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
}
