pragma Singleton

import QtQuick 2.13

import utils 1.0

QtObject {
    id: root

    property string activeChannelName: chatsModel.channelView.activeChannel.name

    property var currentNetwork: profileModel.network.current

    property bool currentTabConnected: false

    function getUrlFromUserInput(input) {
        return utilsModel.urlFromUserInput(input)
    }

    function getAscii2Hex(input) {
        return utilsModel.ascii2Hex(input)
    }

    function getHex2Ascii(input) {
        return utilsModel.hex2Ascii(input)
    }

    function getWei2Eth(wei,decimals) {
        return utilsModel.wei2Eth(wei,decimals)
    }

    function generateIdenticon(pk) {
        return utilsModel.generateIdenticon(pk)
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
}
