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
            function isSupportedByProvider(tokens) {
                if(!tokens)
                    return true
                return !!ModelUtils.getFirstModelEntryIf(
                            tokens,
                            (t) => {
                                return root.selectedChainId === t.chainId &&
                                root.selectedProviderSupportedAssetsArray.includes(t.key)
                            })
            }
            expression: {
                root.selectedChainId //dependency
                root.selectedProviderSupportedAssetsArray //dependency
                isSupportedByProvider(model.tokens)
            }
            expectedRoles: ["tokens"]
            enabled: !!root.selectedProviderSupportedAssetsArray && root.selectedProviderSupportedAssetsArray.length > 0 && root.selectedChainId !== -1
        }
    }
}
