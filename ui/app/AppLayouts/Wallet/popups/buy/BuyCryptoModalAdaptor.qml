import QtQml
import SortFilterProxyModel

import StatusQ
import StatusQ.Core.Utils

QObject {
    id: root

    required property var networksModel
    required property var processedTokenSelectorAssetsModel
    required property var selectedProviderSupportedAssetsArray
    required property int selectedChainId

    // this proxy removes tokens not supported by selected on-ramp provider
    readonly property SortFilterProxyModel filteredAssetsModel: SortFilterProxyModel {
        sourceModel: root.processedTokenSelectorAssetsModel.count ? root.processedTokenSelectorAssetsModel: null
        filters: FastExpressionFilter {
            function isSupportedByProvider(addressPerChain) {
                if(!addressPerChain)
                    return true
                return !!ModelUtils.getFirstModelEntryIf(
                            addressPerChain,
                            (addPerChain) => {
                                return root.selectedChainId === addPerChain.chainId &&
                                root.selectedProviderSupportedAssetsArray.includes(addPerChain.chainId+addPerChain.address)
                            })
            }
            expression: {
                root.selectedChainId //dependency
                root.selectedProviderSupportedAssetsArray //dependency
                isSupportedByProvider(model.addressPerChain)
            }
            expectedRoles: ["addressPerChain"]
            enabled: !!root.selectedProviderSupportedAssetsArray && root.selectedProviderSupportedAssetsArray.length > 0 && root.selectedChainId !== -1
        }
    }
}
