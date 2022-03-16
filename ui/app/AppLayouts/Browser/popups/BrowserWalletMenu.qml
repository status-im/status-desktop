import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import StatusQ.Controls 0.1
import StatusQ.Core 0.1

import shared.controls 1.0

import utils 1.0

import "../../Wallet/views"
import "../stores"

// TODO: replace with StatusPopupMenu
Popup {
    id: popup

    signal sendTriggered(var selectedAccount)
    signal disconnect()
    signal reload()

    modal: false

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    parent: Overlay.overlay
    width: 360
    height: 480
    background: Rectangle {
        id: bgPopup
        color: Style.current.background
        radius: Style.current.radius
        layer.enabled: true
        layer.effect: DropShadow {
            width: bgPopup.width
            height: bgPopup.height
            x: bgPopup.x
            y: bgPopup.y + 10
            visible: bgPopup.visible
            source: bgPopup
            horizontalOffset: 0
            verticalOffset: 5
            radius: 10
            samples: 15
            color: Style.current.dropShadow
        }
    }
    padding: Style.current.padding

    Item {
        id: walletHeader
        width: parent.width
        height: networkText.height

        Rectangle {
            id: networkColorCircle
            width: 8
            height: 8
            radius: width / 2
            color: {
                switch (Web3ProviderStore.currentNetwork) {
                case Constants.networkMainnet: return Style.current.green;
                case Constants.networkRopsten: return Style.current.turquoise;
                default: return Style.current.red
                }
            }
            anchors.verticalCenter: parent.verticalCenter
        }

        StatusBaseText {
            id: networkText
            text: {
                switch (Web3ProviderStore.currentNetwork) {
                //% "Mainnet"
                case Constants.networkMainnet: return qsTrId("mainnet");
                //% "Ropsten"
                case Constants.networkRopsten: return qsTrId("ropsten");
                //% "Unknown"
                default: return qsTrId("active-unknown")
                }
            }
            font.pixelSize: 15
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: networkColorCircle.right
            anchors.leftMargin: Style.current.halfPadding
        }

        StatusBaseText {
            id: disconectBtn
            //% "Disconnect"
            text: qsTrId("disconnect")
            font.pixelSize: 15
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            color: Style.current.danger
            visible: RootStore.currentTabConnected

            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                onClicked: disconnect()
            }
        }
    }

    Item {
        property string currentAddress: ""
        id: accountSelectorRow
        width: parent.width
        height: accountSelector.height
        anchors.top: walletHeader.bottom
        anchors.topMargin: Style.current.bigPadding

        StatusAccountSelector {
            id: accountSelector
            label: ""
            anchors.left: parent.left
            anchors.right: copyBtn.left
            anchors.rightMargin: Style.current.padding
            accounts: WalletStore.accounts
            selectedAccount: WalletStore.dappBrowserAccount
            currency: WalletStore.defaultCurrency
            onSelectedAccountChanged: {
                if (!accountSelectorRow.currentAddress) {
                    // We just set the account for the first time. Nothing to do here
                    accountSelectorRow.currentAddress = selectedAccount.address
                    return
                }
                if (accountSelectorRow.currentAddress === selectedAccount.address) {
                    return
                }

                accountSelectorRow.currentAddress = selectedAccount.address
                Web3ProviderStore.web3ProviderInst.dappsAddress = selectedAccount.address;
                WalletStore.switchAccountByAddress(selectedAccount.address)
                reload()
            }
        }

        CopyToClipBoardButton {
            id: copyBtn
            width: 20
            height: 20
            anchors.right: sendBtn.left
            anchors.rightMargin: Style.current.padding
            anchors.top: parent.top
            anchors.topMargin: Style.current.padding
            color: Style.current.transparent
            textToCopy: accountSelector.selectedAccount.address
            store: RootStore
        }

        StatusFlatRoundButton {
            id: sendBtn
            width: 40
            height: 40
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: Style.current.halfPadding
            icon.name: "send"
            onClicked: sendTriggered(accountSelector.selectedAccount)
        }
    }

    Item {
        id: walletInfoContent
        width: parent.width
        anchors.top: accountSelectorRow.bottom
        anchors.topMargin: Style.current.bigPadding
        anchors.bottom: parent.bottom

        TabBar {
            id: walletTabBar
            width: parent.width
            anchors.top: parent.top
            height: assetBtn.height
            background: Rectangle {
                color: Style.current.transparent
                border.width: 0
            }

            StatusTabButton {
                id: assetBtn
                //% "Assets"
                btnText: qsTrId("wallet-assets")
                anchors.top: parent.top
            }
            StatusTabButton {
                id: historyBtn
                anchors.top: parent.top
                anchors.left: assetBtn.right
                anchors.leftMargin: 32
                //% "History"
                btnText: qsTrId("history")
            }
        }

        StackLayout {
            id: stackLayout
            width: parent.width
            anchors.top: walletTabBar.bottom
            anchors.topMargin: Style.current.bigPadding
            anchors.bottom: parent.bottom
            currentIndex: walletTabBar.currentIndex

            AssetsView {
                id: assetsTab
            }
            HistoryView {
                id: historyTab
            }
        }
    }
}
