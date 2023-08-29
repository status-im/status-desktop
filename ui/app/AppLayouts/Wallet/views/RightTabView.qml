import QtQuick 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared.controls 1.0
import shared.views 1.0
import shared.stores 1.0

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
    property var networkConnectionStore
    property bool showAllAccounts: false

    signal launchShareAddressModal()

    function resetView() {
        stack.currentIndex = 0
        root.currentTabIndex = 0
    }

    function resetStack() {
        stack.currentIndex = 0;
    }

    Connections {
        target: walletSection

        function onFilterChanged() {
            root.resetStack()
        }
    }

    QtObject {
        id: d
        function getBackButtonText(index) {
            switch(index) {
                case 1:
                return qsTr("Collectibles")
                case 2:
                return qsTr("Assets")
                case 3:
                return qsTr("Activity")
                default:
                return ""
            }
        }
    }

    StackLayout {
        id: stack
        anchors.fill: parent
        onCurrentIndexChanged: {
            RootStore.backButtonName = d.getBackButtonText(currentIndex)
        }

        ColumnLayout {
            spacing: 0
            WalletHeader {
                Layout.fillWidth: true
                overview: RootStore.overview
                store: root.store
                walletStore: RootStore
                networkConnectionStore: root.networkConnectionStore
                onLaunchShareAddressModal: root.launchShareAddressModal()
                onSwitchHideWatchOnlyAccounts: RootStore.toggleWatchOnlyAccounts()
            }

            ImportKeypairInfo {
                Layout.fillWidth: true
                Layout.topMargin: Style.current.bigPadding
                Layout.preferredHeight: childrenRect.height
                visible: root.store.walletSectionInst.hasPairedDevices && root.store.walletSectionInst.keypairOperabilityForObservedAccount === Constants.keypair.operability.nonOperable

                onRunImport: {
                    root.store.walletSectionInst.runKeypairImportPopup()
                }
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
                Layout.topMargin: Style.current.padding
                Layout.bottomMargin: Style.current.padding
                currentIndex: walletTabBar.currentIndex

                AssetsView {
                    assets: RootStore.assets
                    networkConnectionStore: root.networkConnectionStore
                    assetDetailsLaunched: stack.currentIndex === 2
                    onAssetClicked: {
                        assetDetailView.token = token
                        stack.currentIndex = 2
                    }
                }
                CollectiblesView {
                    collectiblesModel: RootStore.collectiblesStore.ownedCollectibles
                    onCollectibleClicked: {
                        RootStore.collectiblesStore.getDetailedCollectible(chainId, contractAddress, tokenId)
                        stack.currentIndex = 1
                    }
                }
                HistoryView {
                    overview: RootStore.overview
                    showAllAccounts: root.showAllAccounts
                    onLaunchTransactionDetail: function (entry, entryIndex) {
                        transactionDetailView.transactionIndex = entryIndex
                        transactionDetailView.transaction = entry

                        stack.currentIndex = 3
                    }
                }
            }
        }
        CollectibleDetailView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            collectible: RootStore.collectiblesStore.detailedCollectible
            isCollectibleLoading: RootStore.collectiblesStore.isDetailedCollectibleLoading
        }
        AssetsDetailView {
            id: assetDetailView

            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: (stack.currentIndex === 2)

            assetsLoading: RootStore.assetsLoading
            address: RootStore.overview.mixedcaseAddress

            networkConnectionStore: root.networkConnectionStore
        }

        TransactionDetailView {
            id: transactionDetailView
            Layout.fillWidth: true
            Layout.fillHeight: true
            onVisibleChanged: {
                if (!visible)
                    transaction = null
            }
            showAllAccounts: root.showAllAccounts
            sendModal: root.sendModal
            contactsStore: root.contactsStore
            visible: (stack.currentIndex === 3)
        }
    }
}
