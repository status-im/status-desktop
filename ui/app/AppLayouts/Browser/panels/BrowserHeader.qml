import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Controls
import StatusQ.Core.Theme
import StatusQ.Core.Utils as SQUtils

import shared.controls
import AppLayouts.Wallet.controls

import utils

import "../popups"
import "../controls"

Rectangle {
    id: root

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

    property var browserDappsModel: null
    property int browserDappsCount: 0

    signal addNewFavoriteClicked(int xPos)
    signal launchInBrowser(string url)
    signal openHistoryPopup(int xPos, int yPos)
    signal goForward()
    signal goBack()
    signal reload()
    signal stopLoading()
    signal openWalletMenu()
    signal openDappUrl(string url)
    signal disconnectDapp(string dappUrl)

    QtObject {
        id: _internal
        readonly property int innerMargin: 12
        readonly property int buttonSize: 40
    }

    width: parent.width
    height: barRow.height + (favoritesBarLoader.active ? favoritesBarLoader.height : 0)
    color: Theme.palette.background

    RowLayout {
        id: barRow
        width: parent.width
        height: 56
        spacing: _internal.innerMargin

        StatusFlatRoundButton {
            id: backButton
            Layout.preferredWidth: _internal.buttonSize
            Layout.preferredHeight: _internal.buttonSize
            Layout.leftMargin: _internal.innerMargin
            icon.name: "arrow-left"
            icon.disabledColor: Theme.palette.baseColor2
            type: StatusFlatRoundButton.Type.Tertiary
            enabled: canGoBack
            sensor.acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: function(mouse) {
                if (mouse.button === Qt.RightButton) {
                    openHistoryPopup(backButton.x, backButton.y + backButton.height)
                } else
                    goBack()
            }
            onPressAndHold: function(mouse) {
                if (canGoBack) {
                    openHistoryPopup(backButton.x, backButton.y + backButton.height)
                }
            }
        }

        StatusFlatRoundButton {
            id: forwardButton
            Layout.preferredWidth: _internal.buttonSize
            Layout.preferredHeight: _internal.buttonSize
            Layout.leftMargin: -_internal.innerMargin/2
            icon.name: "arrow-right"
            icon.disabledColor: Theme.palette.baseColor2
            type: StatusFlatRoundButton.Type.Tertiary
            enabled: canGoForward
            sensor.acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: function(mouse) {
                if (mouse.button === Qt.RightButton) {
                    openHistoryPopup(forwardButton.x, forwardButton.y + forwardButton.height)
                } else
                    goForward()
            }
            onPressAndHold: function(mouse) {
                if (canGoForward) {
                    openHistoryPopup(forwardButton.x, forwardButton.y + forwardButton.height)
                }
            }
        }

        StatusTextField {
            id: addressBar
            Layout.preferredHeight: 40
            Layout.fillWidth: true
            background: Rectangle {
                color: Theme.palette.baseColor2
                border.color: parent.cursorVisible ? Theme.palette.primaryColor1 : Theme.palette.primaryColor2
                border.width: 1
                radius: 20
            }
            leftPadding: Theme.padding
            rightPadding: addFavoriteBtn.width + reloadBtn.width + Theme.bigPadding
            placeholderText: qsTr("Enter URL")
            focus: !SQUtils.Utils.isMobile
            color: Theme.palette.textColor
            onActiveFocusChanged: {
                if (activeFocus) {
                    addressBar.selectAll()
                }
            }

            Keys.onPressed: function (event) {
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
                anchors.rightMargin: Theme.halfPadding
                visible: !!currentUrl
                icon.name: !!root.currentFavorite ? "favourite-filled" : "favourite"
                color: "transparent"
                type: StatusFlatRoundButton.Type.Tertiary
                onClicked: addNewFavoriteClicked(addFavoriteBtn.x)
            }

            StatusFlatRoundButton {
                id: reloadBtn
                width: 24
                height: 24
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: Theme.halfPadding
                icon.name: isLoading ? "close-circle" : "refresh"
                color: "transparent"
                type: StatusFlatRoundButton.Type.Tertiary
                onClicked: isLoading ? stopLoading(): reload()
            }
        }

        DappsComboBox {
            Layout.preferredWidth: _internal.buttonSize
            Layout.preferredHeight: _internal.buttonSize
            spacing: 8
            
            visible: true
            enabled: true
            model: root.browserDappsModel
            showConnectButton: false
            
            onDisconnectDapp: function(dappUrl) {
                root.disconnectDapp(dappUrl)
            }
            
            onDappClicked: function(dappUrl) {
                root.openDappUrl(dappUrl)
            }
            
            onConnectDapp: {
                console.log("[Browser] Connect new dApp requested")
                // Can open a modal or use DAppsWorkflow in the future
            }
        }

        Loader {
            Layout.preferredWidth: _internal.buttonSize
            Layout.preferredHeight: _internal.buttonSize
            active: true
            sourceComponent: currentTabConnected ? connectedBtnComponent : notConnectedBtnCompoent
        }

        Component {
            id: notConnectedBtnCompoent
            StatusFlatRoundButton {
                id: accountBtn
                icon.name: "filled-account"
                type: StatusFlatRoundButton.Type.Tertiary
                onPressed: {
                    root.openWalletMenu()
                }
            }
        }

        Component {
            id: connectedBtnComponent
            StatusFlatButton {
                id: accountBtnConnected
                icon.name: "wallet"
                icon.color: dappBrowserAccIcon
                text: dappBrowserAccName
                onPressed: {
                    root.openWalletMenu();
                }
            }
        }

        StatusFlatRoundButton {
            id: settingsMenuButton
            Layout.preferredHeight: _internal.buttonSize
            Layout.preferredWidth: _internal.buttonSize
            icon.name: "more"
            type: StatusFlatRoundButton.Type.Tertiary
            Layout.rightMargin: _internal.innerMargin
            highlighted: settingMenu.opened
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
        anchors.leftMargin: Theme.smallPadding
        anchors.right: parent.right
        anchors.rightMargin: Theme.smallPadding
    }
}
