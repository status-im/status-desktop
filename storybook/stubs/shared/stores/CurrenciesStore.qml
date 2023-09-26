import QtQuick 2.15

QtObject {
    readonly property string currentCurrency: "USD"
    property string currentCurrencySymbol: "$"

    function formatCurrencyAmount(amount, symbol, options = null, locale = null) {
        return amount
    }

    function getFiatValue(balance, cryptoSymbol, fiatSymbol) {
        return balance
    }
}
