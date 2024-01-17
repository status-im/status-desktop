
import QtQuick 2.12
import utils 1.0

QtObject {
    id: root

    /* PRIVATE: Modules used to get data from backend */
    readonly property var _allCollectiblesModule: !!walletSectionAllCollectibles ? walletSectionAllCollectibles : null

    /* This list contains the complete list of collectibles with separate
       entry per collectible which has a unique [network + contractAddress + tokenID] */
    readonly property var allCollectiblesModel: !!root._allCollectiblesModule ? root._allCollectiblesModule.allCollectiblesModel : null

    /* The following are used to display the detailed view of a collectible */
    readonly property var detailedCollectible: Global.appIsReady ? walletSection.collectibleDetailsController.detailedEntry : null
    readonly property var detailedCollectibleStatus: Global.appIsReady ? walletSection.collectibleDetailsController.status : null
    readonly property bool isDetailedCollectibleLoading: Global.appIsReady ? walletSection.collectibleDetailsController.isDetailedEntryLoading : true

    function getDetailedCollectible(chainId, contractAddress, tokenId) {
        walletSection.collectibleDetailsController.getDetailedCollectible(chainId, contractAddress, tokenId)
    }
}
