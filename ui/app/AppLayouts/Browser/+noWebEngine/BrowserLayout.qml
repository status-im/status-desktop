import QtQuick

import StatusQ.Layout

import AppLayouts.stores.Browser as BrowserStores

// dummy container/section for mobile
StatusSectionLayout {
    required property string userUID
    required property bool thirdpartyServicesEnabled

    property var transactionStore
    property var assetsStore
    property var currencyStore
    property var tokensStore
    property var networksStore

    property BrowserStores.BookmarksStore bookmarksStore
    property BrowserStores.DownloadsStore downloadsStore
    property BrowserStores.BrowserRootStore browserRootStore
    property BrowserStores.BrowserWalletStore browserWalletStore
    property BrowserStores.BrowserActivityStore browserActivityStore

    required property var connectorController
    property bool isDebugEnabled: false

    signal sendToRecipientRequested(string address)
}
