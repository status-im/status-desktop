pragma Singleton

import QtQuick 2.14

QtObject {
    property var userProfileInst
    property bool isTenorWarningAccepted
    property bool isGifWidgetEnabled
    property bool isWalletEnabled
    property var getSelectedTextWithFormationChars
    property var gifColumnA
    property var currentCurrency

    property var currencyStore

    property var getNetworkIcon
    property var getFiatValue
    property var getLatestBlockNumber
    property var hex2Dec
    property var getNetworkColor
    property var getNetworkFullName
    property var getNetworkShortName
    property var formatCurrencyAmount
    property var getNameForSavedWalletAddress
    property var getNameForAddress
    property var getEnsForSavedWalletAddress
    property var getChainShortNamesForSavedWalletAddress
    property var getGasEthValue
    property var getNetworkLayer
}
