import QtQuick 2.15

import StatusQ.Core 0.1

import utils 1.0
/*!
    \qmltype AirdropFeesSubscriber
    \inherits QtObject
    \brief Helper object that holds the request data and the fee response when available
*/

QtObject {
    id: root

    required property string communityId
    required property var contractKeysAndAmounts
    required property var addressesToAirdrop
    required property string feeAccountAddress
    required property bool enabled

    // JS object specifing fees for the airdrop operation, should be set to
    // provide response to airdropFeesRequested signal.
    //
    // The expected structure is as follows:
    // {
    //    fees: [{
    //      ethFee: {CurrencyAmount JSON},
    //      fiatFee: {CurrencyAmount JSON},
    //      contractUniqueKey: string,
    //      errorCode: ComputeFeeErrorCode (int)
    //    }],
    //    totalEthFee: {CurrencyAmount JSON},
    //    totalFiatFee: {CurrencyAmount JSON},
    //    errorCode: ComputeFeeErrorCode (int)
    // }
    property var airdropFeesResponse: null

    readonly property string feesError: {
        if (!airdropFeesResponse)  return ""

        if (airdropFeesResponse.errorCode === Constants.ComputeFeeErrorCode.Success) return ""

        if (airdropFeesResponse.errorCode === Constants.ComputeFeeErrorCode.Balance)
            return qsTr("Your account does not have enough ETH to pay the gas fee for this airdrop. Try adding some ETH to your account.")

        if (airdropFeesResponse.errorCode === Constants.ComputeFeeErrorCode.Infura)
            return qsTr("Infura error")

        return qsTr("Unknown error")
    }
    readonly property string totalFee: {
        if (!airdropFeesResponse || !Object.values(airdropFeesResponse.totalEthFee).length || !Object.values(airdropFeesResponse.totalFiatFee).length)  return ""

        if (airdropFeesResponse.errorCode !== Constants.ComputeFeeErrorCode.Success && airdropFeesResponse.errorCode !== Constants.ComputeFeeErrorCode.Balance)
            return ""

        return `${LocaleUtils.currencyAmountToLocaleString(airdropFeesResponse.totalEthFee)} (${LocaleUtils.currencyAmountToLocaleString(airdropFeesResponse.totalFiatFee)})`
    }

    readonly property var feesPerContract: {
        if (!airdropFeesResponse || !Object.values(airdropFeesResponse.fees).length || totalFee == "")  return []

        return airdropFeesResponse.fees.map(fee => {
            return {
                contractUniqueKey: fee.contractUniqueKey,
                feeText: `${LocaleUtils.currencyAmountToLocaleString(fee.ethFee)} (${LocaleUtils.currencyAmountToLocaleString(fee.fiatFee)})`
            }
        })
    }
}
