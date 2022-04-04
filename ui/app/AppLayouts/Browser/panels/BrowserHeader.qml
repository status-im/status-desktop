import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import Qt.labs.settings 1.0
import QtQuick.Controls.Styles 1.0
import QtWebEngine 1.10

import StatusQ.Controls 0.1

import shared.controls 1.0

import utils 1.0

import "../popups"
import "../controls"

Rectangle {
    id: browserHeader

    property alias favoriteComponent: favoritesBarLoader.sourceComponent
    property alias addressBar: addressBar

    property var currentUrl
    property bool isLoading: false
    property bool canGoBack: false
    property bool canGoForward: false
    property var currentFavorite
    property bool currentTabConnected: false
    property string dappBrowserAccName: ""
    property string dappBrowserAccIcon: ""
    property var settingMenu
    property var walletMenu

    signal addNewFavoritelClicked(var xPos)
    signal launchInBrowser(var url)
    signal openHistoryPopup(var xPos, var yPos)
    signal goForward()
    signal goBack()
    signal reload()
    signal stopLoading()

    QtObject {
        id: _internal
        readonly property int innerMargin: 12
    }

    width: parent.width
    height: barRow.height + (favoritesBarLoader.active ? favoritesBarLoader.height : 0)
    color: Style.current.background
    border.width: 0

    RowLayout {
        id: barRow
        width: parent.width
        height: 45
        spacing: _internal.innerMargin

        StatusFlatRoundButton {
            id: backButton
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            icon.height: 20
            icon.width: 20
            icon.name: "arrow-left"
            icon.disabledColor: Style.current.lightGrey
            type: StatusFlatRoundButton.Type.Tertiary
            enabled: canGoBack
            Layout.leftMargin: _internal.innerMargin
            onClicked: goBack()
            onPressAndHold: {
                if (canGoBack || canGoForward) {
                    openHistoryPopup(backButton.x, backButton.y + backButton.height)
                }
            }
        }

        StatusFlatRoundButton {
            id: forwardButton
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            icon.width: 20
            icon.height: 20
            icon.name: "arrow-right"
            icon.disabledColor: Style.current.lightGrey
            type: StatusFlatRoundButton.Type.Tertiary
            enabled: canGoForward
            Layout.leftMargin: -_internal.innerMargin/2
            onClicked: goForward()
            onPressAndHold: {
                if (canGoBack || canGoForward) {
                    openHistoryPopup(backButton.x, backButton.y + backButton.height)
                }
            }
        }

        StyledTextField {
            id: addressBar
            Layout.preferredHeight: 40
            Layout.fillWidth: true
            background: Rectangle {
                color: Style.current.inputBackground
                border.color: Style.current.inputBorderFocus
                border.width: activeFocus ? 1 : 0
                radius: 20
            }
            leftPadding: Style.current.padding
            rightPadding: addFavoriteBtn.width + reloadBtn.width + Style.current.bigPadding
            placeholderText: qsTr("Enter URL")
            focus: true
            text: ""
            color: Style.current.textColor
            onActiveFocusChanged: {
                if (activeFocus) {
                    addressBar.selectAll()
                }
            }

            Keys.onPressed: {
                if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                    launchInBrowser(text)
                }
            }

            StatusFlatRoundButton {
                id: addFavoriteBtn
                width: 24
                height: 24
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: reloadBtn.left
                anchors.rightMargin: Style.current.halfPadding
                visible: !!currentUrl
                icon.source: !!browserHeader.currentFavorite ? Style.svg("browser/favoriteActive") : Style.svg("browser/favorite")
                color: "transparent"
                type: StatusFlatRoundButton.Type.Tertiary
                onClicked: addNewFavoritelClicked(addFavoriteBtn.x)
            }

            StatusFlatRoundButton {
                id: reloadBtn
                width: 24
                height: 24
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: Style.current.halfPadding
                icon.name: isLoading ? "close-circle" : "refresh"
                color: "transparent"
                type: StatusFlatRoundButton.Type.Tertiary
                onClicked: isLoading ? stopLoading(): reload()
            }
        }

        Loader {
            active: true
            sourceComponent: currentTabConnected ? connectedBtnComponent : notConnectedBtnCompoent
        }

        Component {
            id: notConnectedBtnCompoent
            StatusFlatRoundButton {
                id: accountBtn
                width: 24
                height: 24
                icon.width: 24
                icon.height: 24
                icon.name: "filled-account"
                type: StatusFlatRoundButton.Type.Tertiary
                onClicked: {
                    if (walletMenu.opened) {
                        walletMenu.close()
                    } else {
                        walletMenu.open()
                    }
                }
            }
        }

        Component {
            id: connectedBtnComponent
            StatusFlatButton {
                id: accountBtnConnected
                icon.name: "wallet"
                icon.width: 18
                icon.height: 18
                icon.color: dappBrowserAccIcon
                text: dappBrowserAccName
                onClicked: {
                    if (walletMenu.opened) {
                        walletMenu.close()
                    } else {
                        walletMenu.open()
                    }
                }
            }
        }

        StatusFlatRoundButton {
            id: settingsMenuButton
            Layout.preferredHeight: 32
            Layout.preferredWidth: 32
            icon.width: 24
            icon.height: 24
            icon.name: "more"
            type: StatusFlatRoundButton.Type.Tertiary
            Layout.rightMargin: _internal.innerMargin
            onClicked: {
                if (settingMenu.opened) {
                    settingMenu.close()
                } else {
                    settingMenu.open()
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
