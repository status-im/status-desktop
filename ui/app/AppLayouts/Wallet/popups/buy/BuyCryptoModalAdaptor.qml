import QtQml 2.15
import SortFilterProxyModel 0.2

import StatusQ 0.1
import StatusQ.Core.Utils 0.1

QObject {
    id: root

    required property var networksModel
    required property bool areTestNetworksEnabled
    required property var processedTokenSelectorAssetsModel
    required property var selectedProviderSupportedAssetsArray
    required property int selectedChainId

    readonly property SortFilterProxyModel filteredFlatNetworksModel: SortFilterProxyModel {
        sourceModel: root.networksModel
        filters: ValueFilter { roleName: "isTest"; value: root.areTestNetworksEnabled }
    }

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
            expression: isSupportedByProvider(model.addressPerChain)
            expectedRoles: ["addressPerChain"]
            enabled: !!root.selectedProviderSupportedAssetsArray && root.selectedProviderSupportedAssetsArray.length > 0 && root.selectedChainId !== -1
        }
    }
}
