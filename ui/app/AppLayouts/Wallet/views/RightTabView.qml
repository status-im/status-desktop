import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import utils 1.0

import shared 1.0
import shared.controls 1.0

import "../controls"
import "../stores"
import "../views"
import "../panels"

Item {
    id: walletContainer

    property var changeSelectedAccount
    property alias currentTabIndex: walletTabBar.currentIndex
    property var store
    property var emojiPopup
    property var sendModal

    ColumnLayout {
        width: parent.width
        height: parent.height

        WalletHeader {
            id: walletHeader
            Layout.fillWidth: true
            locale: RootStore.locale
            currency: RootStore.currentCurrency
            currentAccount: RootStore.currentAccount
            changeSelectedAccount: walletContainer.changeSelectedAccount
            store: walletContainer.store
            walletStore: RootStore
            emojiPopup: walletContainer.emojiPopup
        }

        Item {
            id: walletInfoContent
            Layout.fillHeight: true
            Layout.fillWidth: true

            TabBar {
                id: walletTabBar
                anchors.right: parent.right
                anchors.rightMargin: Style.current.bigPadding
                anchors.left: parent.left
                anchors.leftMargin: Style.current.bigPadding
                anchors.top: parent.top
                anchors.topMargin: Style.current.padding
                height: assetBtn.height
                background: Rectangle {
                    color: Style.current.transparent
                }
                StatusTabButton {
                    id: assetBtn
                    //% "Assets"
                    btnText: qsTrId("wallet-assets")
                }
                StatusTabButton {
                    id: collectiblesBtn
                    anchors.left: assetBtn.right
                    anchors.leftMargin: 32
                    //% "Collectibles"
                    btnText: qsTrId("wallet-collectibles")
                }
                StatusTabButton {
                    id: historyBtn
                    anchors.left: collectiblesBtn.right
                    anchors.leftMargin: 32
                    //% "History"
                    btnText: qsTrId("history")
                }
            }

            StackLayout {
                id: stackLayout
                anchors.rightMargin: Style.current.bigPadding
                anchors.leftMargin: Style.current.bigPadding
                anchors.top: walletTabBar.bottom
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.topMargin: Style.current.bigPadding
                currentIndex: walletTabBar.currentIndex

                AssetsView {
                    id: assetsTab
                }
                CollectiblesView {
                    id: collectiblesTab
                }
                HistoryView {
                    id: historyTab
                }
            }
        }

        WalletFooter {
            id: walletFooter
            Layout.fillWidth: true
            sendModal: walletContainer.sendModal
        }
    }
}
