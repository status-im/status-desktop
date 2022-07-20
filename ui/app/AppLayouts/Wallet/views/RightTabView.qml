import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

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
    id: root

    property alias currentTabIndex: walletTabBar.currentIndex
    property var store
    property var sendModal

    ColumnLayout {
       anchors.fill: parent

        WalletHeader {
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
            locale: RootStore.locale
            currency: RootStore.currentCurrency
            currentAccount: RootStore.currentAccount
            store: root.store
            walletStore: RootStore
        }

        StatusTabBar {
            id: walletTabBar
            horizontalPadding: Style.current.padding
            Layout.fillWidth: true
            Layout.topMargin: Style.current.padding

            StatusTabButton {
                leftPadding: 0
                width: implicitWidth
                text: qsTr("Assets")
            }
            StatusTabButton {
                width: implicitWidth
                text: qsTr("Collectibles")
            }
            StatusTabButton {
                rightPadding: 0
                width: implicitWidth
                text: qsTr("Activity")
            }
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: Style.current.padding
            currentIndex: walletTabBar.currentIndex

            AssetsView {
                account: RootStore.currentAccount
            }
            CollectiblesView {}
            HistoryView {
                account: RootStore.currentAccount
            }
        }

        WalletFooter {
            Layout.fillWidth: true
            Layout.leftMargin: -root.StackView.view.anchors.leftMargin
            Layout.rightMargin: -root.StackView.view.anchors.rightMargin
            sendModal: root.sendModal
            walletStore: RootStore
        }
    }
}
