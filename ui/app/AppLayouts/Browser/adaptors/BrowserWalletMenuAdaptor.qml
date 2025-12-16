import QtQuick
import StatusQ.Core.Utils as SQUtils
import utils

/**
 * BrowserWalletMenuAdaptor
 *
 * Prepares data for initializing the browser wallet menu popup.
 * Transforms store data into filter-ready formats.
 *
 * Input:
 *  - activeNetworksModel: Model of active networks from NetworksStore
 *  - currentAccount: Current browser account object
 *
 * Output:
 *  - activeChainIds: Array of active chain IDs
 *  - chainsFilterJson: JSON string of chain IDs for filtering
 *  - addressesFilterJson: JSON string of current address for filtering
 *  - hasActiveChains: Whether there are any active chains
 */
QtObject {
    id: root

    required property var activeNetworksModel
    required property var currentAccount

    readonly property var activeChainIds: {
        if (!root.activeNetworksModel) {
            return []
        }
        return SQUtils.ModelUtils.modelToFlatArray(
            root.activeNetworksModel, "chainId")
    }

    readonly property string currentAccountAddress: {
        return root.currentAccount?.address ?? ""
    }

    readonly property string chainsFilterJson: {
        return JSON.stringify(root.activeChainIds)
    }

    readonly property string addressesFilterJson: {
        return JSON.stringify([root.currentAccountAddress])
    }

    readonly property bool hasActiveChains: {
        return root.activeChainIds.length > 0
    }
}
