pragma Singleton

import QtQml 2.14

QtObject {

    function fractionalPartLength(num) {
        if (Number.isInteger(num))
            return 0

        return num.toString().split('.')[1].length
    }

    function stripTrailingZeroes(numStr, locale) {
        let regEx = locale.decimalPoint == "." ? /(\.[0-9]*[1-9])0+$|\.0*$/ : /(\,[0-9]*[1-9])0+$|\,0*$/
        return numStr.replace(regEx, '$1')
    }

    function numberToLocaleString(num, precision = -1, locale = null) {
        locale = locale || Qt.locale()

        if (precision === -1)
            precision = fractionalPartLength(num)

        return num.toLocaleString(locale, 'f', precision)
    }

    function currencyAmountToLocaleString(currencyAmount, locale) {
        if (!locale) {
            console.log("Unspecified locale for: " + JSON.stringify(currencyAmount))
            locale = Qt.locale()
        }
        if (typeof(currencyAmount) !== "object") {
            console.log("Wrong type for currencyAmount: " + JSON.stringify(currencyAmount))
            return NaN
        }
        var amountStr = numberToLocaleString(currencyAmount.amount, currencyAmount.displayDecimals, locale)
        if (currencyAmount.stripTrailingZeroes) {
            amountStr = stripTrailingZeroes(amountStr, locale)
        }
        if (currencyAmount.symbol) {
            amountStr = "%1 %2".arg(amountStr).arg(currencyAmount.symbol)
        }
        return amountStr
    }
}
