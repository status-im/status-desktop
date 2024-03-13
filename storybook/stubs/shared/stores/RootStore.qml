pragma Singleton

import QtQuick 2.14

QtObject {
    property var userProfileInst
    property bool gifUnfurlingEnabled
    property bool isWalletEnabled
    property var getSelectedTextWithFormationChars
    property var gifColumnA
    property var currentCurrency
    property bool neverAskAboutUnfurlingAgain: false

    property var currencyStore: CurrenciesStore {}
    property var history

    property var getFiatValue
    property var getLatestBlockNumber
    property var hex2Dec
    property var formatCurrencyAmount
    property var getNameForSavedWalletAddress
    property var getNameForAddress
    property var getEnsForSavedWalletAddress
    property var getChainShortNamesForSavedWalletAddress
    property var getGasEthValue
    property var flatNetworks

    function copyToClipboard(text) {
        console.warn("STUB: copyToClipboard:", text)
    }

    function setNeverAskAboutUnfurlingAgain(value) {
        console.log("STUB: setNeverAskAboutUnfurlingAgain:", value)
        neverAskAboutUnfurlingAgain = value
    }

    function getHistoricalDataForToken(symbol, currency) {
        console.log("STUB: getHistoricalDataForToken:", symbol, currency)
    }
}
