pragma Singleton

import QtQml

import StatusQ.Core
import StatusQ.Core.Utils
import StatusQ.Internal as Internal

import AppLayouts.Communities.controls

QtObject {

    // Given a specific network model and an index inside the model, it gets the chain name.
    function getChainName(model, index) {
        return ModelUtils.get(model, index, "chainName") ?? ""
    }

     // Given a specific network model and an index inside the model, it gets the chain icon url.
    function getChainIconUrl(model, index) {
        return ModelUtils.get(model, index, "iconUrl") ?? ""
    }

    // Given a network model, it looks for the provided chainId and returns
    // the layer network model that contains the specific chain. If not found, returns undefined.
    function getLayerNetworkModelByChainId(networksModel, chainId) {
        if(chainId) {
            if(!!networksModel && ModelUtils.contains(networksModel, "chainId", chainId))
                return networksModel
        }

        // Default value if chainId is not part of any provided layer network model
        return undefined
    }

    // Given a network model, it looks for the provided chainId and returns
    // the index of the the specific chain. If not found, returns 0 value.
    function getChainIndexByChainId(networksModel, chainId) {
        if(!!networksModel && chainId !== undefined)
            return ModelUtils.indexOf(networksModel, "chainId", chainId)

        // Default value if no model specified
        return 0
    }

    function getChainIndexForFirstLayer2Network(networksModel) {
        if(!!networksModel)
            return ModelUtils.indexOf(networksModel, "layer", 2)

        // Default value if no model specified
        return 0
    }
}
