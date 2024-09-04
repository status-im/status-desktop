import QtQuick 2.15

QtObject {
    property var userProfileInst
    property bool gifUnfurlingEnabled
    property bool isWalletEnabled
    property var currentCurrency
    property bool neverAskAboutUnfurlingAgain: false

    property var currencyStore: CurrenciesStore {}
    property var history

    property var getFiatValue
    property var getLatestBlockNumber
    property var formatCurrencyAmount
    property var getNameForSavedWalletAddress
    property var getNameForAddress
    property var getEnsForSavedWalletAddress
    property var getChainShortNamesForSavedWalletAddress
    property var getGasEthValue
    property var flatNetworks

    function setNeverAskAboutUnfurlingAgain(value) {
        console.log("STUB: setNeverAskAboutUnfurlingAgain:", value)
        neverAskAboutUnfurlingAgain = value
    }

    function getHistoricalDataForToken(symbol, currency) {
        console.log("STUB: getHistoricalDataForToken:", symbol, currency)
    }
}
