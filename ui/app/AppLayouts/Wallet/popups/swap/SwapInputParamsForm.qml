import QtQml 2.15

import StatusQ.Core.Utils 0.1 as SQUtils

/* This is used so that there is an easy way to fill in the data
needed to launch the Swap Modal with pre-filled requisites. */
QtObject {
    id: root

    signal formValuesChanged()

    property int selectedAccountIndex: 0
    property int selectedNetworkChainId: -1
    property string fromTokensKey: ""
    property string fromTokenAmount: "0"
    property string toTokenKey: ""
    property string toTokenAmount: "0"
    property double selectedSlippage: 0.5

    onSelectedAccountIndexChanged: root.formValuesChanged()
    onSelectedNetworkChainIdChanged: root.formValuesChanged()
    onFromTokensKeyChanged: root.formValuesChanged()
    onFromTokenAmountChanged: root.formValuesChanged()
    onToTokenKeyChanged: root.formValuesChanged()
    onToTokenAmountChanged: root.formValuesChanged()

    function resetFormData() {
        selectedAccountIndex = 0
        selectedNetworkChainId = -1
        fromTokensKey = ""
        fromTokenAmount = "0"
        toTokenKey = ""
        toTokenAmount = "0"
        selectedSlippage = 0.5
    }

    function isFormFilledCorrectly() {
        return root.selectedAccountIndex >= 0 &&
                root.selectedNetworkChainId !== -1 &&
                !!root.fromTokensKey && !!root.toTokenKey &&
                ((!!root.fromTokenAmount &&
                  !isNaN(SQUtils.AmountsArithmetic.fromString(root.fromTokenAmount)) &&
                  SQUtils.AmountsArithmetic.fromString(root.fromTokenAmount) > 0) ||
                 (!!root.toTokenAmount &&
                  !isNaN(SQUtils.AmountsArithmetic.fromString(root.toTokenAmount)) &&
                  SQUtils.AmountsArithmetic.fromString(root.toTokenAmount) > 0 )) &&
                root.selectedSlippage > 0
    }
}
