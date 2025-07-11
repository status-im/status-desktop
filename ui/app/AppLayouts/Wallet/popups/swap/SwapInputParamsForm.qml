import QtQml

import StatusQ.Core.Utils as SQUtils

import utils

/* This is used so that there is an easy way to fill in the data
needed to launch the Swap Modal with pre-filled requisites. */
QtObject {
    id: root

    signal formValuesChanged()

    property string selectedAccountAddress: ""
    property int selectedNetworkChainId: -1
    property string fromTokensKey: root.defaultFromTokenKey
    property string fromTokenAmount: ""
    property string toTokenKey: root.defaultToTokenKey
    property string toTokenAmount: ""
    property double selectedSlippage: 0.5

    // default to token key
    property string defaultToTokenKey: Utils.getNativeTokenSymbol(root.selectedNetworkChainId)
    // default from token key
    property string defaultFromTokenKey: Constants.tokenSymbolToUniqueSymbol(Constants.usdcToken, root.selectedNetworkChainId)
    // 15 seconds
    property int autoRefreshTime: 15000

    onSelectedAccountAddressChanged: root.formValuesChanged()
    onSelectedNetworkChainIdChanged: root.formValuesChanged()
    onFromTokensKeyChanged: root.formValuesChanged()
    onFromTokenAmountChanged: root.formValuesChanged()
    onToTokenKeyChanged: root.formValuesChanged()
    onToTokenAmountChanged: root.formValuesChanged()
    onSelectedSlippageChanged: root.formValuesChanged()

    function resetFormData() {
        root.selectedAccountAddress = ""
        root.selectedNetworkChainId = -1
        root.selectedSlippage = 0.5
        root.resetFromTokenValues()
        root.resetToTokenValues()
    }

    function resetFromTokenValues(keepDefault = true) {
        if(keepDefault) {
            root.fromTokensKey = root.defaultFromTokenKey
        } else {
            root.fromTokensKey = ""
        }
        root.fromTokenAmount = ""
    }

    function resetToTokenValues(keepDefault = true) {
        if(keepDefault) {
            root.toTokenKey = root.defaultToTokenKey
        } else {
            root.toTokenKey = ""
        }
        root.toTokenAmount = ""
    }

    function isFormFilledCorrectly() {
        let bigIntNumber = SQUtils.AmountsArithmetic.fromString(root.fromTokenAmount)
        return !!root.selectedAccountAddress &&
                root.selectedNetworkChainId !== -1 &&
                !!root.fromTokensKey && !!root.toTokenKey &&
                (!!root.fromTokenAmount && !isNaN(bigIntNumber) && bigIntNumber.gt(0)) &&
                root.selectedSlippage > 0
    }
}
