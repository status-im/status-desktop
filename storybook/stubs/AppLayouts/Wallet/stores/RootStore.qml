// This should not be a singleton. TODO: Remove it once the "real" Wallet root store is not a singleton anymore.
pragma Singleton

import QtQml

import utils
import Models

QtObject {
    id: root

    property bool showSavedAddresses
    property bool isAccountTokensReloading

    // TODO: Remove this. This stub should be empty. The color transformation should be done in adaptors or in the first model transformation steps.

    function savedAddressNameExists(name) {
        return false
    }

    function createOrUpdateSavedAddress(name, address, ens, colorId) {
        console.log("createOrUpdateSavedAddress")
    }

    function getNameForAddress(address) {
        return "NAMEFOR: %1".arg(Utils.compactAddress(address, 4))
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

    function getDappDetails(chainId, contractAddress) {
        return {
            "icon": ModelsData.icons.socks,
            "url": "https://somedummyurl.com",
            "name": "SomeDummyName",
            "approvalContractAddress": "0x6a000f20005980200259b80c5102003040001068",
            "swapContractAddress": "0xDEF171Fe48CF0115B1d80b88dc8eAB59176FEe57",
        }
    }

    function getTransactionType(transaction) {
        return transaction.txType
    }
}
