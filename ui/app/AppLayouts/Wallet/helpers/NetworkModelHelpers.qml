pragma Singleton

import QtQml 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Internal 0.1 as Internal

import AppLayouts.Communities.controls 1.0

QtObject {

    // Given a specific network model and an index inside the model, it gets the chain name.
    function getChainName(model, index) {
        return ModelUtils.get(model, index, "chainName") ?? ""
    }

     // Given a specific network model and an index inside the model, it gets the chain icon url.
    function getChainIconUrl(model, index) {
        return ModelUtils.get(model, index, "iconUrl") ?? ""
    }

    // Given a layer1 network model and layer2 network model, it looks for the provided chainId and returns
    // the layer network model that contains the specific chain. If not found, returns undefined.
    function getLayerNetworkModelByChainId(layer1NetworksModel, layer2NetworksModel, chainId) {
        if(chainId) {
            if(!!layer1NetworksModel && ModelUtils.contains(layer1NetworksModel, "chainId", chainId))
                return layer1NetworksModel

            else if(!!layer2NetworksModel && ModelUtils.contains(layer2NetworksModel, "chainId", chainId))
                return layer2NetworksModel
        }

        // Default value if chainId is not part of any provided layer network model
        return undefined
    }

    // Given a layer1 network model and layer2 network model, it looks for the provided chainId and returns
    // the index of the the specific chain. If not found, returns 0 value.
    function getChainIndexByChainId(layer1NetworksModel, layer2NetworksModel, chainId) {
        const currentModel = getLayerNetworkModelByChainId(layer1NetworksModel, layer2NetworksModel, chainId)

        if(!!currentModel)
             return ModelUtils.indexOf(currentModel, "chainId", chainId)

         // Default value if no model specified
        return 0
    }
}
