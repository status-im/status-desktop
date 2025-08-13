import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtWebEngine
import QtWebChannel

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Layout
import StatusQ.Popups
import StatusQ.Popups.Dialog

import utils
import shared.controls
import shared
import shared.status
import shared.popups.send
import shared.stores.send

import AppLayouts.Browser.stores as BrowserStores

import "popups"
import "controls"
import "views"
import "panels"

// Code based on https://code.qt.io/cgit/qt/qtwebengine.git/tree/examples/webengine/quicknanobrowser/BrowserWindow.qml?h=5.15
// Licensed under BSD

StatusSectionLayout {
    id: root

    required property string userUID

    required property TransactionStore transactionStore
    required property var assetsStore
    required property var currencyStore
    required property var tokensStore

    required property BrowserStores.BookmarksStore bookmarksStore
    required property BrowserStores.DownloadsStore downloadsStore
    required property BrowserStores.BrowserRootStore browserRootStore
    required property BrowserStores.BrowserWalletStore browserWalletStore
    required property BrowserStores.Web3ProviderStore web3ProviderStore

    signal sendToRecipientRequested(string address)

    function openUrlInNewTab(url) {
        var tab = _internal.addNewTab()
        tab.url = _internal.determineRealURL(url)
    }

    onNotificationButtonClicked: Global.openActivityCenterPopup()

    QtObject {
        id: _internal

        property Item currentWebView: tabs.currentIndex < tabs.count ? tabs.getCurrentTab() : null

        property Component browserDialogComponent: BrowserDialog {}

        property Component jsDialogComponent: JSDialogWindow {}

        property Component accessDialogComponent: BrowserConnectionModal {
            browserRootStore: root.browserRootStore
            browserWalletStore: root.browserWalletStore
            web3ProviderStore: root.web3ProviderStore

            parent: browserWindow
            x: browserWindow.width - width - Theme.halfPadding
            y: browserWindow.y + browserHeader.height + Theme.halfPadding
            web3Response: function(message) {
                provider.web3Response(message)
            }
        }

        property Component sendTransactionModalComponent: SendModal {
            anchors.centerIn: parent
            preSelectedHoldingID: "ETH"
            preSelectedHoldingType: Constants.TokenType.ERC20
            store: root.transactionStore
        }

        property Component signMessageModalComponent: SignMessageModal {
            browserRootStore: root.browserRootStore
            signingPhrase: root.browserWalletStore.signingPhrase
        }

        property StatusMessageDialog sendingError: StatusMessageDialog {
            title: qsTr("Error sending the transaction")
            icon: StatusMessageDialog.StandardIcon.Critical
            standardButtons: Dialog.Ok
        }

        property StatusMessageDialog signingError: StatusMessageDialog {
            title: qsTr("Error signing message")
            icon: StatusMessageDialog.StandardIcon.Critical
            standardButtons: Dialog.Ok
        }

        readonly property var script: ({
            injectionPoint: WebEngineScript.DocumentCreation,
            sourceUrl: Qt.resolvedUrl("./helpers/provider.js"), // FIXME needs to be revisited (see https://github.com/status-im/status-desktop/issues/18545)
            worldId: WebEngineScript.MainWorld // TODO: check https://doc.qt.io/qt-5/qml-qtwebengine-webenginescript.html#worldId-prop
        })

        property QtObject defaultProfile: WebEngineProfile {
            storageName: "Profile_%1".arg(root.userUID)
            offTheRecord: false
            httpUserAgent: {
                if (localAccountSensitiveSettings.compatibilityMode) {
                    // Google doesn't let you connect if the user agent is Chrome-ish and doesn't satisfy some sort of hidden requirement
                    return "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36"
                }
                return ""
            }
            // FIXME script disabled as it crashes the browser (https://github.com/status-im/status-desktop/issues/18545)
            //userScripts.collection: [_internal.script]
        }

        property QtObject otrProfile: WebEngineProfile {
            storageName: "IncognitoProfile_%1".arg(root.userUID)
            offTheRecord: true
            persistentCookiesPolicy: WebEngineProfile.NoPersistentCookies
            httpUserAgent: _internal.defaultProfile.httpUserAgent
            // FIXME script disabled as it crashes the browser (https://github.com/status-im/status-desktop/issues/18545)
            //userScripts.collection: [_internal.script]
        }

        function addNewDownloadTab() {
            tabs.createDownloadTab(tabs.count !== 0 ? currentWebView.profile : defaultProfile);
            tabs.currentIndex = tabs.count - 1;
        }

        function addNewTab() {
            var tab = tabs.createEmptyTab(tabs.count !== 0 ? currentWebView.profile : defaultProfile);
            browserHeader.addressBar.forceActiveFocus();
            browserHeader.addressBar.selectAll();

            return tab;
        }

        function onDownloadRequested(download) {
            downloadBar.isVisible = true
            download.accept();
            root.downloadsStore.addDownload(download)
        }

        function determineRealURL(url) {
            return root.web3ProviderStore.determineRealURL(url)
        }

        onCurrentWebViewChanged: {
            findBar.reset();
            browserHeader.addressBar.text = root.web3ProviderStore.obtainAddress(currentWebView.url)
        }
    }

    centerPanel: Rectangle {
        id: browserWindow
        anchors.fill: parent
        color: Theme.palette.baseColor2

        WebProviderObj {
            id: provider
            web3ProviderStore: root.web3ProviderStore
            browserRootStore: root.browserRootStore
            browserWalletStore: root.browserWalletStore

            createAccessDialogComponent: function() {
                return _internal.accessDialogComponent.createObject(root)
            }
            createSendTransactionModalComponent: function(request) {
                return _internal.sendTransactionModalComponent.createObject(root, {
                                                                                preSelectedRecipient: request.payload.params[0].to,
                                                                                preDefinedAmountToSend: LocaleUtils.numberToLocaleString(root.browserRootStore.getWei2Eth(request.payload.params[0].value, 18)),
                                                                            })
            }
            createSignMessageModalComponent: function(request) {
                return _internal.signMessageModalComponent.createObject(root, {
                                                                            request,
                                                                            selectedAccount: {
                                                                                name: root.browserWalletStore.dappBrowserAccount.name,
                                                                                iconColor: Utils.getColorForId(root.browserWalletStore.dappBrowserAccount.colorId)
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
            showToastMessage: function(result, chainId) {
                let url = "%1/%2".arg(root.browserWalletStore.getEtherscanLink(chainId)).arg(result)
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
            currentFavorite: _internal.currentWebView && root.bookmarksStore.getCurrentFavorite(_internal.currentWebView.url)
            dappBrowserAccName: root.browserWalletStore.dappBrowserAccount.name
            dappBrowserAccIcon: Utils.getColorForId(root.browserWalletStore.dappBrowserAccount.colorId)
            settingMenu: settingsMenu
            currentUrl: !!_internal.currentWebView ? _internal.currentWebView.url : ""
            isLoading: (!!_internal.currentWebView && _internal.currentWebView.loading)
            canGoBack: (!!_internal.currentWebView && _internal.currentWebView.canGoBack)
            canGoForward: (!!_internal.currentWebView && _internal.currentWebView.canGoForward)
            currentTabConnected: root.browserRootStore.currentTabConnected
            onOpenHistoryPopup: (xPos, yPos) => historyMenu.popup(xPos, yPos)
            onGoBack: _internal.currentWebView.goBack()
            onGoForward: _internal.currentWebView.goForward()
            onReload: _internal.currentWebView.reload()
            onStopLoading: _internal.currentWebView.stop()
            onAddNewFavoriteClicked: function(xPos) {
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
            onLaunchInBrowser: function(url) {
                if (localAccountSensitiveSettings.useBrowserEthereumExplorer !== Constants.browserEthereumExplorerNone && url.startsWith("0x")) {
                    _internal.currentWebView.url = root.browserRootStore.get0xFormedUrl(localAccountSensitiveSettings.useBrowserEthereumExplorer, url)
                    return
                }
                if (localAccountSensitiveSettings.shouldShowBrowserSearchEngine !== Constants.browserSearchEngineNone && !Utils.isURL(url) && !Utils.isURLWithOptionalProtocol(url)) {
                    _internal.currentWebView.url = root.browserRootStore.getFormedUrl(localAccountSensitiveSettings.shouldShowBrowserSearchEngine, url)
                    return
                } else if (Utils.isURLWithOptionalProtocol(url)) {
                    url = "https://" + url
                }
                _internal.currentWebView.url = _internal.determineRealURL(url);
            }
            onOpenWalletMenu: Global.openPopup(browserWalletMenu)
        }

        BrowserTabView {
            id: tabs
            anchors.top: parent.top
            anchors.topMargin: Theme.halfPadding
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
                var tab = createEmptyTab(_internal.defaultProfile, true);
                // For Devs: Uncomment the next line if you want to use the simpledapp on first load
                // tab.url = root.web3ProviderStore.determineRealURL("https://simpledapp.eth");
            }
        }

        ProgressBar {
            id: progressBar
            height: 3
            from: 0
            to: 100
            visible: value !== 0 && value !== 100
            value: (_internal.currentWebView && _internal.currentWebView.loadProgress < 100) ? _internal.currentWebView.loadProgress : 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.padding
            anchors.right: parent.right
            anchors.rightMargin: Theme.padding
        }

        WebEngineView {
            id: devToolsView
            visible: localAccountSensitiveSettings.devToolsEnabled
            height: visible ? 400 : 0
            inspectedView: visible && tabs.currentIndex < tabs.count ? tabs.getCurrentTab() : null
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            settings.forceDarkMode: Application.styleHints.colorScheme === Qt.ColorScheme.Dark
            onNewWindowRequested: function(request) {
                var tab = tabs.createEmptyTab(_internal.currentWebView.profile);
                request.openIn(tab);
            }
            onWindowCloseRequested: localAccountSensitiveSettings.devToolsEnabled = false
            z: 100
        }

        FavoriteMenu {
            id: favoriteMenu
            bookmarksStore: root.bookmarksStore
            openInNewTab: function (url) {
                root.openUrlInNewTab(url)
            }
            onEditFavoriteTriggered: {
                Global.openPopup(addFavoriteModal, {
                                     modifiyModal: true,
                                     ogUrl: favoriteMenu.currentFavorite ? favoriteMenu.currentFavorite.url : _internal.currentWebView.url,
                                     ogName: favoriteMenu.currentFavorite ? favoriteMenu.currentFavorite.name : _internal.currentWebView.title})
            }
        }
        DownloadBar {
            id: downloadBar
            anchors.bottom: parent.bottom
            z: 60
            downloadsModel: root.downloadsStore.downloadModel
            downloadsMenu: downloadMenu
            onOpenDownloadClicked: function (downloadComplete, index) {
                if (downloadComplete) {
                    return root.downloadsStore.openFile(index)
                }
                root.downloadsStore.openDirectory(index)
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

        DownloadMenu {
            id: downloadMenu
            downloadsStore: root.downloadsStore
        }

        BrowserSettingsMenu {
            id: settingsMenu
            x: parent.width - width
            y: browserHeader.y + (localAccountSensitiveSettings.shouldShowFavoritesBar ? browserHeader.height - 38 : browserHeader.height)
            isIncognito: _internal.currentWebView && _internal.currentWebView.profile === _internal.otrProfile
            onAddNewTab: _internal.addNewTab()
            onGoIncognito: function (checked) {
                if (_internal.currentWebView) {
                    _internal.currentWebView.profile = checked ? _internal.otrProfile : _internal.defaultProfile;
                }
            }
            onZoomIn: {
                const newZoom = _internal.currentWebView.zoomFactor + 0.1
                _internal.currentWebView.changeZoomFactor(newZoom)
            }
            onZoomOut: {
                const newZoom = _internal.currentWebView.zoomFactor - 0.1
                _internal.currentWebView.changeZoomFactor(newZoom)
            }
            onChangeZoomFactor: _internal.currentWebView.changeZoomFactor(1.0)
            onLaunchFindBar: {
                if (!findBar.visible) {
                    findBar.visible = true;
                    findBar.forceActiveFocus()
                }
            }
            onToggleCompatibilityMode: function(checked) {
                for (let i = 0; i < tabs.count; ++i){
                    tabs.getTab(i).stop() // Stop all loading tabs
                }

                localAccountSensitiveSettings.compatibilityMode = checked;

                for (let i = 0; i < tabs.count; ++i){
                    tabs.getTab(i).reload() // Reload them with new user agent
                }
            }
            onLaunchBrowserSettings: {
                Global.changeAppSectionBySectionType(Constants.appSection.profile, Constants.settingsSubsection.browserSettings);
            }
        }
        Component  {
            id: browserWalletMenu
            BrowserWalletMenu {
                assetsStore: root.assetsStore
                currencyStore: root.currencyStore
                tokensStore: root.tokensStore
                currentTabConnected: root.browserRootStore.currentTabConnected
                browserWalletStore: root.browserWalletStore
                web3ProviderStore: root.web3ProviderStore
                property point headerPoint: Qt.point(browserHeader.x, browserHeader.y)
                x: (parent.width - width - Theme.halfPadding)
                y: (Math.abs(browserHeader.mapFromGlobal(headerPoint).y) +
                    browserHeader.anchors.topMargin + Theme.halfPadding)
                onSendTriggered: (address) => root.sendToRecipientRequested(address)
                onReload: {
                    for (let i = 0; i < tabs.count; ++i){
                        tabs.getTab(i).reload();
                    }
                }
                onDisconnect: {
                    root.web3ProviderStore.disconnect(Utils.getHostname(browserHeader.addressBar.text))
                    provider.postMessage("web3-disconnect-account", "{}");
                    _internal.currentWebView.reload()
                    close()
                }
            }
        }
    }

    Component {
        id: addFavoriteModal
        AddFavoriteModal {
            bookmarksStore: root.bookmarksStore
        }
    }

    StatusMessageDialog {
        id: sslDialog

        property var certErrors: []
        icon: StatusMessageDialog.StandardIcon.Warning
        standardButtons: Dialog.No | Dialog.Yes
        title: qsTr("Server's certificate not trusted")
        text: qsTr("Do you wish to continue?")
        detailedText: qsTr("If you wish so, you may continue with an unverified certificate. Accepting an unverified certificate means you may not be connected with the host you tried to connect to.\nDo you wish to override the security check and continue?")
        onAccepted: {
            certErrors.shift().ignoreCertificateError();
            presentError();
        }
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

    StatusMenu {
        id: historyMenu
        Instantiator {
            model: _internal.currentWebView && _internal.currentWebView.history.items
            StatusMenuItem {
                text: model.title
                icon.source: model.icon
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
            bookmarkModel: root.bookmarksStore.bookmarksModel
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
            bookmarksStore: root.bookmarksStore
            downloadsStore: root.downloadsStore
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
                if (hoveredUrl.toString() === "") {
                    hideStatusText.start();
                } else {
                    statusText.text = hoveredUrl;
                    statusBubble.visible = true;
                    hideStatusText.stop();
                }
            }
            onSetCurrentWebUrl: (url) => _internal.currentWebView.url = url
            onWindowCloseRequested: tabs.removeView(StackLayout.index)
            onNewWindowRequested: function(request) {
                if (!request.userInitiated) {
                    console.warn("Warning: Blocked a popup window.");
                } else if (request.destination === WebEngineNewWindowRequest.InNewTab) {
                    var tab = tabs.createEmptyTab(_internal.currentWebView.profile, false, true, request.requestedUrl);
                    tab.acceptAsNewWindow(request);
                } else if (request.destination === WebEngineNewWindowRequest.InNewBackgroundTab) {
                    var backgroundTab = tabs.createEmptyTab(_internal.currentWebView.profile, false, false, request.requestedUrl);
                    backgroundTab.acceptAsNewWindow(request);
                // Disabling popups temporarily since we need to set that webengineview settings / channel and other properties
                /*} else if (request.destination === WebEngineNewWindowRequest.InNewDialog) {
                    var dialog = browserDialogComponent.createObject();
                    dialog.currentWebView.profile = currentWebView.profile;
                    dialog.currentWebView.webChannel = channel;
                    request.openIn(dialog.currentWebView);*/
                } else {
                    // Instead of opening a new window, we open a new tab
                    // TODO: remove "open in new window" from context menu
                    var tab = tabs.createEmptyTab(_internal.currentWebView.profile, false, true, request.requestedUrl);
                    tab.acceptAsNewWindow(request);
                }
            }
            onCertificateError: function(error) {
                error.defer();
                sslDialog.enqueue(error);
            }
            onJavaScriptDialogRequested: function(request) {
                request.accepted = true;
                var dialog = _internal.jsDialogComponent.createObject(root, {"request": request});
                dialog.open();
            }

            Rectangle {
                id: statusBubble
                color: Theme.palette.baseColor2
                visible: false
                z: 54

                anchors.left: parent.left
                anchors.bottom: parent.bottom
                width: Math.min(statusText.implicitWidth, parent.width)
                height: statusText.implicitHeight

                StatusBaseText {
                    id: statusText
                    anchors.fill: parent
                    verticalAlignment: Qt.AlignVCenter
                    elide: Qt.ElideMiddle
                    padding: 4

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
        }
    }

    Connections {
        target: _internal.currentWebView
        function onUrlChanged() {
            browserHeader.addressBar.text = root.web3ProviderStore.obtainAddress(_internal.currentWebView.url)
            root.browserRootStore.currentTabConnected = root.web3ProviderStore.hasWalletConnected(Utils.getHostname(_internal.currentWebView.url))
        }
    }

    Connections {
        target: root.bookmarksStore.bookmarksModel
        function onModelChanged() {
            browserHeader.currentFavorite = Qt.binding(function () {return root.bookmarksStore.getCurrentFavorite(_internal.currentWebView.url)})
        }
    }

    Connections {
        target: typeof browserSection !== "undefined" ? browserSection : null
        function onOpenUrl(url: string) {
            root.openUrlInNewTab(url);
        }
    }
}
