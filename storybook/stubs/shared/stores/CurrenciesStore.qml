import QtQuick

import StatusQ.Core
import StatusQ.Core.Utils as SQUtils

import utils

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

    function getCurrencyAmount(amount, key) {
        let currencyFormat = {
            amount: amount,
            tokenKey: key,
            symbol: "",
            displayDecimals: 0,
            stripTrailingZeroes: true
        }
        if (key === "") {
            return (currencyFormat)
        }

        currencyFormat["displayDecimals"] = 2

        const groupKeyToSymbol = new Map();
        groupKeyToSymbol.set(Constants.ethGroupKey, Constants.ethToken);
        groupKeyToSymbol.set(Constants.bnbGroupKey, Constants.bnbToken);
        groupKeyToSymbol.set(Constants.sntGroupKey, Constants.sntToken);
        groupKeyToSymbol.set(Constants.sttGroupKey, Constants.sttToken);
        groupKeyToSymbol.set(Constants.usdcGroupKeyEvm, Constants.usdcToken);
        groupKeyToSymbol.set(Constants.usdcGroupKeyBsc, Constants.usdcToken);
        groupKeyToSymbol.set(Constants.usdtGroupKeyEvm, "USDT");
        groupKeyToSymbol.set(Constants.daiGroupKey, "DAI");
        groupKeyToSymbol.set(Constants.aaveGroupKey, "AAVE");

        let symbol = groupKeyToSymbol.get(key)
        if (!!symbol) {
            currencyFormat["symbol"] = symbol
            return (currencyFormat)
        }

        const tokenKeyToSymbol = new Map();

        symbol = tokenKeyToSymbol.get(key)
        if (!!symbol) {
            currencyFormat["symbol"] = symbol
            return (currencyFormat)
        }

        currencyFormat["symbol"] = key
        return (currencyFormat)
    }

    function getCurrentCurrencyAmount(amount) {
        return getCurrencyAmount(amount, root.currentCurrency)
    }
}
