import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import StatusQ.Controls 0.1

import utils 1.0

import shared 1.0
import shared.controls 1.0
import shared.views 1.0

import "../controls"
import "../stores"
import "../views"
import "../panels"

Item {
    id: walletContainer

    property alias currentTabIndex: walletTabBar.currentIndex
    property var store
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
            store: walletContainer.store
            walletStore: RootStore
        }

        Item {
            id: walletInfoContent
            Layout.fillHeight: true
            Layout.fillWidth: true

            StatusTabBar {
                id: walletTabBar
                anchors.right: parent.right
                anchors.rightMargin: Style.current.bigPadding
                anchors.left: parent.left
                anchors.leftMargin: Style.current.bigPadding
                anchors.top: parent.top
                anchors.topMargin: Style.current.padding
                
                StatusTabButton {
                    id: assetBtn
                    width: implicitWidth
                    text: qsTr("Assets")
                }
                StatusTabButton {
                    id: collectiblesBtn
                    width: implicitWidth
                    text: qsTr("Collectibles")
                }
                StatusTabButton {
                    id: historyBtn
                    width: implicitWidth
                    text: qsTr("History")
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
                    account: RootStore.currentAccount
                }
                CollectiblesView {
                    id: collectiblesTab
                }
                HistoryView {
                    id: historyTab
                    account: RootStore.currentAccount
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
