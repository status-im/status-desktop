import QtQuick
import QtWebEngine

import StatusQ.Core.Theme

import shared.controls

import utils

import "../panels"

import AppLayouts.Browser.stores as BrowserStores

WebEngineView {
    id: root

    required property BrowserStores.BookmarksStore bookmarksStore
    required property BrowserStores.DownloadsStore downloadsStore

    property var currentWebView
    property var findBarComp
    property var favMenu
    property var addFavModal
    property var downloadsMenu
    property var determineRealURLFn: function(url){}
    property bool isDownloadView

    signal setCurrentWebUrl(url url)

    focus: true

    function changeZoomFactor(newFactor) {
        zoomFactor = newFactor
    }

    backgroundColor: Theme.palette.background

    settings.autoLoadImages: localAccountSensitiveSettings.autoLoadImages
    settings.javascriptEnabled: localAccountSensitiveSettings.javaScriptEnabled
    settings.errorPageEnabled: localAccountSensitiveSettings.errorPageEnabled
    settings.pluginsEnabled: localAccountSensitiveSettings.pluginsEnabled
    settings.autoLoadIconsForPage: localAccountSensitiveSettings.autoLoadIconsForPage
    settings.touchIconsEnabled: localAccountSensitiveSettings.touchIconsEnabled
    settings.webRTCPublicInterfacesOnly: localAccountSensitiveSettings.webRTCPublicInterfacesOnly
    settings.pdfViewerEnabled: localAccountSensitiveSettings.pdfViewerEnabled
    settings.focusOnNavigationEnabled: true
    settings.forceDarkMode: Application.styleHints.colorScheme === Qt.ColorScheme.Dark

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

    onNavigationRequested: function (request) {
        if(request.url.toString().startsWith("file:/")){
            console.log("Local file browsing is disabled" )
            request.reject()
        }
    }

    Loader {
        active: root.isDownloadView
        width: parent.width
        height: parent.height
        z: 54
        sourceComponent: DownloadView {
            id: downloadView
            downloadsModel: root.downloadsStore.downloadModel
            downloadsMenu: root.downloadsMenu
            onOpenDownloadClicked: {
                if (downloadComplete) {
                    return root.downloadsStore.openFile(index)
                }
                root.downloadsStore.openDirectory(index)
            }
        }
    }

    Loader {
        active: !root.url.toString() && !root.isDownloadView
        width: parent.width
        height: parent.height
        z: 54

        sourceComponent: Item {
            width: parent.width
            height: parent.height

            Image {
                id: emptyPageImage
                source: Theme.png("browser/compass")
                width: 294
                height: 294
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 60
                cache: false
            }

            FavoritesList {
                id: bookmarkListContainer
                anchors.horizontalCenter: emptyPageImage.horizontalCenter
                anchors.top: emptyPageImage.bottom
                anchors.topMargin: 30
                width: (parent.width < 700) ? (Math.floor(parent.width/cellWidth)*cellWidth) : 700
                height: parent.height - emptyPageImage.height - 20
                model: root.bookmarksStore.bookmarksModel
                favMenu: root.favMenu
                addFavModal: root.addFavModal
                determineRealURLFn: function(url) {
                    return root.determineRealURLFn(url)
                }
                setAsCurrentWebUrl: function(url) {
                    root.setCurrentWebUrl(url)
                }
                Component.onCompleted: {
                    // Add fav button at the end of the grid
                    var index = root.bookmarksStore.getBookmarkIndexByUrl(Constants.newBookmark)
                    if (index !== -1) { root.bookmarksStore.deleteBookmark(Constants.newBookmark) }
                    root.bookmarksStore.addBookmark(Constants.newBookmark, qsTr("Add Favourite"))
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
