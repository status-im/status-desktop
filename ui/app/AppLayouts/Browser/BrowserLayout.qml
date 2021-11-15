import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtWebEngine 1.10
import QtWebChannel 1.13
import Qt.labs.settings 1.0
import QtQuick.Controls.Styles 1.0
import QtQuick.Dialogs 1.2

import utils 1.0
import shared.controls 1.0

import shared 1.0
import shared.status 1.0

import "popups"
import "controls"
import "views"
import "panels"
import "stores"
import "../Chat/popups"

// Code based on https://code.qt.io/cgit/qt/qtwebengine.git/tree/examples/webengine/quicknanobrowser/BrowserWindow.qml?h=5.15 
// Licensed under BSD

Rectangle {
    id: browserWindow

    property var globalStore
    property Item currentWebView: tabs.currentIndex < tabs.count ? tabs.getTab(tabs.currentIndex).item : null

    property Component browserDialogComponent: BrowserDialog {
        onClosing: destroy()
    }

    property Component jsDialogComponent: JSDialogWindow {}

    property bool currentTabConnected: false

    property Component accessDialogComponent: BrowserConnectionModal {
        currentTab: tabs.getTab(tabs.currentIndex) && tabs.getTab(tabs.currentIndex).item
        x: browserWindow.width - width - Style.current.halfPadding
        y: browserHeader.y + browserHeader.height + Style.current.halfPadding
    }

    // TODO we'll need a new dialog at one point because this one is not using the same call, but it's good for now
    property Component sendTransactionModalComponent: SignTransactionModal {
        store: browserWindow.globalStore
    }

    property Component signMessageModalComponent: SignMessageModal {}

    property MessageDialog sendingError: MessageDialog {
        id: sendingError
        //% "Error sending the transaction"
        title: qsTrId("error-sending-the-transaction")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }

    property MessageDialog signingError: MessageDialog {
        id: signingError
        //% "Error signing message"
        title: qsTrId("error-signing-message")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }

    property QtObject defaultProfile: WebEngineProfile {
        storageName: "Profile"
        offTheRecord: false
        httpUserAgent: {
            if (localAccountSensitiveSettings.compatibilityMode) {
                // Google doesn't let you connect if the user agent is Chrome-ish and doesn't satisfy some sort of hidden requirement
                return "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:81.0) Gecko/20100101 Firefox/81.0"
            }
            return ""
        }
        useForGlobalCertificateVerification: true
        userScripts: [
            WebEngineScript {
                injectionPoint: WebEngineScript.DocumentCreation
                sourceUrl:  Qt.resolvedUrl("./helpers/provider.js")
                worldId: WebEngineScript.MainWorld // TODO: check https://doc.qt.io/qt-5/qml-qtwebengine-webenginescript.html#worldId-prop
            }
        ]
    }

    property QtObject otrProfile: WebEngineProfile {
        offTheRecord: true
        persistentCookiesPolicy:  WebEngineProfile.NoPersistentCookies
        httpUserAgent: defaultProfile.httpUserAgent
        userScripts: [
            WebEngineScript {
                injectionPoint: WebEngineScript.DocumentCreation
                sourceUrl:  Qt.resolvedUrl("./helpers/provider.js")
                worldId: WebEngineScript.MainWorld // TODO: check https://doc.qt.io/qt-5/qml-qtwebengine-webenginescript.html#worldId-prop
            }
        ]
    }

    function openUrlInNewTab(url) {
        var tab = browserWindow.addNewTab()
        tab.item.url = determineRealURL(url)
    }

    function addNewDownloadTab() {
        tabs.createDownloadTab(tabs.count !== 0 ? currentWebView.profile : defaultProfile);
        tabs.currentIndex = tabs.count - 1;
    }

    function addNewTab() {
        var tab = tabs.createEmptyTab(tabs.count !== 0 ? currentWebView.profile : defaultProfile);
        tabs.currentIndex = tabs.count - 1;
        browserHeader.addressBar.forceActiveFocus();
        browserHeader.addressBar.selectAll();

        return tab;
    }

    function onDownloadRequested(download) {
        downloadBar.isVisible = true
        download.accept();
        DownloadsStore.addDownload(download)
    }

    function determineRealURL(url) {
        return Web3ProviderStore.determineRealURL(url)
    }

    onCurrentWebViewChanged: {
        findBar.reset();
        browserHeader.addressBar.text = Web3ProviderStore.obtainAddress(currentWebView.url)
    }

    Layout.fillHeight: true
    Layout.fillWidth: true

    color: Style.current.inputBackground
    border.width: 0

    WebProviderObj { id: provider }

    BrowserShortcutActions {
        id: keyboardShortcutActions
    }

    WebChannel {
        id: channel
        registeredObjects: [provider]
    }

    BrowserHeader {
        id: browserHeader
        anchors.top: parent.top
        anchors.topMargin: tabs.tabHeight + tabs.anchors.topMargin
        z: 52
        addNewTab: browserWindow.addNewTab
        favoriteComponent: favoritesBar
        currentFavorite: currentWebView && BookmarksStore.getCurrentFavorite(currentWebView.url)
        dappBrowserAccName: WalletStore.dappBrowserAccount.name
        dappBrowserAccIcon: WalletStore.dappBrowserAccount.iconColor
        onAddNewFavoritelClicked: {
            addFavoriteModal.modifiyModal = browserHeader.currentFavorite
            addFavoriteModal.toolbarMode = true
            addFavoriteModal.x = xPos - 30
            addFavoriteModal.y = browserHeader.y + browserHeader.height + 4
            addFavoriteModal.ogUrl = browserHeader.currentFavorite ? browserHeader.currentFavorite.url : currentWebView.url
            addFavoriteModal.ogName = browserHeader.currentFavorite ? browserHeader.currentFavorite.name : currentWebView.title
            addFavoriteModal.open()
        }
    }

    BrowserTabView {
        id: tabs
        anchors.top: parent.top
        anchors.topMargin: Style.current.halfPadding
        anchors.bottom: devToolsView.top
        anchors.bottomMargin: browserHeader.height
        anchors.left: parent.left
        anchors.right: parent.right
        z: 50
        tabComponent: webEngineView
    }

    ProgressBar {
        id: progressBar
        height: 3
        from: 0
        to: 100
        visible: value != 0 && value != 100
        value: (currentWebView && currentWebView.loadProgress < 100) ? currentWebView.loadProgress : 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.current.padding
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
    }

    WebEngineView {
        id: devToolsView
        visible: localAccountSensitiveSettings.devToolsEnabled
        height: visible ? 400 : 0
        inspectedView: visible && tabs.currentIndex < tabs.count ? tabs.getTab(tabs.currentIndex).item : null
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        onNewViewRequested: function(request) {
            var tab = tabs.createEmptyTab(currentWebView.profile);
            tabs.currentIndex = tabs.count - 1;
            request.openIn(tab.item);
        }
        z: 100
    }

    AddFavoriteModal {
        id: addFavoriteModal
    }

    FavoriteMenu {
        id: favoriteMenu
        openInNewTab: function (url) {
            browserWindow.openUrlInNewTab(url)
        }
    }

    MessageDialog {
        id: sslDialog

        property var certErrors: []
        icon: StandardIcon.Warning
        standardButtons: StandardButton.No | StandardButton.Yes
        //% "Server's certificate not trusted"
        title: qsTrId("server-s-certificate-not-trusted")
        //% "Do you wish to continue?"
        text: qsTrId("do-you-wish-to-continue-")
        //% "If you wish so, you may continue with an unverified certificate. Accepting an unverified certificate means you may not be connected with the host you tried to connect to.\nDo you wish to override the security check and continue?"
        detailedText: qsTrId("if-you-wish-so--you-may-continue-with-an-unverified-certificate--accepting-an-unverified-certificate-means-you-may-not-be-connected-with-the-host-you-tried-to-connect-to--ndo-you-wish-to-override-the-security-check-and-continue-")
        onYes: {
            certErrors.shift().ignoreCertificateError();
            presentError();
        }
        onNo: reject()
        onRejected: reject()

        function reject(){
            certErrors.shift().rejectCertificate();
            presentError();
        }
        function enqueue(error){
            certErrors.push(error);
            presentError();
        }
        function presentError(){
            visible = certErrors.length > 0
        }
    }

    DownloadBar {
        id: downloadBar
        anchors.bottom: parent.bottom
        z: 60
        downloadsModel: DownloadsStore.downloadModel
        onOpenDownloadClicked: {
            if (downloadComplete) {
                return DownloadsStore.openFile(index)
            }
            DownloadsStore.openDirectory(index)
        }
    }

    FindBar {
        id: findBar
        visible: false
        anchors.right: parent.right
        anchors.top: browserHeader.bottom
        z: 60

        onFindNext: {
            if (text)
                currentWebView && currentWebView.findText(text);
            else if (!visible)
                visible = true;
        }
        onFindPrevious: {
            if (text)
                currentWebView && currentWebView.findText(text, WebEngineView.FindBackward);
            else if (!visible)
                visible = true;
        }
    }

    Rectangle {
        id: statusBubble
        color: "oldlace"
        property int padding: 8
        visible: false

        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width: statusText.paintedWidth + padding
        height: statusText.paintedHeight + padding

        Text {
            id: statusText
            anchors.centerIn: statusBubble
            elide: Qt.ElideMiddle

            Timer {
                id: hideStatusText
                interval: 750
                onTriggered: {
                    statusText.text = "";
                    statusBubble.visible = false;
                }
            }
        }
    }

    DownloadMenu {
        id: downloadMenu
    }

    Component {
        id: favoritesBar
        FavoritesBar {
            bookmarkModel: BookmarksStore.bookmarksModel
        }
    }

    Component {
        id: webEngineView
        BrowserWebEngineView {}
    }

    Connections {
        target: currentWebView
        onUrlChanged: {
            browserHeader.addressBar.text = Web3ProviderStore.obtainAddress(currentWebView.url)
        }
    }

    Connections {
        target: BookmarksStore.bookmarksModel
        onModelChanged: {
            browserHeader.currentFavorite = Qt.binding(function () {return BookmarksStore.getCurrentFavorite(currentWebView.url)})
        }
    }
}
