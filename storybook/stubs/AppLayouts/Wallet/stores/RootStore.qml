// This should not be a singleton. TODO: Remove it once the "real" Wallet root store is not a singleton anymore.
pragma Singleton

import QtQml 2.15

QtObject {
    id: root

    // TODO: Remove this. This stub should be empty. The color transformation should be done in adaptors or in the first model transformation steps.

    function savedAddressNameExists(name) {
        return false
    }

    function createOrUpdateSavedAddress(name, address, ens, colorId) {
        console.log("createOrUpdateSavedAddress")
    }

    function getNameForAddress(address) {
        return "NAMEFOR: %1".arg(address)
    }

    function getExplorerNameForNetwork(networkName) {
        return qsTr("%1 Explorer").arg(networkName)
    }

    function getExplorerUrl(networkShortName, contractAddress, tokenId) {
        return "https://somedummyurl.com"
    }

    function getOpenSeaCollectionUrl(networkShortName, contractAddress) {
        return "https://somedummyurl.com"
    }

    function getOpenSeaCollectibleUrl(networkShortName, contractAddress, tokenId) {
        return "https://somedummyurl.com"
    }
}
