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
import "../../../imports"

// Code based on https://code.qt.io/cgit/qt/qtwebengine.git/tree/examples/webengine/quicknanobrowser/BrowserWindow.qml?h=5.15 
// Licensed under BSD

Item {
    id: browserWindow

    property Item currentWebView: tabs.currentIndex < tabs.count ? tabs.getTab(tabs.currentIndex).item : null
    
    property Component browserDialogComponent: BrowserDialog {
        onClosing: destroy()
    }

    Layout.fillHeight: true
    Layout.fillWidth: true

    property var urlENSDictionary: ({})

    function determineRealURL(text){
        var url = utilsModel.urlFromUserInput(text);
        var host = web3Provider.getHost(url);
        if(host.endsWith(".eth")){
            var ensResource = web3Provider.ensResourceURL(host, url);
            urlENSDictionary[web3Provider.getHost(ensResource)] = host;
            url = ensResource;
        }
        return url;
    }

    property Component accessDialogComponent: ModalPopup {
        id: accessDialog

        property var request: ({"hostname": "", "title": "", "permission": ""})

        function postMessage(isAllowed){
            request.isAllowed = isAllowed;
            provider.web3Response(web3Provider.postMessage(JSON.stringify(request)));
        }

        onClosed: {
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


    QtObject {
        id: provider
        WebChannel.id: "backend"

        signal web3Response(string data);

        function postMessage(data){
            var request = JSON.parse(data)

            var ensAddr = urlENSDictionary[request.hostname];
            if(ensAddr){
                request.hostname = ensAddr;
            }
            
            if(request.type === Constants.api_request){
                if(!web3Provider.hasPermission(request.hostname, request.permission)){
                    var dialog = accessDialogComponent.createObject(browserWindow);
                    dialog.request = request;
                    dialog.open();
                } else {
                    request.isAllowed = true;
                    web3Response(web3Provider.postMessage(JSON.stringify(request)));
                }
            } else {
                web3Response(web3Provider.postMessage(data));
            }
        }

        property int networkId: web3Provider.networkId
    }

    WebChannel {
        id: channel
        registeredObjects: [provider]
    }

    property QtObject defaultProfile: WebEngineProfile {
        storageName: "Profile"
        offTheRecord: false
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
        userScripts: [
            WebEngineScript {
                injectionPoint: WebEngineScript.DocumentCreation
                sourceUrl:  Qt.resolvedUrl("provider.js")
                worldId: WebEngineScript.MainWorld // TODO: check https://doc.qt.io/qt-5/qml-qtwebengine-webenginescript.html#worldId-prop 
            }
        ]
    }

    onCurrentWebViewChanged: {
        findBar.reset();
    }

    Settings {
        id : browserSettings
        property alias autoLoadImages: loadImages.checked
        property alias javaScriptEnabled: javaScriptEnabled.checked
        property alias errorPageEnabled: errorPageEnabled.checked
        property alias pluginsEnabled: pluginsEnabled.checked
        property alias autoLoadIconsForPage: autoLoadIconsForPage.checked
        property alias touchIconsEnabled: touchIconsEnabled.checked
        property alias webRTCPublicInterfacesOnly : webRTCPublicInterfacesOnly.checked
        property alias devToolsEnabled: devToolsEnabled.checked
        property alias pdfViewerEnabled: pdfViewerEnabled.checked
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
            addressBar.forceActiveFocus();
            addressBar.selectAll();
        }
    }
    Action {
        shortcut: StandardKey.Refresh
        onTriggered: {
            if (currentWebView)
                currentWebView.reload();
        }
    }
    Action {
        shortcut: StandardKey.AddTab
        onTriggered: {
            tabs.createEmptyTab(tabs.count != 0 ? currentWebView.profile : defaultProfile);
            tabs.currentIndex = tabs.count - 1;
            addressBar.forceActiveFocus();
            addressBar.selectAll();
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
            browserSettings.devToolsEnabled = !browserSettings.devToolsEnabled
        }
    }

    Item {
        id: navigationBar
        anchors.left: parent.left
        anchors.right: parent.right
        height: 45

        RowLayout {
            anchors.fill: parent

            Menu {
                id: historyMenu
                Instantiator {
                    model: currentWebView && currentWebView.navigationHistory.items
                    MenuItem {
                        text: model.title
                        onTriggered: currentWebView.goBackOrForward(model.offset)
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

            ToolButton {
                id: backButton
                icon.source: "../../img/browser/back.png"
                onClicked: currentWebView.goBack()
                onPressAndHold: {
                    if (currentWebView && (currentWebView.canGoBack || currentWebView.canGoForward)){
                        historyMenu.popup(backButton.x, backButton.y + backButton.height)
                    } 
                }
                enabled: currentWebView && currentWebView.canGoBack
            }

            ToolButton {
                id: forwardButton
                icon.source: "../../img/browser/forward.png"
                onClicked: currentWebView.goForward()
                enabled: currentWebView && currentWebView.canGoForward
                onPressAndHold: {
                    if (currentWebView && (currentWebView.canGoBack || currentWebView.canGoForward)){
                        historyMenu.popup(forwardButton.x, forwardButton.y + forwardButton.height)
                    } 
                }
            }

            ToolButton {
                id: reloadButton
                icon.source: currentWebView && currentWebView.loading ? "../../img/browser/stop.png" : "../../img/browser/refresh.png"
                onClicked: currentWebView && currentWebView.loading ? currentWebView.stop() : currentWebView.reload()
            }

            Connections {
                target: currentWebView
                onUrlChanged: {
                    var ensAddr = urlENSDictionary[web3Provider.getHost(currentWebView.url)];
                    if(ensAddr){ // replace host by ensAddr
                        addressBar.text = web3Provider.replaceHostByENS(currentWebView.url, ensAddr);
                    }
                }
            }


            StyledTextField {
                id: addressBar
                Layout.fillWidth: true
                background: Rectangle {
                    border.color: Style.current.secondaryText
                    border.width: 1
                    radius: 2
                }
                leftPadding: 25
                Image {
                    anchors.verticalCenter: addressBar.verticalCenter;
                    x: 5
                    z: 2
                    id: faviconImage
                    width: 16; height: 16
                    sourceSize: Qt.size(width, height)
                    source: currentWebView && currentWebView.icon ? currentWebView.icon : ""
                }
                focus: true
                text: ""
                Keys.onPressed: {
                    // TODO: disable browsing local files?  file://
                    if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return){
                        currentWebView.url = determineRealURL(text);
                    }
                }
            }

            Menu {
                id: settingsMenu
                y: settingsMenuButton.height
                x: settingsMenuButton.x
                MenuItem {
                    id: loadImages
                    text: "Autoload images"
                    checkable: true
                    checked: WebEngine.settings.autoLoadImages
                }
                MenuItem {
                    id: javaScriptEnabled
                    text: "JavaScript On"
                    checkable: true
                    checked: WebEngine.settings.javascriptEnabled
                }
                MenuItem {
                    id: errorPageEnabled
                    text: "ErrorPage On"
                    checkable: true
                    checked: WebEngine.settings.errorPageEnabled
                }
                MenuItem {
                    id: pluginsEnabled
                    text: "Plugins On"
                    checkable: true
                    checked: true
                }
                MenuItem {
                    id: offTheRecordEnabled
                    text: "Off The Record"
                    checkable: true
                    checked: currentWebView && currentWebView.profile === otrProfile
                    onToggled: function(checked) {
                        if (currentWebView) {
                            currentWebView.profile = checked ? otrProfile : defaultProfile;
                        }
                    }
                }
                MenuItem {
                    id: httpDiskCacheEnabled
                    text: "HTTP Disk Cache"
                    checkable: currentWebView && !currentWebView.profile.offTheRecord
                    checked: currentWebView && (currentWebView.profile.httpCacheType === WebEngineProfile.DiskHttpCache)
                    onToggled: function(checked) {
                        if (currentWebView) {
                            currentWebView.profile.httpCacheType = checked ? WebEngineProfile.DiskHttpCache : WebEngineProfile.MemoryHttpCache;
                        }
                    }
                }
                MenuItem {
                    id: autoLoadIconsForPage
                    text: "Icons On"
                    checkable: true
                    checked: WebEngine.settings.autoLoadIconsForPage
                }
                MenuItem {
                    id: touchIconsEnabled
                    text: "Touch Icons On"
                    checkable: true
                    checked: WebEngine.settings.touchIconsEnabled
                    enabled: autoLoadIconsForPage.checked
                }
                MenuItem {
                    id: webRTCPublicInterfacesOnly
                    text: "WebRTC Public Interfaces Only"
                    checkable: true
                    checked: WebEngine.settings.webRTCPublicInterfacesOnly
                }
                MenuItem {
                    id: devToolsEnabled
                    text: "Open DevTools"
                    checkable: true
                    checked: false
                }
                MenuItem {
                    id: pdfViewerEnabled
                    text: "PDF viewer enabled"
                    checkable: true
                    checked: WebEngine.settings.pdfViewerEnabled
                }
            }
              
            ToolButton {
                id: settingsMenuButton
                text: qsTr("⋮")
                onClicked: settingsMenu.open()
            }
        }
    }

    QQC1.TabView {
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
                if (tabs.getTab(i).item == view)
                    return i
            return -1
        }

        function removeView(index) {
            if (tabs.count > 1)
                tabs.removeTab(index)
        }

        anchors.top: navigationBar.bottom
        anchors.bottom: devToolsView.top
        anchors.left: parent.left
        anchors.right: parent.right
        Component.onCompleted: {
            var tab = createEmptyTab(defaultProfile);
            tab.item.url = determineRealURL("https://simpledapp.eth");
        }

        // Add custom tab view style so we can customize the tabs to include a close button
        style: TabViewStyle {
            property color frameColor: "#999"
            property color fillColor: "#eee"
            property color nonSelectedColor: "#ddd"
            frameOverlap: 1
            frame: Rectangle {
                color: "#eee"
                border.color: frameColor
            }
            tab: Rectangle {
                id: tabRectangle
                color: styleData.selected ? fillColor : nonSelectedColor
                border.width: 1
                border.color: frameColor
                implicitWidth: Math.max(text.width + 30, 80)
                implicitHeight: Math.max(text.height + 10, 20)
                Rectangle { height: 1 ; width: parent.width ; color: frameColor}
                Rectangle { height: parent.height ; width: 1; color: frameColor}
                Rectangle { x: parent.width - 2; height: parent.height ; width: 1; color: frameColor}
                Text {
                    id: text
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 6
                    text: styleData.title
                    elide: Text.ElideRight
                    color: styleData.selected ? "black" : frameColor
                }

                Image {
                    visible: tabs.count > 1
                    source: "../../img/browser/close.png"
                    width: 12
                    height: 16
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: 4
                    MouseArea {
                        anchors.fill: parent
                        enabled: tabs.count > 1
                        onClicked: tabs.removeView(styleData.index)
                    }
                }
            }
        }

        Component {
            id: tabComponent
            WebEngineView {
                id: webEngineView
                focus: true
                webChannel: channel
                onLinkHovered: function(hoveredUrl) {
                    if (hoveredUrl == "")
                        hideStatusText.start();
                    else {
                        statusText.text = hoveredUrl;
                        statusBubble.visible = true;
                        hideStatusText.stop();
                    }
                }

                settings.autoLoadImages: browserSettings.autoLoadImages
                settings.javascriptEnabled: browserSettings.javaScriptEnabled
                settings.errorPageEnabled: browserSettings.errorPageEnabled
                settings.pluginsEnabled: browserSettings.pluginsEnabled
                settings.autoLoadIconsForPage: browserSettings.autoLoadIconsForPage
                settings.touchIconsEnabled: browserSettings.touchIconsEnabled
                settings.webRTCPublicInterfacesOnly: browserSettings.webRTCPublicInterfacesOnly
                settings.pdfViewerEnabled: browserSettings.pdfViewerEnabled

                onCertificateError: function(error) {
                    error.defer();
                    sslDialog.enqueue(error);
                }

                onNewViewRequested: function(request) {
                    if (!request.userInitiated)
                        print("Warning: Blocked a popup window.");
                    else if (request.destination === WebEngineView.NewViewInTab) {
                        var tab = tabs.createEmptyTab(currentWebView.profile);
                        tabs.currentIndex = tabs.count - 1;
                        request.openIn(tab.item);
                    } else if (request.destination === WebEngineView.NewViewInBackgroundTab) {
                        var backgroundTab = tabs.createEmptyTab(currentWebView.profile);
                        request.openIn(backgroundTab.item);
                    } else if (request.destination === WebEngineView.NewViewInDialog) {
                        var dialog = browserDialogComponent.createObject();
                        dialog.currentWebView.profile = currentWebView.profile;
                        request.openIn(dialog.currentWebView);
                    } else {
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
                    if (loadRequest.status == WebEngineView.LoadStartedStatus)
                        findBar.reset();
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
        visible: devToolsEnabled.checked
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
