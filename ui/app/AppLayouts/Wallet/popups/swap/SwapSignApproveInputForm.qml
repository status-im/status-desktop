import QtQml 2.15

/* This is used so that there is an easy way to fill in the data
needed to launch the Approve/Sign Modal with pre-filled requisites. */
QtObject {
    id: root

    required property string selectedAccountAddress
    required property int selectedNetworkChainId
    required property string fromTokensKey
    required property string fromTokensAmount
    required property string toTokensKey
    required property string toTokensAmount
    required property double selectedSlippage
    // TODO: this should be string but backend gas_estimate_item.nim passes this as float
    required property double swapFees

    // need to check how this is done in new router, right now it is Enum type
    required property int estimatedTime
    required property string swapProviderName
    required property string approvalGasFees
    required property string approvalAmountRequired
    required property string approvalContractAddress


}
