import QtQml 2.15

import AppLayouts.Wallet 1.0

import StatusQ 0.1
import StatusQ.Core.Utils 0.1

import SortFilterProxyModel 0.2

QObject {
    id: root

    // Input parameters:
    /**
      Expected model structure:
        address                     [string] - wallet account address, e.g "0x10b...eaf"
        name                        [string] - wallet account name, e.g "Status account"
        keyUid                      [string] - unique identifier, e.g "0x79e07.....006"
        currencyBalance             [var]    - CurrencyAmount type
            amount              [string]
            symbol              [string]
            displayDecimals     [int]
            stripTrailingZeroes [bool]
        emoji                       [string] - custom emoji
        walletType                  [string] - e.g "generated"
        colorId                     [string] - e.g "YELLOW"
        preferredSharingChainIds    [string] - separated by `:`, e.g "42161:10:1"
        position                    [int]    - visual order, e.g: "1"
    **/
    property var accountsModel

    property var flatNetworksModel
    property bool areTestNetworksEnabled

    // Output parameters:
    /**
      Model structure:

        All roles from the source model are passed directly to the output model,
        additionally:
            colorizedChainShortNames    [string] - build from `preferredSharingChainIds` adding different colors to different network short names
    **/
    readonly property alias model: sfpm

    readonly property SortFilterProxyModel filteredFlatNetworksModel: SortFilterProxyModel {
        sourceModel: root.flatNetworksModel
        filters: ValueFilter { roleName: "isTest"; value: root.areTestNetworksEnabled }
    }

    QtObject {
        id: d

        property var chainColors: ({})

        function initChainColors() {
            for (let i = 0; i < root.flatNetworksModel.count; i++) {
                const item = ModelUtils.get(root.flatNetworksModel, i)
                chainColors[item.shortName] = item.chainColor
            }
        }
    }

    SortFilterProxyModel {
        id: sfpm
        sourceModel: root.accountsModel ?? null

        proxyRoles: FastExpressionRole {
            function getChainShortNames(preferredSharingChainIds){
                const chainShortNames = WalletUtils.getNetworkShortNames(preferredSharingChainIds, root.flatNetworksModel)
                return WalletUtils.colorizedChainPrefixNew(d.chainColors, chainShortNames)
            }

            name: "colorizedChainShortNames"
            expectedRoles: ["preferredSharingChainIds"]
            expression: getChainShortNames(model.preferredSharingChainIds)
        }
    }

    onFlatNetworksModelChanged: d.initChainColors()
}
