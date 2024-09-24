import QtQuick 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

import utils 1.0
import AppLayouts.Profile.stores 1.0

QtObject {
    id: root

    // Some token+currency-related functions are implemented in the profileSectionModule.
    // We should probably refactor this and move those functions to some Wallet module.
    property var _profileSectionModuleInst: profileSectionModule

    readonly property string currentCurrency: Global.appIsReady ? walletSection.currentCurrency : ""

    function updateCurrency(shortName) {
        walletSection.updateCurrency(shortName)
    }

    // The object returned by this sometimes becomes null when used as part of a binding expression.
    // Will probably be solved when moving to C++, for now avoid storing the result of this function and use
    // formatCurrencyAmount at the visualization point instead, or move functionality over to the NIM side.
    function getCurrencyAmount(amount, symbol) {
        walletSection.prepareCurrencyAmount(amount, symbol)
        return walletSection.getPreparedCurrencyAmount()
    }

    function formatCurrencyAmount(amount, symbol, options = null, locale = null) {
        if (isNaN(amount)) {
            return qsTr("N/A")
        }
        var currencyAmount = getCurrencyAmount(amount, symbol)
        return LocaleUtils.currencyAmountToLocaleString(currencyAmount, options, locale)
    }

    function formatCurrencyAmountFromBigInt(balance, symbol, decimals, options = null) {
        let bigIntBalance = SQUtils.AmountsArithmetic.fromString(balance)
        let decimalBalance = SQUtils.AmountsArithmetic.toNumber(bigIntBalance, decimals)
        return formatCurrencyAmount(decimalBalance, symbol, options)
    }

    function formatBigNumber(number: string, symbol: string, noSymbolOption: bool) {
        if (!number)
            return "N/A"
        if (!symbol)
            symbol = root.currentCurrency
        let options = {}
        if (!!noSymbolOption)
            options = {noSymbol: true}
        return formatCurrencyAmount(parseFloat(number), symbol, options)
    }

    function getFiatValue(cryptoAmount, cryptoSymbol) {
        var amount = _profileSectionModuleInst.ensUsernamesModule.getFiatValue(cryptoAmount, cryptoSymbol)
        return parseFloat(amount)
    }

    function getCryptoValue(fiatAmount, cryptoSymbol) {
        var amount = _profileSectionModuleInst.ensUsernamesModule.getCryptoValue(fiatAmount, cryptoSymbol)
        return parseFloat(amount)
    }

    function getGasEthValue(gweiValue, gasLimit) {
        var amount = _profileSectionModuleInst.ensUsernamesModule.getGasEthValue(gweiValue, gasLimit)
        return parseFloat(amount)
    }

    function getCurrentCurrencyAmount(amount) {
        return getCurrencyAmount(amount, currentCurrency)
    }
}
