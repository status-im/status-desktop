import QtQuick

import StatusQ.Core
import StatusQ.Core.Utils as SQUtils

QtObject {
    id: root

    /*readonly*/ property string currentCurrency: "USD"

    function formatCurrencyAmount(amount, symbol, options = null, locale = null) {
        if (isNaN(amount)) {
            return "N/A"
        }
        var currencyAmount = getCurrencyAmount(amount, symbol)
        return LocaleUtils.currencyAmountToLocaleString(currencyAmount, options, locale)
    }

    function formatCurrencyAmountFromBigInt(balance, symbol, decimals, options = null) {
        let bigIntBalance = SQUtils.AmountsArithmetic.fromString(balance)
        let decimalBalance = SQUtils.AmountsArithmetic.toNumber(bigIntBalance, decimals)
        return formatCurrencyAmount(decimalBalance, symbol, options)
    }

    function getFiatValue(balance, cryptoSymbol) {
        return parseFloat(balance)
    }

    function getCryptoValue(balance, symbol) {
        return balance
    }

    function getCurrencyAmount(amount, symbol) {
        return ({
                    amount: amount,
                    symbol: symbol ? symbol.toUpperCase() : root.currentCurrency,
                    displayDecimals: 2,
                    stripTrailingZeroes: false
                })
    }

    function getCurrentCurrencyAmount(amount) {
        return getCurrencyAmount(amount, root.currentCurrency)
    }
}
