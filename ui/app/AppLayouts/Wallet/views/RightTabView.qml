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

    property alias currentTabIndex: walletTabBar.currentIndex

    WalletHeader {
        id: walletHeader
        changeSelectedAccount: leftTab.changeSelectedAccount
        currentAccount: RootStore.currentAccount
        currency: RootStore.currentCurrency
    }

    RowLayout {
        id: walletInfoContainer
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.top: walletHeader.bottom
        anchors.topMargin: 23

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
    }
}
