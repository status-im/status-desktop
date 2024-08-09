import QtQml 2.15

QtObject {
    id: root

    property string selectedWalletAddress: ""
    property int selectedNetworkChainId: -1
    property string selectedTokenKey: ""
    property string selectedProviderId: ""

    readonly property bool filledCorrectly: !!selectedWalletAddress && !!selectedTokenKey && selectedNetworkChainId !== -1

    function resetFormData() {
        selectedWalletAddress = ""
        selectedNetworkChainId = -1
        selectedTokenKey = ""
        selectedProviderId = ""
    }
}
