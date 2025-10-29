import QtCore
import QtQuick
import QtQuick.Controls
import QtQml

import StatusQ
import StatusQ.Core.Utils as SQUtils

import Models
import Storybook

import utils

import AppLayouts.Browser
import AppLayouts.Browser.stores as BrowserStores
import AppLayouts.Browser.nim as BrowserNim

import AppLayouts.Wallet.stores
import shared.stores
import shared.stores.send

Item {
    id: root

    BrowserLayout {
        id: browserLayout
        anchors.fill: parent
        userUID: "0xdeadbeef"
        transactionStore: TransactionStore {}
        thirdpartyServicesEnabled: true
        connectorController: BrowserNim.ConnectorController {}

        bookmarksStore: BrowserStores.BookmarksStore {
            property var bookmarksModel: ListModel {}
            function addBookmark(url, name) {}
            function deleteBookmark(url) {}
            function updateBookmark(originalUrl, newUrl, newName) {}
            function getBookmarkIndexByUrl(url) {}
            function getCurrentFavorite(url) {}
        }
        downloadsStore: BrowserStores.DownloadsStore {
            property ListModel downloadModel : ListModel {
                property var downloads: []
            }
            function getDownload(index) {
                return downloadModel.downloads[index]
            }
        }
        browserRootStore: BrowserStores.BrowserRootStore {
            property bool currentTabConnected
            property var urlENSDictionary: ({})

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
                switch (browserLayout.localAccountSensitiveSettings.shouldShowBrowserSearchEngine) {
                case Constants.browserSearchEngineGoogle: tempUrl = "https://www.google.com/search?q=" + url; break;
                case Constants.browserSearchEngineYahoo: tempUrl = "https://search.yahoo.com/search?p=" + url; break;
                case Constants.browserSearchEngineDuckDuckGo: tempUrl = "https://duckduckgo.com/?q=" + url; break;
                }
                return tempUrl
            }

            function determineRealURL(text) {
                return UrlUtils.urlFromUserInput(text)
            }
            
            function obtainAddress(url) {
                return url
            }
        }
        browserWalletStore: BrowserStores.BrowserWalletStore {
            property var dappBrowserAccount: ({address:"0xdeadbeef", name: "Foobar", colorId: 0})
            property var accounts: []
            property string defaultCurrency: "USD"
            property string signingPhrase

            function getEtherscanLink(chainID) {
                return "https://etherscan.io/tx/"
            }

            function switchAccountByAddress(address) {
                dappBrowserAccount.address = address
            }
        }

        readonly property var localAccountSensitiveSettings: Settings {
            property bool devToolsEnabled
            property bool compatibilityMode: true
            property bool shouldShowFavoritesBar
            property int useBrowserEthereumExplorer: Constants.browserEthereumExplorerEtherscan
            property int shouldShowBrowserSearchEngine: Constants.browserSearchEngineGoogle

            property bool autoLoadImages: true
            property bool javaScriptEnabled: true
            property bool errorPageEnabled: true
            property bool pluginsEnabled: true
            property bool autoLoadIconsForPage: true
            property bool touchIconsEnabled: SQUtils.Utils.isMobile
            property bool webRTCPublicInterfacesOnly
            property bool pdfViewerEnabled: true
            property bool focusOnNavigationEnabled: true
        }

        onSendToRecipientRequested: (address) => console.warn("!!! SEND TO:", address)
    }
}

// category: Sections
// status: good
