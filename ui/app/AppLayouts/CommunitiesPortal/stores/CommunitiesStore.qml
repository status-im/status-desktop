import QtQuick 2.13

QtObject {
    id: root

    property var communitiesModuleInst: communitiesModule
    property var curatedCommunitiesModel: root.communitiesModuleInst.curatedCommunities
    property var locale: appSettings.locale

    property ListModel featuredCommunitiesModel: root.featuredTestCommunitiesModel //[]
    property ListModel popularCommunitiesModel: root.popularTestCommunitiesModel //[]
    property ListModel tagsModel: root.tagsTestModel

    function updateCommunitiesClassification() {
        root.featuredCommunitiesModel.clear()
        root.popularCommunitiesModel.clear()

        if(root.curatedCommunitiesModel) {
            for(var i = 0; i < root.curatedCommunitiesModel.count; i++) {
                var entry = root.curatedCommunitiesModel.get(i)
                if(entry.featured) {
                    root.featuredCommunitiesModel.append(entry)
                }
                else {
                    root.popularCommunitiesModel.append(entry)
                }
            }
        }
    }

    // COMMENTED FOR TESTING:
    //onCuratedCommunitiesModelChanged: { root.updateCommunitiesClassification() }

    // Test models:
    // TO DO: Complete list can be added in backend or here: https://www.notion.so/Category-tags-339b2e699e7c4d36ab0608ab00b99111
    property ListModel tagsTestModel : ListModel {
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

    property ListModel featuredTestCommunitiesModel : ListModel {
        ListElement {
            name: "CryptoKitties";
            description: "A community of cat lovers, meow!";
            icon: "../../../../imports/assets/png/collectibles/CryptoKitties.png";
            members: 1000;
            categories: [];
            communityId: "1";
            available: true;
            popularity: 1
        }
        ListElement {
            name: "Friends with Benefits";
            description: "A group chat full of out favorite thinkers and creators.";
            icon: "../../../../imports/assets/png/collectibles/FriendsBenefits.png";
            members: 452;
            categories: [];
            communityId: "2";
            available: true;
            popularity: 2
        }
        ListElement {
            name: "Teller";
            description: "A community of P2P crypto trades";
            icon: "../../../../imports/assets/png/collectibles/P2PCrypto.png";
            members: 50;
            categories: [];
            communityId: "3";
            available: true;
            popularity: 3
        }
    }

    property ListModel popularTestCommunitiesModel : ListModel {
        ListElement {
            name: "Status";
            description: "Community description goes here.";
            icon: "../../../../imports/assets/png/collectibles/SNT.png";
            members: 5288;
            categories: [];
            communityId: "4";
            available: true;
            popularity: 4
        }
        ListElement {
            name: "Status Punks";
            description: "Community description goes here.";
            icon: "../../../../imports/assets/png/collectibles/StatusPunks.png";
            members: 4125;
            categories: [];
            communityId: "5";
            available: false;
            popularity: 5
        }
        ListElement {
            name: "Uniswap";
            description: "Community description goes here.";
            icon: "../../../../imports/assets/png/collectibles/CryptoKitties.png";
            members: 45;
            categories: [];
            communityId: "6";
            available: false;
            popularity: 6
        }
        ListElement {
            name: "Dragonereum";
            description: "Community description goes here.";
            icon: "../../../../imports/assets/png/collectibles/Dragonerum.png";
            members: 968;
            categories: [];
            communityId: "7";
            available: true;
            popularity: 7
        }
        ListElement {
            name: "CryptoPunks";
            description: "Community description goes here.";
            icon: "../../../../imports/assets/png/collectibles/CryptoPunks.png";
            members: 4200;
            categories: [];
            communityId: "8";
            available: true;
            popularity: 8
        }
        ListElement {
            name: "Socks";
            description: "Community description goes here.";
            icon: "../../../../imports/assets/png/collectibles/Socks.png";
            members: 12;
            categories: [];
            communityId: "9";
            available: true;
            popularity: 9
        }
    }
}
