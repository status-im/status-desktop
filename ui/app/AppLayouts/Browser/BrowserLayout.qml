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
import shared.popups 1.0

import "popups"
import "controls"
import "views"
import "panels"
import "stores"

// Code based on https://code.qt.io/cgit/qt/qtwebengine.git/tree/examples/webengine/quicknanobrowser/BrowserWindow.qml?h=5.15
// Licensed under BSD
Rectangle {
    id: browserWindow

    property var globalStore
    property var sendTransactionModal

    function openUrlInNewTab(url) {
        var tab = _internal.addNewTab()
        tab.item.url = _internal.determineRealURL(url)
    }

    QtObject {
        id: _internal

        property Item currentWebView: tabs.currentIndex < tabs.count ? tabs.getTab(tabs.currentIndex).item : null

        property Component browserDialogComponent: BrowserDialog {
            onClosing: destroy()
        }

        property Component jsDialogComponent: JSDialogWindow {}

        property Component accessDialogComponent: BrowserConnectionModal {
            currentTab: tabs.getTab(tabs.currentIndex) && tabs.getTab(tabs.currentIndex).item
            parent: browserWindow
            x: browserWindow.width - width - Style.current.halfPadding
            y: browserWindow.y + browserHeader.height + Style.current.halfPadding
            web3Response: function(message) {
                provider.web3Response(message)
            }
        }

        // TODO we'll need a new dialog at one point because this one is not using the same call, but it's good for now
        property Component sendTransactionModalComponent: SignTransactionModal {
            anchors.centerIn: parent
            store: browserWindow.globalStore
            contactsStore: browserWindow.globalStore.profileSectionStore.contactsStore
            chainId: browserWindow.globalStore.getChainIdForBrowser()
        }

        property Component signMessageModalComponent: SignMessageModal {}

        property MessageDialog sendingError: MessageDialog {
            title: qsTr("Error sending the transaction")
            icon: StandardIcon.Critical
            standardButtons: StandardButton.Ok
        }

        property MessageDialog signingError: MessageDialog {
            title: qsTr("Error signing message")
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
            httpUserAgent: _internal.defaultProfile.httpUserAgent
            userScripts: [
                WebEngineScript {
                    injectionPoint: WebEngineScript.DocumentCreation
                    sourceUrl:  Qt.resolvedUrl("./helpers/provider.js")
                    worldId: WebEngineScript.MainWorld // TODO: check https://doc.qt.io/qt-5/qml-qtwebengine-webenginescript.html#worldId-prop
                }
            ]
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
    }

    Layout.fillHeight: true
    Layout.fillWidth: true

    color: Style.current.inputBackground
    border.width: 0

    WebProviderObj {
        id: provider
        createAccessDialogComponent: function() {
            return _internal.accessDialogComponent.createObject(browserWindow)
        }
        createSendTransactionModalComponent: function(request) {
            return _internal.sendTransactionModalComponent.createObject(browserWindow, {
                                                                            trxData: request.payload.params[0].data || "",
                                                                            selectedAccount: {
                                                                                name: WalletStore.dappBrowserAccount.name,
                                                                                address: request.payload.params[0].from,
                                                                                iconColor: WalletStore.dappBrowserAccount.color,
                                                                                assets: WalletStore.dappBrowserAccount.assets
                                                                            },
                                                                            selectedRecipient: {
                                                                                address: request.payload.params[0].to,
                                                                                identicon: "",
                                                                                name: RootStore.activeChannelName,
                                                                                type: RecipientSelector.Type.Address
                                                                            },
                                                                            selectedAsset: {
                                                                                name: "ETH",
                                                                                symbol: "ETH",
                                                                                address: Constants.zeroAddress
                                                                            },
                                                                            selectedFiatAmount: "42", // TODO calculate that
                                                                            selectedAmount: RootStore.getWei2Eth(request.payload.params[0].value, 18)
                                                                        })
        }
        createSignMessageModalComponent: function(request) {
            return _internal.signMessageModalComponent.createObject(browserWindow, {
                                                              request,
                                                              selectedAccount: {
                                                                  name: WalletStore.dappBrowserAccount.name,
                                                                  iconColor: WalletStore.dappBrowserAccount.color
                                                              }
                                                          })
        }
        showSendingError: function(message) {
            _internal.sendingError.text = message
            return _internal.sendingError.open()
        }
        showSigningError: function(message) {
            _internal.signingError.text = message
            return _internal.signingError.open()
        }
        showToastMessage: function(result) {
            // TODO: WIP under PR https://github.com/status-im/status-desktop/pull/4274
            let url = `${WalletStore.getEtherscanLink()}/${result}`;
            Global.displayToastMessage(qsTr("Transaction pending..."),
                                       qsTr("View on etherscan"),
                                       "",
                                       true,
                                       Constants.ephemeralNotificationType.normal,
                                       url);
        }
    }

    BrowserShortcutActions {
        id: keyboardShortcutActions
        currentWebView: _internal.currentWebView
        findBarComponent: findBar
        browserHeaderComponent: browserHeader
        onAddNewDownloadTab: _internal.addNewDownloadTab()
        onRemoveView: tabs.removeView(tabs.currentIndex)
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
        favoriteComponent: favoritesBar
        currentFavorite: _internal.currentWebView && BookmarksStore.getCurrentFavorite(_internal.currentWebView.url)
        dappBrowserAccName: WalletStore.dappBrowserAccount.name
        dappBrowserAccIcon: WalletStore.dappBrowserAccount.color
        settingMenu: settingsMenu
        walletMenu: browserWalletMenu
        currentUrl: _internal.currentWebView.url
        isLoading: _internal.currentWebView.loading
        canGoBack: _internal.currentWebView.canGoBack
        canGoForward: _internal.currentWebView.canGoForward
        currentTabConnected: RootStore.currentTabConnected
        onOpenHistoryPopup: historyMenu.popup(xPos, yPos)
        onGoBack: _internal.currentWebView.goBack()
        onGoForward: _internal.currentWebView.goForward()
        onReload: _internal.currentWebView.reload()
        onStopLoading: _internal.currentWebView.stop()
        onAddNewFavoritelClicked: {
            Global.openPopup(addFavoriteModal,
                             {
                                 x: xPos - 30,
                                 y: browserHeader.y + browserHeader.height + 4,
                                 modifiyModal: browserHeader.currentFavorite,
                                 toolbarMode: true,
                                 ogUrl: browserHeader.currentFavorite ? browserHeader.currentFavorite.url : _internal.currentWebView.url,
                                 ogName: browserHeader.currentFavorite ? browserHeader.currentFavorite.name : _internal.currentWebView.title
                             })
        }
        onLaunchInBrowser: {
            // TODO: disable browsing local files?  file://
            if (localAccountSensitiveSettings.useBrowserEthereumExplorer !== Constants.browserEthereumExplorerNone && url.startsWith("0x")) {
                _internal.currentWebView.url = RootStore.get0xFormedUrl(localAccountSensitiveSettings.useBrowserEthereumExplorer, url)
                return
            }
            if (localAccountSensitiveSettings.shouldShowBrowserSearchEngine !== Constants.browserSearchEngineNone && !Utils.isURL(url) && !Utils.isURLWithOptionalProtocol(url)) {
                _internal.currentWebView.url = RootStore.getFormedUrl(localAccountSensitiveSettings.shouldShowBrowserSearchEngine, url)
                return
            } else if (Utils.isURLWithOptionalProtocol(url)) {
                url = "https://" + url
            }
            _internal.currentWebView.url = _internal.determineRealURL(url);
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
        currentWebEngineProfile: _internal.currentWebView.profile
        determineRealURL: function(url) {
            return _internal.determineRealURL(url)
        }
        onOpenNewTabTriggered: _internal.addNewTab()
        Component.onCompleted: {
            _internal.defaultProfile.downloadRequested.connect(_internal.onDownloadRequested);
            _internal.otrProfile.downloadRequested.connect(_internal.onDownloadRequested);
            var tab = createEmptyTab(_internal.defaultProfile);
            // For Devs: Uncomment the next lien if you want to use the simpeldapp on first load
            // tab.item.url = Web3ProviderStore.determineRealURL("https://simpledapp.eth");
        }
    }

    ProgressBar {
        id: progressBar
        height: 3
        from: 0
        to: 100
        visible: value != 0 && value != 100
        value: (_internal.currentWebView && _internal.currentWebView.loadProgress < 100) ? _internal.currentWebView.loadProgress : 0
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
            var tab = tabs.createEmptyTab(_internal.currentWebView.profile);
            tabs.currentIndex = tabs.count - 1;
            request.openIn(tab.item);
        }
        z: 100
    }

    Component {
        id: addFavoriteModal
        AddFavoriteModal {}
    }

    FavoriteMenu {
        id: favoriteMenu
        openInNewTab: function (url) {
            browserWindow.openUrlInNewTab(url)
        }
        onEditFavoriteTriggered: {
            Global.openPopup(addFavoriteModal, {
                                 modifiyModal: true,
                                 ogUrl: favoriteMenu.currentFavorite ? favoriteMenu.currentFavorite.url : _internal.currentWebView.url,
                                 ogName: favoriteMenu.currentFavorite ? favoriteMenu.currentFavorite.name : _internal.currentWebView.title})
        }
    }

    MessageDialog {
        id: sslDialog

        property var certErrors: []
        icon: StandardIcon.Warning
        standardButtons: StandardButton.No | StandardButton.Yes
        title: qsTr("Server's certificate not trusted")
        text: qsTr("Do you wish to continue?")
        detailedText: qsTr("If you wish so, you may continue with an unverified certificate. Accepting an unverified certificate means you may not be connected with the host you tried to connect to.\nDo you wish to override the security check and continue?")
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
        downloadsMenu: downloadMenu
        onOpenDownloadClicked: {
            if (downloadComplete) {
                return DownloadsStore.openFile(index)
            }
            DownloadsStore.openDirectory(index)
        }
        onAddNewDownloadTab: _internal.addNewDownloadTab()
    }

    FindBar {
        id: findBar
        visible: false
        anchors.right: parent.right
        anchors.top: browserHeader.bottom
        z: 60

        onFindNext: {
            if (text)
                _internal.currentWebView && _internal.currentWebView.findText(text);
            else if (!visible)
                visible = true;
        }
        onFindPrevious: {
            if (text)
                _internal.currentWebView && _internal.currentWebView.findText(text, WebEngineView.FindBackward);
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

    BrowserSettingsMenu {
        id: settingsMenu
        x: parent.width - width
        y: browserHeader.y + (localAccountSensitiveSettings.shouldShowFavoritesBar ? browserHeader.height - 38 : browserHeader.height)
        isIncognito: _internal.currentWebView && _internal.currentWebView.profile === _internal.otrProfile
        onAddNewTab: _internal.addNewTab()
        onGoIncognito: {
            if (_internal.currentWebView) {
                _internal.currentWebView.profile = checked ? _internal.otrProfile : _internal.defaultProfile;
            }
        }
        onZoomIn: {
            const newZoom = _internal.currentWebView.zoomFactor + 0.1
            _internal.currentWebView.changeZoomFactor(newZoom)
        }
        onZoomOut: {
            const newZoom = currentWebView.zoomFactor - 0.1
            _internal.currentWebView.changeZoomFactor(newZoom)
        }
        onChangeZoomFactor: _internal.currentWebView.changeZoomFactor(1.0)
        onLaunchFindBar: {
            if (!findBar.visible) {
                findBar.visible = true;
                findBar.forceActiveFocus()
            }
        }
        onToggleCompatibilityMode: {
            for (let i = 0; i < tabs.count; ++i){
                tabs.getTab(i).item.stop() // Stop all loading tabs
            }

            localAccountSensitiveSettings.compatibilityMode = checked;

            for (let i = 0; i < tabs.count; ++i){
                tabs.getTab(i).item.reload() // Reload them with new user agent
            }
        }
        onLaunchBrowserSettings: {
            Global.changeAppSectionBySectionType(Constants.appSection.profile, Constants.settingsSubsection.browserSettings);
        }
    }

    BrowserWalletMenu {
        id: browserWalletMenu
        y: browserHeader.height + browserHeader.anchors.topMargin
        x: parent.width - width - Style.current.halfPadding
        onSendTriggered: {
            sendTransactionModal.selectedAccount = selectedAccount
            sendTransactionModal.open()
        }
        onReload: {
            for (let i = 0; i < tabs.count; ++i){
                tabs.getTab(i).item.reload();
            }
        }
        onDisconnect: {
            Web3ProviderStore.disconnect(Utils.getHostname(browserHeader.addressBar.text))
            provider.postMessage("web3-disconnect-account", "{}");
            _internal.currentWebView.reload()
            close()
        }
    }

    Menu {
        id: historyMenu
        Instantiator {
            model: _internal.currentWebView && _internal.currentWebView.navigationHistory.items
            MenuItem {
                text: model.title
                onTriggered: _internal.currentWebView.goBackOrForward(model.offset)
                checkable: !enabled
                checked: !enabled
                enabled: model.offset
            }
            onObjectAdded: function(index, object) {
                historyMenu.insertItem(index, object)
            }
            onObjectRemoved: function(index, object) {
                historyMenu.removeItem(object)
            }
        }
    }

    Component {
        id: favoritesBar
        FavoritesBar {
            bookmarkModel: BookmarksStore.bookmarksModel
            favoritesMenu: favoriteMenu
            setAsCurrentWebUrl:  function(url) {
                _internal.currentWebView.url = _internal.determineRealURL(url)
            }
            addFavModal: function() {
                Global.openPopup(addFavoriteModal, {toolbarMode: true,
                                     ogUrl: browserHeader.currentFavorite ? browserHeader.currentFavorite.url : _internal.currentWebView.url,
                                     ogName: browserHeader.currentFavorite ? browserHeader.currentFavorite.name : _internal.currentWebView.title})
            }
        }
    }

    Component {
        id: webEngineView
        BrowserWebEngineView {
            anchors.top: parent.top
            anchors.topMargin: browserHeader.height
            currentWebView: _internal.currentWebView
            webChannel: channel
            findBarComp: findBar
            favMenu: favoriteMenu
            addFavModal: addFavoriteModal
            downloadsMenu: downloadMenu
            determineRealURLFn: function(url) {
                return _internal.determineRealURL(url)
            }
            onLinkHovered: function(hoveredUrl) {
                if (hoveredUrl === "")
                    hideStatusText.start();
                else {
                    statusText.text = hoveredUrl;
                    statusBubble.visible = true;
                    hideStatusText.stop();
                }
            }
            onSetCurrentWebUrl: {
                _internal.currentWebView.url = url
            }
            onWindowCloseRequested: tabs.removeView(tabs.indexOfView(webEngineView))
            onNewViewRequested: function(request) {
                if (!request.userInitiated) {
                    print("Warning: Blocked a popup window.");
                } else if (request.destination === WebEngineView.NewViewInTab) {
                    var tab = tabs.createEmptyTab(_internal.currentWebView.profile);
                    tabs.currentIndex = tabs.count - 1;
                    request.openIn(tab.item);
                } else if (request.destination === WebEngineView.NewViewInBackgroundTab) {
                    var backgroundTab = tabs.createEmptyTab(_internal.currentWebView.profile);
                    request.openIn(backgroundTab.item);
                    // Disabling popups temporarily since we need to set that webengineview settings / channel and other properties
                    /*} else if (request.destination === WebEngineView.NewViewInDialog) {
                    var dialog = browserDialogComponent.createObject();
                    dialog.currentWebView.profile = currentWebView.profile;
                    dialog.currentWebView.webChannel = channel;
                    request.openIn(dialog.currentWebView);*/
                } else {
                    // Instead of opening a new window, we open a new tab
                    // TODO: remove "open in new window" from context menu
                    var tab = tabs.createEmptyTab(_internal.currentWebView.profile);
                    tabs.currentIndex = tabs.count - 1;
                    request.openIn(tab.item);
                }
            }
            onCertificateError: function(error) {
                error.defer();
                sslDialog.enqueue(error);
            }
            onJavaScriptDialogRequested: function(request) {
                request.accepted = true;
                var dialog = _internal.jsDialogComponent.createObject(browserWindow, {"request": request});
                dialog.open();
            }
        }
    }

    Connections {
        target: _internal.currentWebView
        onUrlChanged: {
            browserHeader.addressBar.text = Web3ProviderStore.obtainAddress(_internal.currentWebView.url)
            RootStore.currentTabConnected = Web3ProviderStore.hasWalletConnected(Utils.getHostname(_internal.currentWebView.url))
        }
    }

    Connections {
        target: BookmarksStore.bookmarksModel
        onModelChanged: {
            browserHeader.currentFavorite = Qt.binding(function () {return BookmarksStore.getCurrentFavorite(_internal.currentWebView.url)})
        }
    }

    Connections {
        target: browserSection
        onOpenUrl: {
            browserWindow.openUrlInNewTab(url);
        }
    }
}
