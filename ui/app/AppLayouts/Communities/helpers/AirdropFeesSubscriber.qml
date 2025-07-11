import QtQuick

import StatusQ.Core

import utils
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
    //      nativeCryptoFee: {CurrencyAmount JSON},
    //      fiatFee: {CurrencyAmount JSON},
    //      contractUniqueKey: string,
    //      errorCode: ComputeFeeErrorCode (int)
    //    }],
    //    totalNativeCryptoFee: {CurrencyAmount JSON},
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

        if (!root.airdropFeesResponse || !Object.values(root.airdropFeesResponse.nativeCryptoCurrency).length || !Object.values(root.airdropFeesResponse.fiatCurrency).length) {
            return ""
        }

        return LocaleUtils.currencyAmountToLocaleString(root.airdropFeesResponse.nativeCryptoCurrency)
                + " (" + LocaleUtils.currencyAmountToLocaleString(root.airdropFeesResponse.fiatCurrency) + ")"
    }

    readonly property var feesPerContract: {
        if (!root.airdropFeesResponse || !Object.values(root.airdropFeesResponse.fees).length || totalFee == "")
            return []

        return root.airdropFeesResponse.fees.map(fee => {
            return {
                contractUniqueKey: fee.contractUniqueKey,
                feeText: `${LocaleUtils.currencyAmountToLocaleString(fee.nativeCryptoFee)} (${LocaleUtils.currencyAmountToLocaleString(fee.fiatFee)})`
            }
        })
    }
}
