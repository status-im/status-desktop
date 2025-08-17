import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Controls
import StatusQ.Core.Theme

import shared.controls

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

    signal addNewFavoriteClicked(int xPos)
    signal launchInBrowser(string url)
    signal openHistoryPopup(int xPos, int yPos)
    signal goForward()
    signal goBack()
    signal reload()
    signal stopLoading()
    signal openWalletMenu()

    QtObject {
        id: _internal
        readonly property int innerMargin: 12
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
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            Layout.leftMargin: _internal.innerMargin
            icon.height: 20
            icon.width: 20
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
            onPressAndHold: {
                if (canGoBack) {
                    openHistoryPopup(backButton.x, backButton.y + backButton.height)
                }
            }
        }

        StatusFlatRoundButton {
            id: forwardButton
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            Layout.leftMargin: -_internal.innerMargin/2
            icon.width: 20
            icon.height: 20
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
            onPressAndHold: {
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
            focus: true
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

        Loader {
            Layout.preferredWidth: 44
            Layout.preferredHeight: 44
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
                icon.width: 18
                icon.height: 18
                icon.color: dappBrowserAccIcon
                text: dappBrowserAccName
                onPressed: {
                    root.openWalletMenu();
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
        anchors.leftMargin: Theme.smallPadding
        anchors.right: parent.right
        anchors.rightMargin: Theme.smallPadding
    }
}
