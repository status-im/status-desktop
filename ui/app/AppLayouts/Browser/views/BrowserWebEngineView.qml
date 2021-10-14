import QtQuick 2.13
import QtWebEngine 1.10

import "../../../../shared/controls"
import "../panels"
import "../stores"

import utils 1.0

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

    function changeZoomFactor(newFactor) {
        // FIXME there seems to be a bug in the WebEngine where the zoomFactor only update 1/2 times
        zoomFactor = newFactor
        zoomFactor = newFactor
        zoomFactor = newFactor
    }

    settings.autoLoadImages: appSettings.autoLoadImages
    settings.javascriptEnabled: appSettings.javaScriptEnabled
    settings.errorPageEnabled: appSettings.errorPageEnabled
    settings.pluginsEnabled: appSettings.pluginsEnabled
    settings.autoLoadIconsForPage: appSettings.autoLoadIconsForPage
    settings.touchIconsEnabled: appSettings.touchIconsEnabled
    settings.webRTCPublicInterfacesOnly: appSettings.webRTCPublicInterfacesOnly
    settings.pdfViewerEnabled: appSettings.pdfViewerEnabled
    settings.focusOnNavigationEnabled: true

    onCertificateError: function(error) {
        error.defer();
        sslDialog.enqueue(error);
    }

    onJavaScriptDialogRequested: function(request) {
        request.accepted = true;
        var dialog = jsDialogComponent.createObject(browserWindow, {"request": request});
        dialog.open();
    }

    onNewViewRequested: function(request) {
        if (!request.userInitiated) {
            print("Warning: Blocked a popup window.");
        } else if (request.destination === WebEngineView.NewViewInTab) {
            var tab = tabs.createEmptyTab(currentWebView.profile);
            tabs.currentIndex = tabs.count - 1;
            request.openIn(tab.item);
        } else if (request.destination === WebEngineView.NewViewInBackgroundTab) {
            var backgroundTab = tabs.createEmptyTab(currentWebView.profile);
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

    onNavigationRequested: {
        if(request.url.toString().startsWith("file://")){
            console.log("Local file browsing is disabled" )
            request.action = WebEngineNavigationRequest.IgnoreRequest;
        }
    }

    Loader {
        active: webEngineView.url.toString() === "status://downloads"
        width: parent.width
        height: parent.height
        z: 54
        sourceComponent: DownloadView {
            id: downloadView
            downloadsModel: DownloadsStore.downloadModel
            onOpenDownloadClicked: {
                if (downloadComplete) {
                    return DownloadsStore.openFile(index)
                }
                DownloadsStore.openDirectory(index)
            }
        }
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
                source: Style.png("browser/compass")
                width: 294
                height: 294
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 60
            }

            FavoritesList {
                id: bookmarkListContainer
                anchors.horizontalCenter: emptyPageImage.horizontalCenter
                anchors.top: emptyPageImage.bottom
                anchors.topMargin: 30
                width: (parent.width < 700) ? (Math.floor(parent.width/cellWidth)*cellWidth) : 700
                height: parent.height - emptyPageImage.height - 20
                model: BookmarksStore.bookmarksModel
                Component.onCompleted: {
                    // Add fav button at the end of the grid
                    var index = BookmarksStore.getBookmarkIndexByUrl("")
                    if (index !== -1) { BookmarksStore.deleteBookmark("") }
                    BookmarksStore.addBookmark("", qsTr("Add Favorite"))
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
