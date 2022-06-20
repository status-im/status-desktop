import QtQuick 2.13
import QtWebEngine 1.10

import shared.controls 1.0

import utils 1.0

import "../panels"
import "../stores"

WebEngineView {
    id: webEngineView

    property var currentWebView
    property var findBarComp
    property var favMenu
    property var addFavModal
    property var downloadsMenu
    property var determineRealURLFn: function(url){}

    signal setCurrentWebUrl(var url)

    focus: true

    function changeZoomFactor(newFactor) {
        // FIXME there seems to be a bug in the WebEngine where the zoomFactor only update 1/2 times
        zoomFactor = newFactor
        zoomFactor = newFactor
        zoomFactor = newFactor
    }

    settings.autoLoadImages: localAccountSensitiveSettings.autoLoadImages
    settings.javascriptEnabled: localAccountSensitiveSettings.javaScriptEnabled
    settings.errorPageEnabled: localAccountSensitiveSettings.errorPageEnabled
    settings.pluginsEnabled: localAccountSensitiveSettings.pluginsEnabled
    settings.autoLoadIconsForPage: localAccountSensitiveSettings.autoLoadIconsForPage
    settings.touchIconsEnabled: localAccountSensitiveSettings.touchIconsEnabled
    settings.webRTCPublicInterfacesOnly: localAccountSensitiveSettings.webRTCPublicInterfacesOnly
    settings.pdfViewerEnabled: localAccountSensitiveSettings.pdfViewerEnabled
    settings.focusOnNavigationEnabled: true

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

    onSelectClientCertificate: function(selection) {
        selection.certificates[0].select();
    }

    onFindTextFinished: function(result) {
        if (!findBarComp.visible)
            findBarComp.visible = true;

        findBarComp.numberOfMatches = result.numberOfMatches;
        findBarComp.activeMatch = result.activeMatch;
    }

    onLoadingChanged: function(loadRequest) {
        if (loadRequest.status === WebEngineView.LoadStartedStatus)
            findBarComp.reset();
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
            downloadsMenu: webEngineView.downloadsMenu
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
                width: Style.dp(294)
                height: width
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: Style.dp(60)
            }

            FavoritesList {
                id: bookmarkListContainer
                anchors.horizontalCenter: emptyPageImage.horizontalCenter
                anchors.top: emptyPageImage.bottom
                anchors.topMargin: Style.dp(30)
                width: (parent.width < Style.dp(700)) ? (Math.floor(parent.width/cellWidth)*cellWidth) : Style.dp(700)
                height: parent.height - emptyPageImage.height - Style.dp(20)
                model: BookmarksStore.bookmarksModel
                favMenu: webEngineView.favMenu
                addFavModal: webEngineView.addFavModal
                determineRealURLFn: function(url) {
                    return webEngineView.determineRealURLFn(url)
                }
                setAsCurrentWebUrl:  function(url) {
                    webEngineView.setCurrentWebUrl(url)
                }
                Component.onCompleted: {
                    // Add fav button at the end of the grid
                    var index = BookmarksStore.getBookmarkIndexByUrl(Constants.newBookmark)
                    if (index !== -1) { BookmarksStore.deleteBookmark(Constants.newBookmark) }
                    BookmarksStore.addBookmark(Constants.newBookmark, qsTr("Add Favorite"))
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
