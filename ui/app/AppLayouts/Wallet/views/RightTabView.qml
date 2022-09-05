import QtQuick 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared.views 1.0

import "./"
import "../stores"
import "../panels"
import "../views/collectibles"

Item {
    id: root

    property alias currentTabIndex: walletTabBar.currentIndex
    property var store
    property var contactsStore
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
                    objectName: "rightSideWalletTabBar"
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
                        assetDetailsLaunched: stack.currentIndex === 2
                        onAssetClicked: {
                            assetDetailView.token = token
                            stack.currentIndex = 2
                        }
                    }
                    CollectiblesView {
                        onCollectibleClicked: {
                            stack.currentIndex = 1
                        }
                    }
                    HistoryView {
                        account: RootStore.currentAccount
                        onLaunchTransactionDetail: {
                            transactionDetailView.transaction = transaction
                            stack.currentIndex = 3
                        }
                    }
                }
            }
            CollectibleDetailView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                onGoBack: stack.currentIndex = 0
            }
            AssetsDetailView {
                id: assetDetailView
                Layout.fillWidth: true
                Layout.fillHeight: true
                onGoBack: stack.currentIndex = 0
                visible: (stack.currentTabIndex === 2)
            }
            TransactionDetailView {
                id: transactionDetailView
                Layout.fillWidth: true
                Layout.fillHeight: true
                sendModal: root.sendModal
                contactsStore: root.contactsStore
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
