import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../../../shared"
import "../../../shared/status"
import "../../../imports"
import "../Wallet"

Popup {
    id: popup
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
        layer.effect: DropShadow{
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
            color: "#22000000"
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
                switch (profileModel.network.current) {
                case Constants.networkMainnet: return Style.current.green;
                case Constants.networkRopsten: return Style.current.turquoise;
                default: return Style.current.red
                }
            }
            anchors.verticalCenter: parent.verticalCenter
        }

        StyledText {
            id: networkText
            text: {
                switch (profileModel.network.current) {
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

        StyledText {
            id: disconectBtn
            //% "Disconnect"
            text: qsTrId("disconnect")
            font.pixelSize: 15
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            color: Style.current.danger

            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                onClicked: {
                    _web3Provider.disconnect();
                    provider.postMessage(`{"type":"web3-disconnect-account"}`);
                    popup.close();
                }
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

        AccountSelector {
            id: accountSelector
            label: ""
            anchors.left: parent.left
            anchors.right: copyBtn.left
            anchors.rightMargin: Style.current.padding
            accounts: walletModel.accounts
            selectedAccount: walletModel.dappBrowserAccount
            currency: walletModel.defaultCurrency
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
                web3Provider.dappsAddress = selectedAccount.address;
                walletModel.setDappBrowserAddress()
                web3Provider.clearPermissions();
                for (let i = 0; i < tabs.count; ++i){
                    tabs.getTab(i).item.reload();
                }
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
            textToCopy: accountSelector.selectedAccount.address
        }

        StatusIconButton {
            id: sendBtn
            icon.name: "send"
            width: 20
            height: 20
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: Style.current.padding
            iconColor: Style.current.primary
            onClicked: {
                sendModal.selectFromAccount.selectedAccount = accountSelector.selectedAccount
                sendModal.open()
            }
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
                onClicked: historyTab.checkIfHistoryIsBeingFetched()
            }
        }

        StackLayout {
            id: stackLayout
            width: parent.width
            anchors.top: walletTabBar.bottom
            anchors.topMargin: Style.current.bigPadding
            anchors.bottom: parent.bottom
            currentIndex: walletTabBar.currentIndex

            AssetsTab {
                id: assetsTab
            }
            HistoryTab {
                id: historyTab
            }
        }
    }
}
