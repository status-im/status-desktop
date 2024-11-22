import QtQuick 2.15

QtObject {
    required property CurrenciesStore currencyStore
    required property var flatNetworksModel
    required property var processedAssetsModel
    required property var plainAssetsModel
    required property var accountsModel

    property var requestPaymentModel: null

    function addPaymentRequest(symbol, amount, address, chainId) {
        if (!requestPaymentModel)
            return
        requestPaymentModel.addPaymentRequest(address, amount, symbol, chainId)
    }

    function removePaymentRequest(index) {
        requestPaymentModel.removeItemWithIndex(index)
    }
}
