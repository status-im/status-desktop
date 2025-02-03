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
    /** recipient address selected in send modal for sending **/
    required property string selectedRecipientAddress
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

    /**
      Expected model structure:

        address               [string] - address of recipient
        name                  [string] - name of recipient
        ens                   [string] - ens of recipient
        emoji                 [string] - emoji of recipient wallet
        color                 [string] - color of recipient wallet
        colorId               [string] - colorId of recipient wallet
    **/
    required property var recipientModel

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

    /** output property of the selected recipient address **/
    readonly property string recipientAddress: selectedRecipientEntry.available ? selectedRecipientEntry.item.address : selectedRecipientAddress
    /** output property of the selected recipient name **/
    readonly property string recipientName: selectedRecipientEntry.available ? selectedRecipientEntry.item.name : ""
    /** output property of the selected recipient ens **/
    readonly property string recipientEns: selectedRecipientEntry.available ? selectedRecipientEntry.item.ens : ""
    /** output property of the selected recipient emoji **/
    readonly property string recipientEmoji: selectedRecipientEntry.available ? selectedRecipientEntry.item.emoji : ""
    /** output property of the selected recipient color **/
    readonly property string recipientWalletColor: {
        if (!selectedRecipientEntry.available)
            return ""
        const color = selectedRecipientEntry.item.color
        if (!!color) {
            return color
        }
        const colorId = selectedRecipientEntry.item.colorId
        if (!!colorId) {
            return Utils.getColorForId(colorId)
        }
        return ""
    }

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

    ModelEntry {
        id: selectedRecipientEntry
        sourceModel: root.recipientModel
        key: "address"
        value: root.selectedRecipientAddress
    }
}
