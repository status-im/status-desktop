import QtQuick 2.15

import StatusQ 0.1
import StatusQ.Models 0.1

import utils 1.0

QtObject {
    id: root

    /* PRIVATE: Modules used to get data from backend */
    readonly property var _allCollectiblesModule: !!walletSectionAllCollectibles ? walletSectionAllCollectibles : null

    /* This list contains the complete list of collectibles with separate
       entry per collectible which has a unique [network + contractAddress + tokenID] */
    readonly property var _allCollectiblesModel: !!root._allCollectiblesModule ? root._allCollectiblesModule.allCollectiblesModel : null

    readonly property var allCollectiblesModel: RolesRenamingModel {
        sourceModel: root._allCollectiblesModel

        mapping: [
            RoleRename {
                from: "uid"
                to: "symbol"
            }
        ]
    }

    readonly property var collectiblesController: ManageTokensController {
        sourceModel: allCollectiblesModel
        settingsKey: "WalletCollectibles"
        onCommunityTokenGroupHidden: (communityName) => Global.displayToastMessage(
                                         qsTr("%1 community collectibles successfully hidden").arg(communityName), "", "checkmark-circle",
                                         false, Constants.ephemeralNotificationType.success, "")
        onTokenShown: (symbol, name) => Global.displayToastMessage(qsTr("%1 is now visible").arg(name), "", "checkmark-circle",
                                                                   false, Constants.ephemeralNotificationType.success, "")
        onCommunityTokenGroupShown: (communityName) => Global.displayToastMessage(
                                        qsTr("%1 community collectibles are now visible").arg(communityName), "", "checkmark-circle",
                                        false, Constants.ephemeralNotificationType.success, "")
    }
    readonly property bool areCollectiblesFetching: !!root._allCollectiblesModel ? root._allCollectiblesModel.isFetching : true
    readonly property bool areCollectiblesUpdating: !!root._allCollectiblesModel ? root._allCollectiblesModel.isUpdating : false
    readonly property bool areCollectiblesError: !!root._allCollectiblesModel ? root._allCollectiblesModel.isError : false


    /* The following are used to display the detailed view of a collectible */
    readonly property var detailedCollectible: Global.appIsReady ? walletSection.collectibleDetailsController.detailedEntry : null
    readonly property var detailedCollectibleStatus: Global.appIsReady ? walletSection.collectibleDetailsController.status : null
    readonly property bool isDetailedCollectibleLoading: Global.appIsReady ? walletSection.collectibleDetailsController.isDetailedEntryLoading : true

    function getDetailedCollectible(chainId, contractAddress, tokenId) {
        walletSection.collectibleDetailsController.getDetailedCollectible(chainId, contractAddress, tokenId)
    }
}
