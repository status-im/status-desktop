import QtQuick 2.13

import StatusQ.Core 0.1

import utils 1.0

QtObject {
    id: root

    readonly property var networkConnectionModuleInst: networkConnectionModule

    readonly property var blockchainNetworksDown: networkConnectionModule.blockchainNetworkConnection.chainIds.split(";")
    readonly property bool atleastOneBlockchainNetworkAvailable: blockchainNetworksDown.length <  networksModule.all.count

    readonly property bool sendBuyBridgeEnabled: localAppSettings.testEnvironment || (mainModule.isOnline &&
                                        (!networkConnectionModule.blockchainNetworkConnection.completelyDown && atleastOneBlockchainNetworkAvailable) &&
                                        !networkConnectionModule.marketValuesNetworkConnection.completelyDown)
    readonly property string sendBuyBridgeToolTipText: !mainModule.isOnline ?
                                                  qsTr("Requires internet connection") :
                                                  networkConnectionModule.blockchainNetworkConnection.completelyDown ||
                                                   (!networkConnectionModule.blockchainNetworkConnection.completelyDown &&
                                                    !atleastOneBlockchainNetworkAvailable) ?
                                                  qsTr("Requires Pocket Network(POKT) or Infura, both of which are currently unavailable") :
                                                  networkConnectionModule.marketValuesNetworkConnection.completelyDown ?
                                                  qsTr("Requires CryptoCompare or CoinGecko, both of which are currently unavailable"):
                                                  qsTr("Requires POKT/ Infura and CryptoCompare/CoinGecko, which are all currently unavailable")


    readonly property bool tokenBalanceNotAvailable: ((!mainModule.isOnline || networkConnectionModule.blockchainNetworkConnection.completelyDown) &&
                                            !walletSectionCurrent.assetsLoading && walletSectionCurrent.assets.count === 0) ||
                                             (networkConnectionModule.marketValuesNetworkConnection.completelyDown &&
                                              !networkConnectionModule.marketValuesNetworkConnection.withCache)
    readonly property string tokenBalanceNotAvailableText: !mainModule.isOnline ?
                                                          qsTr("Internet connection lost. Data could not be retrieved.") :
                                                          networkConnectionModule.blockchainNetworkConnection.completelyDown ?
                                                          qsTr("Token balances are fetched from Pocket Network (POKT) and Infura which are both curently unavailable") :
                                                          networkConnectionModule.marketValuesNetworkConnection.completelyDown ?
                                                          qsTr("Market values are fetched from CryptoCompare and CoinGecko which are both currently unavailable") :
                                                          qsTr("Market values and token balances use CryptoCompare/CoinGecko and POKT/Infura which are all currently unavailable.")

    function getBlockchainNetworkDownTextForToken(balances) {
        if(!!balances && !networkConnectionModule.blockchainNetworkConnection.completelyDown) {
            let chainIdsDown = []
            for (var i =0; i<balances.count; i++) {
                let chainId = balances.rowData(i, "chainId")
                if(blockchainNetworksDown.includes(chainId))
                    chainIdsDown.push(chainId)
            }
            if(chainIdsDown.length > 0) {
                return qsTr("Pocket Network (POKT) & Infura are currently both unavailable for %1. %1 balances are as of %2.")
                .arg(getChainIdsJointString(chainIdsDown))
                .arg(LocaleUtils.formatDateTime(new Date(networkConnectionModule.blockchainNetworkConnection.lastCheckedAt*1000)))
            }
        }
        return ""
    }

    function getMarketNetworkDownText() {
        if(networkConnectionModule.blockchainNetworkConnection.completelyDown &&
                !walletSectionCurrent.assetsLoading && walletSectionCurrent.assets.count === 0 &&
                networkConnectionModule.marketValuesNetworkConnection.completelyDown &&
                !networkConnectionModule.marketValuesNetworkConnection.withCache)
            return qsTr("Market values and token balances use CryptoCompare/CoinGecko and POKT/Infura which are all currently unavailable.")
        else if(networkConnectionModule.marketValuesNetworkConnection.completelyDown &&
                !networkConnectionModule.marketValuesNetworkConnection.withCache)
            return qsTr("Market values are fetched from CryptoCompare and CoinGecko which are both currently unavailable")
        else
            return ""
    }

    function getChainIdsJointString(chainIdsDown) {
        let jointChainIdString = ""
        for (const chain of chainIdsDown) {
            jointChainIdString = (!!jointChainIdString) ? jointChainIdString + " & " : jointChainIdString
            jointChainIdString +=  networksModule.all.getNetworkFullName(parseInt(chain))
        }
        return jointChainIdString
    }

    function retryConnection(websiteDown) {
        switch(websiteDown) {
        case Constants.walletConnections.blockchains:
            networkConnectionModule.refreshBlockchainValues()
            break
        case Constants.walletConnections.market:
            networkConnectionModule.refreshMarketValues()
            break
        case Constants.walletConnections.collectibles:
            networkConnectionModule.refreshCollectiblesValues()
            break
        }
    }
}
