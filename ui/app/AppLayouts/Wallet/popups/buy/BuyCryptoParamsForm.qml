import QtQml 2.15

import utils 1.0
QtObject {
    id: root

    property string selectedWalletAddress: ""
    property int selectedNetworkChainId: -1
    property string selectedTokenKey: defaultTokenKey
    property string selectedProviderId: ""

    readonly property bool filledCorrectly: !!selectedWalletAddress && !!selectedTokenKey && selectedNetworkChainId !== -1

    property string defaultTokenKey: Utils.getNativeTokenSymbol(root.selectedNetworkChainId)

    function resetFormData() {
        selectedWalletAddress = ""
        selectedNetworkChainId = -1
        selectedTokenKey = defaultTokenKey
        selectedProviderId = ""
    }
}
