import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import Qt.labs.settings 1.0
import QtQuick.Controls.Styles 1.0
import QtWebEngine 1.10
import "../../../shared"
import "../../../shared/status"
import "../../../imports"

Rectangle {
    property alias browserSettings: browserSettings
    property alias addressBar: addressBar
    readonly property int innerMargin: 12

    id: root
    width: parent.width
    height: 45
    color: Style.current.background
    border.width: 0

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

    RowLayout {
        anchors.fill: parent
        spacing: root.innerMargin

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

        StatusIconButton {
            id: backButton
            icon.name: "leave_chat"
            disabledColor: Style.current.lightGrey
            onClicked: currentWebView.goBack()
            onPressAndHold: {
                if (currentWebView && (currentWebView.canGoBack || currentWebView.canGoForward)){
                    historyMenu.popup(backButton.x, backButton.y + backButton.height)
                }
            }
            enabled: currentWebView && currentWebView.canGoBack
            width: 24
            height: 24
            Layout.leftMargin: root.innerMargin
            padding: 6
        }

        StatusIconButton {
            id: forwardButton
            icon.name: "leave_chat"
            iconRotation: 180
            disabledColor: Style.current.lightGrey
            onClicked: currentWebView.goForward()
            onPressAndHold: {
                if (currentWebView && (currentWebView.canGoBack || currentWebView.canGoForward)){
                    historyMenu.popup(forwardButton.x, forwardButton.y + forwardButton.height)
                }
            }
            enabled: currentWebView && currentWebView.canGoForward
            width: 24
            height: 24
            Layout.leftMargin: -root.innerMargin/2
        }

        Connections {
            target: currentWebView
            onUrlChanged: {
                var ensAddr = urlENSDictionary[web3Provider.getHost(currentWebView.url)];
                addressBar.text = ensAddr ? web3Provider.replaceHostByENS(currentWebView.url, ensAddr) : currentWebView.url;
            }
        }


        StyledTextField {
            id: addressBar
            height: 40
            Layout.fillWidth: true
            background: Rectangle {
                color: Style.current.inputBackground
                border.color: Style.current.inputBorderFocus
                border.width: activeFocus ? 1 : 0
                radius: 20
            }
            leftPadding: Style.current.padding
            placeholderText: qsTr("Enter URL")
            focus: true
            text: ""
            color: Style.current.textColor
            Keys.onPressed: {
                // TODO: disable browsing local files?  file://
                if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return){
                    currentWebView.url = determineRealURL(text);
                }
            }

            StatusIconButton {
                id: chatCommandsBtn
                icon.name: currentWebView && currentWebView.loading ? "close" : "browser/refresh"
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: Style.current.halfPadding
                onClicked: currentWebView && currentWebView.loading ? currentWebView.stop() : currentWebView.reload()
                width: 24
                height: 24
            }
        }

        BrowserWalletMenu {
            id: browserWalletMenu
            y: root.height + root.anchors.topMargin
            x: parent.width - width - Style.current.halfPadding
        }

        StatusIconButton {
            id: accountBtn
            icon.name: "walletIcon"
            onClicked: {
                if (browserWalletMenu.opened) {
                    browserWalletMenu.close()
                } else {
                    browserWalletMenu.open()
                }
            }
            width: 24
            height: 24
            padding: 6
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

        StatusIconButton {
            id: settingsMenuButton
            icon.name: "dots-icon"
            onClicked: settingsMenu.open()
            width: 24
            height: 24
            Layout.rightMargin: root.innerMargin
            padding: 6
        }
    }
}




/*##^##
Designer {
    D{i:0;width:700}
}
##^##*/
