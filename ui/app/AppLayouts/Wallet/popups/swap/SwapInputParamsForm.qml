import QtQml 2.15

import StatusQ.Core.Utils 0.1 as SQUtils

import utils 1.0

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
    property string defaultToTokenKey: Constants.swap.ethTokenKey
    // default from token key
    property string defaultFromTokenKey: Constants.swap.usdcTokenKey
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
        selectedAccountAddress = ""
        selectedNetworkChainId = -1
        selectedSlippage = 0.5
        root.resetFromTokenValues()
        root.resetToTokenValues()
    }

    function resetFromTokenValues(keepDefault = true) {
        if(keepDefault) {
            fromTokensKey = root.defaultFromTokenKey
        } else {
            fromTokensKey = ""
        }
        fromTokenAmount = ""
    }

    function resetToTokenValues(keepDefault = true) {
        if(keepDefault) {
            toTokenKey = root.defaultToTokenKey
        } else {
            toTokenKey = ""
        }
        toTokenAmount = ""
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
