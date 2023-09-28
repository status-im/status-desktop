import QtQuick 2.15

import StatusQ.Core 0.1
import utils 1.0

/*!
    \qmltype SingleFeeSubscriber
    \inherits QtObject
    \brief Helper object that parses fees response and provides fee text and error text for single fee response
*/

 QtObject {
    id: root

    // Published properties
    property var feesResponse

    // Internal properties based on response
    readonly property string feeText: {
        if (!feesResponse || !Object.values(feesResponse.ethCurrency).length || !Object.values(feesResponse.fiatCurrency).length)  return ""
        
        if (feesResponse.errorCode !== Constants.ComputeFeeErrorCode.Success && feesResponse.errorCode !== Constants.ComputeFeeErrorCode.Balance)
            return ""

        return LocaleUtils.currencyAmountToLocaleString(feesResponse.ethCurrency)
                + " (" + LocaleUtils.currencyAmountToLocaleString(feesResponse.fiatCurrency) + ")"
    }
    readonly property string feeErrorText: {
        if (!feesResponse)  return ""
        if (feesResponse.errorCode === Constants.ComputeFeeErrorCode.Success) return ""

        if (feesResponse.errorCode === Constants.ComputeFeeErrorCode.Balance)
            return qsTr("Not enough funds to make transaction")

        if (feesResponse.errorCode === Constants.ComputeFeeErrorCode.Infura)
            return qsTr("Infura error")

        return qsTr("Unknown error")
    }
}
