
import QtQuick 2.12
import utils 1.0

QtObject {
    id: root
    readonly property var ownedCollectibles: Global.appIsReady ? walletSection.collectiblesController.model : null

    readonly property var detailedCollectible: Global.appIsReady ? walletSection.collectibleDetailsController.detailedEntry : null
    readonly property var detailedCollectibleStatus: Global.appIsReady ? walletSection.collectibleDetailsController.status : null
    readonly property bool isDetailedCollectibleLoading: Global.appIsReady ? walletSection.collectibleDetailsController.isDetailedEntryLoading : true

    function fetchMoreCollectibles() {
        if (!root.ownedCollectibles.hasMore
            || root.ownedCollectibes.isFetching)
            return
        walletSection.collectiblesController.loadMoreItems()
    }

    function getDetailedCollectible(chainId, contractAddress, tokenId) {
        walletSection.collectibleDetailsController.getDetailedCollectible(chainId, contractAddress, tokenId)
    }
}
