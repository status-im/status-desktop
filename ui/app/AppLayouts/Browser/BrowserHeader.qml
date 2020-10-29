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
    property alias addressBar: addressBar
    readonly property int innerMargin: 12
    property var addNewTab: function () {}

    id: root
    width: parent.width
    height: 45
    color: Style.current.background
    border.width: 0

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
            target: browserModel
            onBookmarksChanged: {
                addressBar.currentFavorite = getCurrentFavorite()
            }
        }

        StyledTextField {
            property var currentFavorite: getCurrentFavorite()

            function getCurrentFavorite() {
                if (!currentWebView || !currentWebView.url) {
                    return false
                }
                const index = browserModel.bookmarks.getBookmarkIndexByUrl(currentWebView.url)
                if (index === -1) {
                    return null
                }
                return {
                    url: currentWebView.url,
                    name: browserModel.bookmarks.rowData(index, 'name')
                }
            }

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
                id: addFavoriteBtn
                visible: !!currentWebView && !!currentWebView.url
                icon.name: !!addressBar.currentFavorite ? "browser/favoriteActive" : "browser/favorite"
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: reloadBtn.left
                anchors.rightMargin: Style.current.halfPadding
                onClicked: {
                    if (!addressBar.currentFavorite) {
                        browserModel.addBookmark(currentWebView.url, currentWebView.title)
                    }

                    addFavoriteModal.modifiyModal = true
                    addFavoriteModal.x = addFavoriteBtn.x + addFavoriteBtn.width / 2 - addFavoriteBtn.width / 2
                    addFavoriteModal.y = root.y + root.height + 4
                    addFavoriteModal.ogUrl = addressBar.currentFavorite ? addressBar.currentFavorite.url : currentWebView.url
                    addFavoriteModal.ogName = addressBar.currentFavorite ? addressBar.currentFavorite.name : currentWebView.title
                    addFavoriteModal.open()
                }
                width: 24
                height: 24
            }

            StatusIconButton {
                id: reloadBtn
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

        Loader {
            active: true
            sourceComponent: currentTabConnected ? connectedBtnComponent : notConnectedBtnCompoent
        }

        Component {
            id: notConnectedBtnCompoent
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
        }



        Component {
            id: connectedBtnComponent
            StatusButton {
                id: accountBtnConnected
                icon.source: "../../img/walletIcon.svg"
                icon.width: 18
                icon.height: 18
                icon.color: walletModel.currentAccount.iconColor
                text: walletModel.currentAccount.name
                implicitHeight: 32
                type: "secondary"
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
            addNewTab: root.addNewTab
            x: parent.width - width
            y: parent.height
        }

        StatusIconButton {
            id: settingsMenuButton
            icon.name: "dots-icon"
            onClicked: {
                if (settingsMenu.opened) {
                    settingsMenu.close()
                } else {
                    settingsMenu.open()
                }
            }
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
