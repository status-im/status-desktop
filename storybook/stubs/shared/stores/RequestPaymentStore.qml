import QtQuick 2.15

QtObject {
    required property CurrenciesStore currencyStore
    required property var flatNetworksModel
    required property var processedAssetsModel
    required property var accountsModel

    property var requestPaymentModel: ListModel {}

    function addPaymentRequest(symbol, amount, address, chainId) {
        requestPaymentModel.append({
            symbol: symbol,
            amount: amount,
            address: address,
            chainId: chainId
        })
    }

    function removePaymentRequest(index) {
        requestPaymentModel.remove(index)
    }
}
