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
        if (!root.airdropFeesResponse)
            return ""

        return root.airdropFeesResponse.error
    }
    readonly property string totalFee: {
        if (!root.airdropFeesResponse) {
            return ""
        }

        if (!!root.airdropFeesResponse.error) {
            return "-"
        }

        if (!root.airdropFeesResponse || !Object.values(root.airdropFeesResponse.ethCurrency).length || !Object.values(root.airdropFeesResponse.fiatCurrency).length) {
            return ""
        }

        return LocaleUtils.currencyAmountToLocaleString(root.airdropFeesResponse.ethCurrency)
                + " (" + LocaleUtils.currencyAmountToLocaleString(root.airdropFeesResponse.fiatCurrency) + ")"
    }

    readonly property var feesPerContract: {
        if (!root.airdropFeesResponse || !Object.values(root.airdropFeesResponse.fees).length || totalFee == "")
            return []

        return root.airdropFeesResponse.fees.map(fee => {
            return {
                contractUniqueKey: fee.contractUniqueKey,
                feeText: `${LocaleUtils.currencyAmountToLocaleString(fee.ethFee)} (${LocaleUtils.currencyAmountToLocaleString(fee.fiatFee)})`
            }
        })
    }
}
