import QtQuick

import StatusQ.Core
import StatusQ.Core.Utils as SQUtils

import utils
import AppLayouts.Profile.stores

QtObject {
    id: root

    // Some token+currency-related functions are implemented in the profileSectionModule.
    // We should probably refactor this and move those functions to some Wallet module.
    property var _profileSectionModuleInst: profileSectionModule

    readonly property var currenciesModel: CurrenciesModel {
        Component.onCompleted: setSelected(root.currentCurrency)
    }

    readonly property string currentCurrency: Global.appIsReady ? walletSection.currentCurrency : ""
    onCurrentCurrencyChanged: currenciesModel.setSelected(root.currentCurrency)

    function updateCurrency(shortName) {
        walletSection.updateCurrency(shortName)
    }

    function getCurrencyAmount(amount, symbol) {
        try {
            let jsonData = walletSection.getCurrencyAmount(amount, symbol)
            let obj = JSON.parse(jsonData)
            return obj
        } catch (e) {
            console.warn("Error parsing prepared currency amount: " + e)
            return {amount: 0, symbol: symbol, displayDecimals: 2, stripTrailingZeroes: false}
        }
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

    function formatBigNumber(number: string, symbol: string, noSymbolOption: bool): string  {
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

    function getCurrentCurrencyAmount(amount) {
        return getCurrencyAmount(amount, currentCurrency)
    }

    function hexToDec(hex) {
        return globalUtils.hexToDec(hex)
    }

    function hexToEth(value) {
        return hexToEthDenomination(value, "eth")
    }

    function hexToEthDenomination(value, ethUnit) {
        let BigOps = SQUtils.AmountsArithmetic
        if (ethUnit !== "qwei" && ethUnit !== "eth") {
            console.warn("unsuported conversion")
            return BigOps.fromNumber(0)
        }
        let unitMapping = {
            "gwei": 9,
            "eth": 18
        }
        let decValue = hexToDec(value)
        if (!!decValue) {
            return BigOps.div(BigOps.fromNumber(decValue), BigOps.fromNumber(1, unitMapping[ethUnit]))
        }
        return BigOps.fromNumber(0)
    }
}
