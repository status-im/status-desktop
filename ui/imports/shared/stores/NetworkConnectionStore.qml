import QtQuick 2.13

import SortFilterProxyModel 0.2

import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1

import utils 1.0

QtObject {
    id: root

    readonly property var networkConnectionModuleInst: networkConnectionModule

    readonly property bool isOnline: mainModule.isOnline

    readonly property bool balanceCache: walletSectionAssets.hasBalanceCache
    readonly property bool marketValuesCache: walletSectionAssets.hasMarketValuesCache

    readonly property SortFilterProxyModel filteredflatNetworks: SortFilterProxyModel {
                                                          sourceModel: networksModule.flatNetworks
                                                          filters: ValueFilter { roleName: "isTest"; value: networksModule.areTestNetworksEnabled }
                                                      }

    readonly property var blockchainNetworksDown: !!networkConnectionModule.blockchainNetworkConnection.chainIds ? networkConnectionModule.blockchainNetworkConnection.chainIds.split(";") : []
    readonly property bool atleastOneBlockchainNetworkAvailable: blockchainNetworksDown.length < filteredflatNetworks.count

    readonly property bool sendBuyBridgeEnabled: localAppSettings.testEnvironment || (isOnline &&
                                        (!networkConnectionModule.blockchainNetworkConnection.completelyDown && atleastOneBlockchainNetworkAvailable) &&
                                        !networkConnectionModule.marketValuesNetworkConnection.completelyDown)
    readonly property string sendBuyBridgeToolTipText: !isOnline ? qsTr("Requires internet connection") :
                                                        noBlockchainAndMarketConnectionAndNoCache ?
                                                        qsTr("Requires POKT/Infura and CryptoCompare/CoinGecko, which are all currently unavailable") :
                                                        networkConnectionModule.blockchainNetworkConnection.completelyDown ||
                                                        (!networkConnectionModule.blockchainNetworkConnection.completelyDown &&
                                                        !atleastOneBlockchainNetworkAvailable) ?
                                                        qsTr("Requires Pocket Network(POKT) or Infura, both of which are currently unavailable") :
                                                        networkConnectionModule.marketValuesNetworkConnection.completelyDown ?
                                                        qsTr("Requires CryptoCompare or CoinGecko, both of which are currently unavailable"): ""

    readonly property bool notOnlineWithNoCache: !isOnline && !balanceCache && !marketValuesCache
    readonly property string notOnlineWithNoCacheText: qsTr("Internet connection lost. Data could not be retrieved.")

    readonly property bool noBlockchainConnectionAndNoCache: networkConnectionModule.blockchainNetworkConnection.completelyDown && !balanceCache
    readonly property string noBlockchainConnectionAndNoCacheText: qsTr("Token balances are fetched from Pocket Network (POKT) and Infura which are both curently unavailable")

    readonly property bool noMarketConnectionAndNoCache: networkConnectionModule.marketValuesNetworkConnection.completelyDown && !marketValuesCache
    readonly property string noMarketConnectionAndNoCacheText: qsTr("Market values are fetched from CryptoCompare and CoinGecko which are both currently unavailable")

    readonly property bool noBlockchainAndMarketConnectionAndNoCache: noBlockchainConnectionAndNoCache && noMarketConnectionAndNoCache
    readonly property string noBlockchainAndMarketConnectionAndNoCacheText: qsTr("Market values and token balances use CryptoCompare/CoinGecko and POKT/Infura which are all currently unavailable.")

    readonly property bool accountBalanceNotAvailable: notOnlineWithNoCache || noBlockchainConnectionAndNoCache || noMarketConnectionAndNoCache
    readonly property string accountBalanceNotAvailableText: !isOnline ? notOnlineWithNoCacheText :
                                                             noBlockchainAndMarketConnectionAndNoCache ? noBlockchainAndMarketConnectionAndNoCacheText :
                                                             networkConnectionModule.blockchainNetworkConnection.completelyDown ? noBlockchainConnectionAndNoCacheText :
                                                             networkConnectionModule.marketValuesNetworkConnection.completelyDown ? noBlockchainAndMarketConnectionAndNoCacheText : ""

    readonly property bool noTokenBalanceAvailable: notOnlineWithNoCache || noBlockchainConnectionAndNoCache

    readonly property bool ensNetworkAvailable: !blockchainNetworksDown.includes(mainModule.appNetworkId.toString())
    readonly property string ensNetworkUnavailableText: qsTr("Requires POKT/Infura for %1, which is currently unavailable").arg(appNetworkName)
    readonly property bool stickersNetworkAvailable: !blockchainNetworksDown.includes(mainModule.appNetworkId.toString())
    readonly property string stickersNetworkUnavailableText: qsTr("Requires POKT/Infura for %1, which is currently unavailable").arg(appNetworkName)
    readonly property string appNetworkName: ModelUtils.getByKey(networksModule.flatNetworks, "chainId", mainModule.appNetworkId, "chainName")

    // DEPRECATED, use getBlockchainNetworkDownText instead
    function getBlockchainNetworkDownTextForToken(balances) {
        if(!!balances && !networkConnectionModule.blockchainNetworkConnection.completelyDown && !notOnlineWithNoCache) {
            let chainIdsDown = []
            for (var i =0; i<balances.count; i++) {
                let chainId = ModelUtils.get(i, "chainId")
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

    function getBlockchainNetworkDownText(chains) {
        if (chains.length === 0
                || networkConnectionModule.blockchainNetworkConnection.completelyDown
                || notOnlineWithNoCache)
            return ""

        let chainIdsDown = []

        for (let i = 0; i < chains.length; i++) {
            const chainId = chains[i]
            if(blockchainNetworksDown.includes(chainId))
                chainIdsDown.push(chainId)
        }
        if(chainIdsDown.length > 0) {
            return qsTr("Pocket Network (POKT) & Infura are currently both unavailable for %1. %1 balances are as of %2.")
            .arg(getChainIdsJointString(chainIdsDown))
            .arg(LocaleUtils.formatDateTime(new Date(networkConnectionModule.blockchainNetworkConnection.lastCheckedAt * 1000)))
        }

        return ""
    }

    function getMarketNetworkDownText() {
        if(notOnlineWithNoCache)
            return notOnlineWithNoCacheText
        else if(noBlockchainAndMarketConnectionAndNoCache)
            return noBlockchainAndMarketConnectionAndNoCacheText
        else if(noMarketConnectionAndNoCache)
            return noMarketConnectionAndNoCacheText
        else
            return ""
    }

    function getChainIdsJointString(chainIdsDown) {
        let jointChainIdString = ""
        for (const chain of chainIdsDown) {
            jointChainIdString = (!!jointChainIdString) ? jointChainIdString + " & " : jointChainIdString
            jointChainIdString += ModelUtils.getByKey(networksModule.flatNetworks, "chainId", parseInt(chain), "chainName")
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
