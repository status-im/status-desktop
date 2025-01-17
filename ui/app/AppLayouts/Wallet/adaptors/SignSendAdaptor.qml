import QtQuick 2.15

import StatusQ 0.1
import StatusQ.Core.Utils 0.1

/**
  Adaptor transforming selected data from send to a format that
  can be used in the sign modal
**/
QObject {
    id: root

    /** Account key used for filtering **/
    required property string accountKey
    /** network chainId used for filtering **/
    required property int chainId
    /** token key used for filtering **/
    required property string tokenKey
    /** amount selected in send modal for sending **/
    required property string selectedAmountInBaseUnit
    /**
      Expected model structure:

        name                 [int]    - name of account
        address              [string] - address of account
        emoji                [string] - emoji of account
        colorId              [string] - colorId of account
    **/
    required property var accountsModel
    /**
      Expected model structure:

        chainId              [int]    - network chain id
        chainName            [string] - name of network
        iconUrl              [string] - network icon url
    **/
    required property var networksModel
    /**
      Expected model structure:

        key                   [int]    - unique id of token
        symbol                [int]    - symbol of token
        decimals              [string] - decimals of token
    **/
    required property var tokenBySymbolModel

    /** output property of the account selected **/
    readonly property var selectedAccount: selectedAccountEntry.item
    /** output property of the network selected **/
    readonly property var selectedNetwork: selectedNetworkEntry.item
    /** output property of the asset (ERC20) selected **/
    readonly property var selectedAsset: selectedAssetEntry.item
    /** output property of the localised amount to send **/
    readonly property string selectedAmount: {
        const decimals = !!root.selectedAsset ? root.selectedAsset.decimals: 0
        const divisor = AmountsArithmetic.fromExponent(decimals)
        let amount =  AmountsArithmetic.div(
                AmountsArithmetic.fromString(root.selectedAmountInBaseUnit),
                divisor).toFixed(decimals)
        // removeDecimalTrailingZeros
        amount = Utils.stripTrailingZeros(amount)
        // localize
        return amount.replace(".", Qt.locale().decimalPoint)
    }
    /** output property of the selected asset contract address on selected chainId **/
    readonly property string selectedAssetContractAddress: selectedAssetContractEntry.available &&
                                                           !!selectedAssetContractEntry.item ?
                                                               selectedAssetContractEntry.item.address: ""

    ModelEntry {
        id: selectedAccountEntry
        sourceModel: root.accountsModel
        value: root.accountKey
        key: "address"
    }

    ModelEntry {
        id: selectedNetworkEntry
        sourceModel: root.networksModel
        value: root.chainId
        key: "chainId"
    }

    ModelEntry {
        id: selectedAssetEntry
        sourceModel: root.tokenBySymbolModel
        value: root.tokenKey
        key: "key"
    }

    ModelEntry {
        id: selectedAssetContractEntry
        sourceModel: selectedAssetEntry.available &&
                     !!selectedAssetEntry.item ?
                         selectedAssetEntry.item.addressPerChain: null
        value: root.chainId
        key: "chainId"
    }
}
