import QtQuick 2.15

QtObject {
    id: root

    readonly property string currentCurrency: "USD"
    property string currentCurrencySymbol: "$"

    function formatCurrencyAmount(amount, symbol, options = null, locale = null) {
        return amount
    }

    function getFiatValue(balance, cryptoSymbol, fiatSymbol) {
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
        return ({
                    amount: amount,
                    symbol: root.currentCurrency,
                    displayDecimals: 2,
                    stripTrailingZeroes: false
                })
    }
}
