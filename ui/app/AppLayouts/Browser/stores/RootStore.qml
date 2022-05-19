pragma Singleton

import QtQuick 2.13

import utils 1.0

QtObject {
    id: root

    // Not Refactored Yet
//    property string activeChannelName: chatsModel.channelView.activeChannel.name

    property bool currentTabConnected: false

    function getUrlFromUserInput(input) {
        return globalUtils.urlFromUserInput(input)
    }

    function getAscii2Hex(input) {
        return globalUtils.ascii2Hex(input)
    }

    function getHex2Ascii(input) {
        return globalUtils.hex2Ascii(input)
    }

    function getWei2Eth(wei,decimals) {
        return globalUtils.wei2Eth(wei,decimals)
    }

    function getEth2Hex(eth) {
        return globalUtils.eth2Hex(eth)
    }

    function getGwei2Hex(gwei){
        return globalUtils.gwei2Hex(gwei)
    }

    function generateAlias(pk) {
        return globalUtils.generateAlias(pk)
    }

    function get0xFormedUrl(browserExplorer, url) {
        var tempUrl = ""
        switch (browserExplorer) {
        case Constants.browserEthereumExplorerEtherscan:
            if (url.length > 42) {
                tempUrl = "https://etherscan.io/tx/" + url; break;
            } else {
                tempUrl = "https://etherscan.io/address/" + url; break;
            }
        case Constants.browserEthereumExplorerEthplorer:
            if (url.length > 42) {
                tempUrl = "https://ethplorer.io/tx/" + url; break;
            } else {
                tempUrl = "https://ethplorer.io/address/" + url; break;
            }
        case Constants.browserEthereumExplorerBlockchair:
            if (url.length > 42) {
                tempUrl = "https://blockchair.com/ethereum/transaction/" + url; break;
            } else {
                tempUrl = "https://blockchair.com/ethereum/address/" + url; break;
            }
        }
        return tempUrl
    }

    function getFormedUrl(shouldShowBrowserSearchEngine, url) {
        var tempUrl = ""
        switch (localAccountSensitiveSettings.shouldShowBrowserSearchEngine) {
        case Constants.browserSearchEngineGoogle: tempUrl = "https://www.google.com/search?q=" + url; break;
        case Constants.browserSearchEngineYahoo: tempUrl = "https://search.yahoo.com/search?p=" + url; break;
        case Constants.browserSearchEngineDuckDuckGo: tempUrl = "https://duckduckgo.com/?q=" + url; break;
        }
        return tempUrl
    }

    function copyToClipboard(text) {
        globalUtils.copyToClipboard(text)
    }

}
