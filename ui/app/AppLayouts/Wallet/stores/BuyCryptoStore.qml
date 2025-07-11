import QtQuick

QtObject {
    id: root

    readonly property var providersModel: walletSectionBuySellCrypto.model
    readonly property bool areProvidersLoading: walletSectionBuySellCrypto.isFetching

    signal providerUrlReady(string uuid , string url)

    function fetchProviders() {
        walletSectionBuySellCrypto.fetchProviders()
    }

    function fetchProviderUrl(
        uuid,
        providerID,
        isRecurrent,
        selectedWalletAddress = "",
        chainID = 0,
        symbol = "") {
        walletSectionBuySellCrypto.fetchProviderUrl(
                    uuid,
                    providerID,
                    isRecurrent,
                    selectedWalletAddress,
                    chainID,
                    symbol
                    )
    }

    Component.onCompleted: {
        walletSectionBuySellCrypto.providerUrlReady.connect(root.providerUrlReady)
    }
}
