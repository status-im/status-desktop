import QtQuick 2.13
import QtQuick.Layouts 1.13

import StatusQ.Controls 0.1

import utils 1.0
import shared.views 1.0

import "../stores"
import "../panels"
import "../views/collectibles"

Item {
    id: root

    property alias currentTabIndex: walletTabBar.currentIndex
    property var store
    property var sendModal

    ColumnLayout {
        anchors.fill: parent

        StackLayout {
            id: stack
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height - footer.height

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
                    CollectiblesView {
                        onCollectibleClicked: {
                            stack.currentIndex = 1
                        }
                    }
                    HistoryView {
                        account: RootStore.currentAccount
                    }
                }
            }
            CollectibleDetailView {
                anchors.fill: parent
                onGoBack: stack.currentIndex = 0
            }
        }

        WalletFooter {
            id: footer
            Layout.fillWidth: true
            Layout.leftMargin: -root.StackView.view.anchors.leftMargin
            Layout.rightMargin: -root.StackView.view.anchors.rightMargin
            sendModal: root.sendModal
            walletStore: RootStore
        }
    }
}
