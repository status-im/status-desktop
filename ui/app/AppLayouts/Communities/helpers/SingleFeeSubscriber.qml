import QtQuick

import StatusQ.Core
import utils

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
        if (!root.feesResponse) {
            return ""
        }


        if (!!root.feesResponse.error) {
            return "-"
        }

        if (!root.feesResponse || !Object.values(root.feesResponse.nativeCryptoCurrency).length || !Object.values(root.feesResponse.fiatCurrency).length) {
            return ""
        }

        return LocaleUtils.currencyAmountToLocaleString(root.feesResponse.nativeCryptoCurrency)
                + " (" + LocaleUtils.currencyAmountToLocaleString(root.feesResponse.fiatCurrency) + ")"
    }
    readonly property string feeErrorText: {
        if (!root.feesResponse)
            return ""

        return root.feesResponse.error
    }
}
