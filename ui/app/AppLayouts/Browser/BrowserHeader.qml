import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import Qt.labs.settings 1.0
import QtQuick.Controls.Styles 1.0
import "../../../shared"
import "../../../imports"

Item {
    property alias browserSettings: browserSettings

    id: root
    width: parent.width
    height: 45

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
                addressBar.text = ensAddr ? web3Provider.replaceHostByENS(currentWebView.url, ensAddr) : currentWebView.url;
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
            id: accountsMenu
            Repeater {
                model: walletModel.accounts
                MenuItem {
                    visible: model.isWallet || model.walletType === "generated"
                    height: visible ? 40 : 0
                    text: model.name
                    onTriggered: {
                        web3Provider.dappsAddress = model.address;
                        web3Provider.clearPermissions();
                        for (let i = 0; i < tabs.count; ++i){
                            tabs.getTab(i).item.reload();
                        }
                    }
                    checked: {
                        if(web3Provider.dappsAddress === model.address){
                            txtAccountBtn.text = model.name.substr(0, 1);
                            rectAccountBtn.color = model.iconColor
                            return true;
                        }
                        return false;
                    }
                }
            }
        }

        ToolButton {
            id: accountBtn
            Rectangle {
                id: rectAccountBtn
                anchors.centerIn: parent
                width: 20
                height: width
                radius: width / 2
                color: "#ff0000"
                StyledText {
                    id: txtAccountBtn
                    text: ""
                    opacity: 0.7
                    font.weight: Font.Bold
                    font.pixelSize: 14
                    color: "white"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            onClicked: accountsMenu.popup(accountBtn.x, accountBtn.y + accountBtn.height)
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



