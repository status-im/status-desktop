import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import Qt.labs.settings 1.0
import QtQuick.Controls.Styles 1.0
import QtWebEngine 1.10

import utils 1.0
import shared.controls 1.0
import StatusQ.Controls 0.1 as StatusQControls

import shared 1.0
import shared.panels 1.0
import shared.status 1.0

import "../popups"
import "../controls"

Rectangle {
    id: browserHeader

    property alias favoriteComponent: favoritesBarLoader.sourceComponent
    property alias addressBar: addressBar

    readonly property int innerMargin: 12
    property var currentFavorite
    property var addNewTab: function () {}
    property string dappBrowserAccName: ""
    property string dappBrowserAccIcon: ""

    signal addNewFavoritelClicked(var xPos)

    width: parent.width
    height: barRow.height + (favoritesBarLoader.active ? favoritesBarLoader.height : 0)
    color: Style.current.background
    border.width: 0

    RowLayout {
        id: barRow
        width: parent.width
        height: 45
        spacing: browserHeader.innerMargin

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

        StatusQControls.StatusFlatRoundButton {
            id: backButton
            width: 32
            height: 32
            icon.height: 20
            icon.width: 20
            icon.name: "left"
            icon.disabledColor: Style.current.lightGrey
            type: StatusQControls.StatusFlatRoundButton.Type.Tertiary
            enabled: currentWebView && currentWebView.canGoBack
            Layout.leftMargin: browserHeader.innerMargin
            onClicked: currentWebView.goBack()
            onPressAndHold: {
                if (currentWebView && (currentWebView.canGoBack || currentWebView.canGoForward)){
                    historyMenu.popup(backButton.x, backButton.y + backButton.height)
                }
            }
        }

        StatusQControls.StatusFlatRoundButton {
            id: forwardButton
            width: 32
            height: 32
            icon.width: 20
            icon.height: 20
            icon.name: "right"
            icon.disabledColor: Style.current.lightGrey
            type: StatusQControls.StatusFlatRoundButton.Type.Tertiary
            enabled: currentWebView && currentWebView.canGoForward
            Layout.leftMargin: -browserHeader.innerMargin/2
            onClicked: currentWebView.goForward()
            onPressAndHold: {
                if (currentWebView && (currentWebView.canGoBack || currentWebView.canGoForward)){
                    historyMenu.popup(forwardButton.x, forwardButton.y + forwardButton.height)
                }
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
            //% "Enter URL"
            placeholderText: qsTrId("enter-url")
            focus: true
            text: ""
            color: Style.current.textColor
            onActiveFocusChanged: {
                if (activeFocus) {
                    addressBar.selectAll()
                }
            }

            Keys.onPressed: {
                // TODO: disable browsing local files?  file://
                if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                    if (localAccountSensitiveSettings.useBrowserEthereumExplorer !== Constants.browserEthereumExplorerNone && text.startsWith("0x")) {
                        switch (localAccountSensitiveSettings.useBrowserEthereumExplorer) {
                        case Constants.browserEthereumExplorerEtherscan:
                            if (text.length > 42) {
                                currentWebView.url = "https://etherscan.io/tx/" + text; break;
                            } else {
                                currentWebView.url = "https://etherscan.io/address/" + text; break;
                            }
                        case Constants.browserEthereumExplorerEthplorer:
                            if (text.length > 42) {
                                currentWebView.url = "https://ethplorer.io/tx/" + text; break;
                            } else {
                                currentWebView.url = "https://ethplorer.io/address/" + text; break;
                            }
                        case Constants.browserEthereumExplorerBlockchair:
                            if (text.length > 42) {
                                currentWebView.url = "https://blockchair.com/ethereum/transaction/" + text; break;
                            } else {
                                currentWebView.url = "https://blockchair.com/ethereum/address/" + text; break;
                            }
                        }
                        return
                    }
                    if (localAccountSensitiveSettings.shouldShowBrowserSearchEngine !== Constants.browserSearchEngineNone && !Utils.isURL(text) && !Utils.isURLWithOptionalProtocol(text)) {
                        switch (localAccountSensitiveSettings.shouldShowBrowserSearchEngine) {
                        case Constants.browserSearchEngineGoogle: currentWebView.url = "https://www.google.com/search?q=" + text; break;
                        case Constants.browserSearchEngineYahoo: currentWebView.url = "https://search.yahoo.com/search?p=" + text; break;
                        case Constants.browserSearchEngineDuckDuckGo: currentWebView.url = "https://duckduckgo.com/?q=" + text; break;
                        }

                        return
                    } else if (Utils.isURLWithOptionalProtocol(text)) {
                        text = "https://" + text
                    }

                    currentWebView.url = determineRealURL(text);
                }
            }

            StatusQControls.StatusFlatRoundButton {
                id: addFavoriteBtn
                width: 24
                height: 24
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: reloadBtn.left
                anchors.rightMargin: Style.current.halfPadding
                visible: !!currentWebView && !!currentWebView.url
                icon.source: !!browserHeader.currentFavorite ? Style.svg("browser/favoriteActive") : Style.svg("browser/favorite")
                color: "transparent"
                type: StatusQControls.StatusFlatRoundButton.Type.Tertiary
                onClicked: addNewFavoritelClicked(addFavoriteBtn.x)
            }

            StatusQControls.StatusFlatRoundButton {
                id: reloadBtn
                width: 24
                height: 24
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: Style.current.halfPadding
                icon.name: currentWebView && currentWebView.loading ? "close-circle" : "refresh"
                color: "transparent"
                type: StatusQControls.StatusFlatRoundButton.Type.Tertiary
                onClicked: currentWebView && currentWebView.loading ? currentWebView.stop() : currentWebView.reload()
            }
        }

        BrowserWalletMenu {
            id: browserWalletMenu
            y: browserHeader.height + browserHeader.anchors.topMargin
            x: parent.width - width - Style.current.halfPadding
        }

        Loader {
            active: true
            sourceComponent: currentTabConnected ? connectedBtnComponent : notConnectedBtnCompoent
        }

        Component {
            id: notConnectedBtnCompoent
            StatusQControls.StatusFlatRoundButton {
                id: accountBtn
                width: 24
                height: 24
                icon.width: 24
                icon.height: 24
                icon.name: "filled-account"
                type: StatusQControls.StatusFlatRoundButton.Type.Tertiary
                onClicked: {
                    if (browserWalletMenu.opened) {
                        browserWalletMenu.close()
                    } else {
                        browserWalletMenu.open()
                    }
                }
            }
        }

        Component {
            id: connectedBtnComponent
            StatusQControls.StatusFlatButton {
                id: accountBtnConnected
                icon.name: "wallet"
                icon.width: 18
                icon.height: 18
                icon.color: dappBrowserAccIcon
                text: dappBrowserAccName
                onClicked: {
                    if (browserWalletMenu.opened) {
                        browserWalletMenu.close()
                    } else {
                        browserWalletMenu.open()
                    }
                }
            }
        }

        BrowserSettingsMenu {
            id: settingsMenu
            addNewTab: browserHeader.addNewTab
            x: parent.width - width
            y: parent.height
        }

        StatusQControls.StatusFlatRoundButton {
            id: settingsMenuButton
            implicitHeight: 32
            implicitWidth: 32
            icon.width: 24
            icon.height: 24
            icon.name: "more"
            type: StatusQControls.StatusFlatRoundButton.Type.Tertiary
            Layout.rightMargin: browserHeader.innerMargin
            onClicked: {
                if (settingsMenu.opened) {
                    settingsMenu.close()
                } else {
                    settingsMenu.open()
                }
            }
        }
    }

    Loader {
        id: favoritesBarLoader
        active: localAccountSensitiveSettings.shouldShowFavoritesBar
        anchors.top: barRow.bottom
        anchors.left: parent.left
        anchors.leftMargin: Style.current.smallPadding
        anchors.right: parent.right
        anchors.rightMargin: Style.current.smallPadding
    }
}
