import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Controls 1.0 as QQC1
import QtQuick.Layouts 1.13
import QtWebEngine 1.10
import QtWebChannel 1.13
import Qt.labs.settings 1.0
import QtQuick.Controls.Styles 1.0
import QtQuick.Dialogs 1.2
import "../../../shared"
import "../../../shared/status"
import "../../../imports"
import "../Chat/ChatColumn/ChatComponents"

// Code based on https://code.qt.io/cgit/qt/qtwebengine.git/tree/examples/webengine/quicknanobrowser/BrowserWindow.qml?h=5.15 
// Licensed under BSD

Rectangle {
    id: browserWindow
    color: Style.current.inputBackground
    border.width: 0

    property Item currentWebView: tabs.currentIndex < tabs.count ? tabs.getTab(tabs.currentIndex).item : null
    
    property Component browserDialogComponent: BrowserDialog {
        onClosing: destroy()
    }


    Layout.fillHeight: true
    Layout.fillWidth: true

    property var urlENSDictionary: ({})

    function determineRealURL(text){
        var url = _utilsModel.urlFromUserInput(text);
        var host = _web3Provider.getHost(url);
        if(host.endsWith(".eth")){
            var ensResource = _web3Provider.ensResourceURL(host, url);
            urlENSDictionary[_web3Provider.getHost(ensResource)] = host;
            url = ensResource;
        }
        return url;
    }

    property Component accessDialogComponent: ModalPopup {
        id: accessDialog

        property var request: ({"hostname": "", "title": "", "permission": ""})
        property bool interactedWith: false

        function postMessage(isAllowed){
            interactedWith = true
            request.isAllowed = isAllowed;
            provider.web3Response(_web3Provider.postMessage(JSON.stringify(request)));
        }

        onClosed: {
            if(!interactedWith){
                postMessage(false);
            }
            accessDialog.destroy();	
        }

        // TODO: design required

        StyledText {
            id: siteName
            text: request.title
            anchors.top: parent.top
            anchors.topMargin: Style.current.padding
            width: parent.width
            wrapMode: Text.WordWrap
        }

        StyledText {
            id: hostName
            text: request.hostname
            anchors.top: siteName.bottom
            anchors.topMargin: Style.current.padding
            width: parent.width
            wrapMode: Text.WordWrap
        }

        StyledText {
            id: permission
            text: qsTr("Permission requested: %1").arg(request.permission)
            anchors.top: hostName.bottom
            anchors.topMargin: Style.current.padding
            width: parent.width
            wrapMode: Text.WordWrap
        }

        StyledText {
            id: description
            anchors.top: permission.bottom
            anchors.topMargin: Style.current.padding
            width: parent.width
            wrapMode: Text.WordWrap
            text: {
                switch(request.permission){
                    case Constants.permission_web3: return qsTr("Allowing authorizes this DApp to retrieve your wallet address and enable Web3");
                    case Constants.permission_contactCode: return qsTr("Granting access authorizes this DApp to retrieve your chat key");
                    default: return qsTr("Unknown permission: " + request.permission);
                }
            }
        }

        StyledButton {	
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Style.current.padding
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding
            label: qsTr("Allow")
            onClicked: {
                postMessage(true);
                accessDialog.close();
            }
        }

        StyledButton {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding
            label: qsTr("Deny")
            onClicked: {
                postMessage(false);
                accessDialog.close();
            }
        }
    }

    // TODO we'll need a new dialog at one point because this one is not using the same call, but it's good for now
    property Component sendTransactionModalComponent: SignTransactionModal {}

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
        title: qsTr("Error signing message")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }

    QtObject {
        id: provider
        WebChannel.id: "backend"

        signal web3Response(string data);

        function postMessage(data) {
            var request;
            try {
                request = JSON.parse(data)
            } catch (e) {
                console.error("Error parsing the message data", e)
                return;
            }

            var ensAddr = urlENSDictionary[request.hostname];
            if (ensAddr) {
                request.hostname = ensAddr;
            }

            if (request.type === Constants.api_request) {
                if (!_web3Provider.hasPermission(request.hostname, request.permission)) {
                    var dialog = accessDialogComponent.createObject(browserWindow);
                    dialog.request = request;
                    dialog.open();
                } else {
                    request.isAllowed = true;
                    web3Response(_web3Provider.postMessage(JSON.stringify(request)));
                }
            } else if (request.type === Constants.web3SendAsyncReadOnly &&
                       request.payload.method === "eth_sendTransaction") {
                const sendDialog = sendTransactionModalComponent.createObject(browserWindow);

                _walletModel.setFocusedAccountByAddress(request.payload.params[0].from)
                var acc = _walletModel.focusedAccount
                sendDialog.selectedAccount = {
                    name: acc.name,
                    address: request.payload.params[0].from,
                    iconColor: acc.iconColor,
                    assets: acc.assets
                }
                sendDialog.selectedRecipient = {
                    address: request.payload.params[0].to,
                    identicon: _chatsModel.generateIdenticon(request.payload.params[0].to),
                    name: _chatsModel.activeChannel.name,
                    type: RecipientSelector.Type.Address
                };
                // TODO get this from data
                sendDialog.selectedAsset = {
                    name: "ETH",
                    symbol: "ETH",
                    address: Constants.zeroAddress
                };
                const value = _utilsModel.wei2Token(request.payload.params[0].value, 18)
                sendDialog.selectedAmount = value
                // TODO calculate that
                sendDialog.selectedFiatAmount = "42";

                // TODO change sendTransaction function to the postMessage one
                sendDialog.sendTransaction = function (selectedGasLimit, selectedGasPrice, enteredPassword) {
                    request.payload.selectedGasLimit = selectedGasLimit
                    request.payload.selectedGasPrice = selectedGasPrice
                    request.payload.password = enteredPassword
                    request.payload.params[0].value = value

                    const response = _web3Provider.postMessage(JSON.stringify(request))
                    provider.web3Response(response)

                    let responseObj
                    try {
                        responseObj = JSON.parse(response)

                        if (responseObj.error) {
                            throw new Error(responseObj.error)
                        }

                        //% "Transaction pending..."
                        toastMessage.title = qsTrId("ens-transaction-pending")
                        toastMessage.source = "../../img/loading.svg"
                        toastMessage.iconColor = Style.current.primary
                        toastMessage.iconRotates = true
                        toastMessage.link = `${_walletModel.etherscanLink}/${responseObj.result}`
                        toastMessage.open()
                    } catch (e) {
                        if (e.message.includes("could not decrypt key with given password")){
                            //% "Wrong password"
                            sendDialog.transactionSigner.validationError = qsTrId("wrong-password")
                            return
                        }
                        sendingError.text = e.message
                        return sendingError.open()
                    }

                    sendDialog.close()
                    sendDialog.destroy()
                }

                sendDialog.open();
                walletModel.getGasPricePredictions()
            } else if (request.type === Constants.web3SendAsyncReadOnly && ["eth_sign", "personal_sign", "eth_signTypedData", "eth_signTypedData_v3"].indexOf(request.payload.method) > -1) {
                const signDialog = signMessageModalComponent.createObject(browserWindow, {request});
                signDialog.web3Response = web3Response
                signDialog.signMessage = function (enteredPassword) {
                    signDialog.interactedWith = true;
                    request.payload.password = enteredPassword;
                    const response = web3Provider.postMessage(JSON.stringify(request));
                    provider.web3Response(response);
                    try {
                        let responseObj = JSON.parse(response)
                        if (responseObj.error) {
                            throw new Error(responseObj.error)
                        }
                    } catch (e) {
                        if (e.message.includes("could not decrypt key with given password")){
                            //% "Wrong password"
                            signDialog.transactionSigner.validationError = qsTrId("wrong-password")
                            return
                        }
                        signingError.text = e.message
                        return signingError.open()
                    }
                    signDialog.close()
                    signDialog.destroy()
                }


                signDialog.open();
            } else {
                web3Response(_web3Provider.postMessage(data));
            }
        }

        property int networkId: _web3Provider.networkId
    }

    WebChannel {
        id: channel
        registeredObjects: [provider]
    }

    property QtObject defaultProfile: WebEngineProfile {
        storageName: "Profile"
        offTheRecord: false
        httpUserAgent: {
            if (browserHeader.addressBar.text.indexOf("google.") > -1) {
                // Google doesn't let you connect if the user agent is Chrome-ish and doesn't satisfy some sort of hidden requirement
                return "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:81.0) Gecko/20100101 Firefox/81.0"
            }
            return ""
        }
        useForGlobalCertificateVerification: true
        userScripts: [
            WebEngineScript {
                injectionPoint: WebEngineScript.DocumentCreation
                sourceUrl:  Qt.resolvedUrl("provider.js")
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
                sourceUrl:  Qt.resolvedUrl("provider.js")
                worldId: WebEngineScript.MainWorld // TODO: check https://doc.qt.io/qt-5/qml-qtwebengine-webenginescript.html#worldId-prop 
            }
        ]
    }
    
    function obtainAddress(){
        var ensAddr = urlENSDictionary[web3Provider.getHost(currentWebView.url)];
        browserHeader.addressBar.text = ensAddr ? web3Provider.replaceHostByENS(currentWebView.url, ensAddr) : currentWebView.url;
    }

    onCurrentWebViewChanged: {
        findBar.reset();
        obtainAddress();
    }

    Action {
        shortcut: "Ctrl+D"
        onTriggered: {
            downloadView.visible = !downloadView.visible;
        }
    }
    Action {
        id: focus
        shortcut: "Ctrl+L"
        onTriggered: {
            browserHeader.addressBar.forceActiveFocus();
            browserHeader.addressBar.selectAll();
        }
    }
    Action {
        shortcut: StandardKey.Refresh
        onTriggered: {
            if (currentWebView)
                currentWebView.reload();
        }
    }
    function addNewTab() {
        tabs.createEmptyTab(tabs.count != 0 ? currentWebView.profile : defaultProfile);
        tabs.currentIndex = tabs.count - 1;
        browserHeader.addressBar.forceActiveFocus();
        browserHeader.addressBar.selectAll();
    }

    Action {
        shortcut: StandardKey.AddTab
        onTriggered: {
            addNewTab()
        }
    }
    Action {
        shortcut: StandardKey.Close
        onTriggered: {
            currentWebView.triggerWebAction(WebEngineView.RequestClose);
        }
    }
    Action {
        shortcut: "Escape"
        onTriggered: {
            if (findBar.visible)
                findBar.visible = false;
        }
    }
    Action {
        shortcut: "Ctrl+0"
        onTriggered: currentWebView.zoomFactor = 1.0
    }
    Action {
        shortcut: StandardKey.ZoomOut
        onTriggered: currentWebView.zoomFactor -= 0.1
    }
    Action {
        shortcut: StandardKey.ZoomIn
        onTriggered: currentWebView.zoomFactor += 0.1
    }

    Action {
        shortcut: StandardKey.Copy
        onTriggered: currentWebView.triggerWebAction(WebEngineView.Copy)
    }
    Action {
        shortcut: StandardKey.Cut
        onTriggered: currentWebView.triggerWebAction(WebEngineView.Cut)
    }
    Action {
        shortcut: StandardKey.Paste
        onTriggered: currentWebView.triggerWebAction(WebEngineView.Paste)
    }
    Action {
        shortcut: "Shift+"+StandardKey.Paste
        onTriggered: currentWebView.triggerWebAction(WebEngineView.PasteAndMatchStyle)
    }
    Action {
        shortcut: StandardKey.SelectAll
        onTriggered: currentWebView.triggerWebAction(WebEngineView.SelectAll)
    }
    Action {
        shortcut: StandardKey.Undo
        onTriggered: currentWebView.triggerWebAction(WebEngineView.Undo)
    }
    Action {
        shortcut: StandardKey.Redo
        onTriggered: currentWebView.triggerWebAction(WebEngineView.Redo)
    }
    Action {
        shortcut: StandardKey.Back
        onTriggered: currentWebView.triggerWebAction(WebEngineView.Back)
    }
    Action {
        shortcut: StandardKey.Forward
        onTriggered: currentWebView.triggerWebAction(WebEngineView.Forward)
    }
    Action {
        shortcut: StandardKey.Find
        onTriggered: {
            if (!findBar.visible)
                findBar.visible = true;
        }
    }
    Action {
        shortcut: StandardKey.FindNext
        onTriggered: findBar.findNext()
    }
    Action {
        shortcut: StandardKey.FindPrevious
        onTriggered: findBar.findPrevious()
    }
    Action {
        shortcut: "F12"
        onTriggered: {
            browserHeader.browserSettings.devToolsEnabled = !browserHeader.browserSettings.devToolsEnabled
        }
    }

    BrowserHeader {
        id: browserHeader
        anchors.top: parent.top
        // TODO Replace with tab height
        anchors.topMargin: tabs.tabHeight + tabs.anchors.topMargin
        z: 52
    }

    QQC1.TabView {
        property int tabHeight: 40

        id: tabs
        function createEmptyTab(profile) {
            var tab = addTab("", tabComponent);
            // We must do this first to make sure that tab.active gets set so that tab.item gets instantiated immediately.
            tab.active = true;
            tab.title = Qt.binding(function() { return tab.item.title ? tab.item.title : qsTr("New Tab") });
            tab.item.profile = profile;
            return tab;
        }

        function indexOfView(view) {
            for (let i = 0; i < tabs.count; ++i)
                if (tabs.getTab(i).item === view)
                    return i
            return -1
        }

        function removeView(index) {
            if (tabs.count > 1)
                tabs.removeTab(index)
        }

        z: 50
        anchors.top: parent.top
        anchors.topMargin: Style.current.halfPadding
        anchors.bottom: devToolsView.top
        anchors.bottomMargin: browserHeader.height
        anchors.left: parent.left
        anchors.right: parent.right
        Component.onCompleted: {
            var tab = createEmptyTab(defaultProfile);
            tab.item.url = determineRealURL("https://simpledapp.eth");
        }

        style: TabViewStyle {
            property color fillColor: Style.current.background
            property color nonSelectedColor: Qt.darker(Style.current.background, 1.2)
            frameOverlap: 1
            tabsMovable: true

            frame: Rectangle {
                color: Style.current.transparent
                border.width: 0
            }

            tab: Item {
                implicitWidth: tabRectangle.implicitWidth + 5 + (newTabloader.active ? newTabloader.width + Style.current.halfPadding : 0)
                implicitHeight: tabRectangle.implicitHeight
                Rectangle {
                    id: tabRectangle
                    color: styleData.selected ? fillColor : nonSelectedColor
                    border.width: 0
                    implicitWidth: 240
                    implicitHeight: tabs.tabHeight
                    radius: Style.current.radius

                    // This rectangle is to hide the bottom radius
                    Rectangle {
                        width: parent.implicitWidth
                        height: 5
                        color: parent.color
                        border.width: 0
                        anchors.bottom: parent.bottom
                    }

                    Image {
                        id: faviconImage
                        anchors.verticalCenter: parent.verticalCenter;
                        anchors.left: parent.left
                        anchors.leftMargin: Style.current.halfPadding
                        width: 24
                        height: 24
                        sourceSize: Qt.size(width, height)
                        // TODO find a better default favicon
                        source: {
                            const thisTab = tabs.getTab(styleData.index) && tabs.getTab(styleData.index).item
                            return thisTab && !!thisTab.icon.toString() ? thisTab.icon : "../../img/globe.svg"
                        }
                    }

                    StyledText {
                        id: text
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: faviconImage.right
                        anchors.leftMargin: Style.current.halfPadding
                        anchors.right: closeTabBtn.left
                        anchors.rightMargin: Style.current.halfPadding
                        text: styleData.title
                        // TODO the elide probably doesn't work. Set a Max width
                        elide: Text.ElideRight
                        color: Style.current.textColor
                    }


                    StatusIconButton {
                        id: closeTabBtn
                        visible: tabs.count > 1
                        enabled: visible
                        icon.name: "browser/close"
                        iconColor: Style.current.textColor
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: Style.current.halfPadding
                        onClicked: tabs.removeView(styleData.index)
                        width: 16
                        height: 16
                    }
                }

                Loader {
                    id: newTabloader
                    active: styleData.index === tabs.count - 1
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right

                    sourceComponent: Component {
                        StatusIconButton {
                            icon.name: "browser/close"
                            iconColor: Style.current.textColor
                            iconRotation: 45
                            onClicked: addNewTab()
                            width: 16
                            height: 16
                        }
                    }
                }
            }
        }

        Component {
            id: tabComponent
            WebEngineView {
                id: webEngineView
                anchors.top: parent.top
                anchors.topMargin: browserHeader.height
                focus: true
                webChannel: channel
                onLinkHovered: function(hoveredUrl) {
                    if (hoveredUrl === "")
                        hideStatusText.start();
                    else {
                        statusText.text = hoveredUrl;
                        statusBubble.visible = true;
                        hideStatusText.stop();
                    }
                }
                backgroundColor: Style.current.background

                settings.autoLoadImages: browserHeader.browserSettings.autoLoadImages
                settings.javascriptEnabled: browserHeader.browserSettings.javaScriptEnabled
                settings.errorPageEnabled: browserHeader.browserSettings.errorPageEnabled
                settings.pluginsEnabled: browserHeader.browserSettings.pluginsEnabled
                settings.autoLoadIconsForPage: browserHeader.browserSettings.autoLoadIconsForPage
                settings.touchIconsEnabled: browserHeader.browserSettings.touchIconsEnabled
                settings.webRTCPublicInterfacesOnly: browserHeader.browserSettings.webRTCPublicInterfacesOnly
                settings.pdfViewerEnabled: browserHeader.browserSettings.pdfViewerEnabled

                onCertificateError: function(error) {
                    error.defer();
                    sslDialog.enqueue(error);
                }

                onNewViewRequested: function(request) {
                    if (!request.userInitiated) {
                        print("PROUT")
                        print("Warning: Blocked a popup window.");
                    } else if (request.destination === WebEngineView.NewViewInTab) {
                        print("NewViewInTab")
                        var tab = tabs.createEmptyTab(currentWebView.profile);
                        tabs.currentIndex = tabs.count - 1;
                        request.openIn(tab.item);
                    } else if (request.destination === WebEngineView.NewViewInBackgroundTab) {
                        print("NewViewInBackgroundTab")
                        var backgroundTab = tabs.createEmptyTab(currentWebView.profile);
                        request.openIn(backgroundTab.item);
                    } else if (request.destination === WebEngineView.NewViewInDialog) {
                        print("NewViewInDialog")
                        var dialog = browserDialogComponent.createObject();
                        dialog.currentWebView.profile = currentWebView.profile;
                        request.openIn(dialog.currentWebView);
                    } else {
                        print("SOMETHIGN")
                        // Instead of opening a new window, we open a new tab
                        // TODO: remove "open in new window" from context menu
                        var tab = tabs.createEmptyTab(currentWebView.profile);
                        tabs.currentIndex = tabs.count - 1;
                        request.openIn(tab.item);
                    }
                }

                onQuotaRequested: function(request) {
                    if (request.requestedSize <= 5 * 1024 * 1024)
                        request.accept();
                    else
                        request.reject();
                }

                onRegisterProtocolHandlerRequested: function(request) {
                    console.log("accepting registerProtocolHandler request for "
                                + request.scheme + " from " + request.origin);
                    request.accept();
                }

                onRenderProcessTerminated: function(terminationStatus, exitCode) {
                    var status = "";
                    switch (terminationStatus) {
                    case WebEngineView.NormalTerminationStatus:
                        status = "(normal exit)";
                        break;
                    case WebEngineView.AbnormalTerminationStatus:
                        status = "(abnormal exit)";
                        break;
                    case WebEngineView.CrashedTerminationStatus:
                        status = "(crashed)";
                        break;
                    case WebEngineView.KilledTerminationStatus:
                        status = "(killed)";
                        break;
                    }

                    print("Render process exited with code " + exitCode + " " + status);
                    reloadTimer.running = true;
                }

                onWindowCloseRequested: tabs.removeView(tabs.indexOfView(webEngineView))

                onSelectClientCertificate: function(selection) {
                    selection.certificates[0].select();
                }

                onFindTextFinished: function(result) {
                    if (!findBar.visible)
                        findBar.visible = true;

                    findBar.numberOfMatches = result.numberOfMatches;
                    findBar.activeMatch = result.activeMatch;
                }

                onLoadingChanged: function(loadRequest) {
                    if (loadRequest.status === WebEngineView.LoadStartedStatus)
                        findBar.reset();
                }

                Loader {
                    active: !webEngineView.url.toString()
                    width: parent.width
                    height: parent.height
                    z: 54

                    sourceComponent: Item {
                        width: parent.width
                        height: parent.height

                        Image {
                            id: emptyPageImage
                            source: "../../img/browser/compass.png"
                            width: 294
                            height: 294
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            anchors.topMargin: 60
                        }

                        Row {
                            anchors.horizontalCenter: emptyPageImage.horizontalCenter
                            anchors.top: emptyPageImage.bottom
                            anchors.topMargin: 30
                            Item {
                                width: bookmarkItem.width
                                height: bookmarkItem.height
                                Item {
                                    id: bookmarkItem
                                    width: childrenRect.width
                                    height: childrenRect.height
                                    SVGImage {
                                        id: bookmarkImage
                                        source: "../../img/globe.svg"
                                        width: 48
                                        height: 48
                                    }

                                    StyledText {
                                        text: "site.com"
                                        anchors.horizontalCenter: bookmarkImage.horizontalCenter
                                        anchors.top: bookmarkImage.bottom
                                        anchors.topMargin: Style.current.halfPadding
                                    }

                                }
                                MouseArea {
                                    anchors.fill: bookmarkItem
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: console.log('Go to bookmark')
                                }
                            }
                        }
                    }
                }



                Timer {
                    id: reloadTimer
                    interval: 0
                    running: false
                    repeat: false
                    onTriggered: currentWebView.reload()
                }
            }
        }
    }

    Connections {
        target: currentWebView
        onUrlChanged: obtainAddress()
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
        visible: browserHeader.browserSettings.devToolsEnabled
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

    DownloadView {
        id: downloadView
        visible: false
        anchors.fill: parent
    }

    function onDownloadRequested(download) {
        console.log("DOWNLOAD REQUESTED")
        downloadView.visible = true;
        downloadView.append(download);
        download.accept();
    }

    FindBar {
        id: findBar
        visible: false
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.top: parent.top

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
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
