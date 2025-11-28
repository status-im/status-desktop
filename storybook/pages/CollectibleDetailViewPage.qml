import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Storybook

import AppLayouts.Communities.stores as CommunitiesStores
import AppLayouts.Wallet
import AppLayouts.Wallet.stores as WalletStores
import AppLayouts.Wallet.views.collectibles

import StatusQ.Core.Utils
import StatusQ.Core.Theme

import shared.controls
import shared.stores as SharedStores

import Models
import utils

SplitView {
    id: root

    QtObject {
        function isValidURL(url) {
            return true
        }

        Component.onCompleted: {
            Utils.globalUtilsInst = this
        }
        Component.onDestruction: {
            Utils.globalUtilsInst = {}
        }
    }

    QtObject {
        id: d

        readonly property QtObject collectiblesModel: ManageCollectiblesModel {
            Component.onCompleted: {
                d.refreshCurrentCollectible()
            }
        }
        property var currentCollectible

        function refreshCurrentCollectible() {
            currentCollectible = ModelUtils.get(collectiblesModel, collectibleComboBox.currentIndex)
        }

        readonly property QtObject transactionsModel: WalletTransactionsModel{}

        readonly property string addressesSelected: {
            let supportedAddresses = ""
            for (let i =0; i< accountsRepeater.count; i++) {
                if (accountsRepeater.itemAt(i).checked && accountsRepeater.itemAt(i).visible)
                    supportedAddresses += accountsRepeater.itemAt(i).address + ":"
            }
            return supportedAddresses
        }
    }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true
        Item {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            Rectangle {
                anchors.fill: viewLoader
                anchors.margins: -1
                color: "transparent"
                border.width: 1
                border.color: "#808080"
            }

            Loader {
                id: viewLoader
                anchors.fill: parent
                anchors.margins: 50

                active: false

                sourceComponent: CollectibleDetailView {
                    collectible: d.currentCollectible
                    isCollectibleLoading: isLoadingCheckbox.checked
                    activityModel: d.transactionsModel
                    addressFilters: d.addressesSelected
                    rootStore: SharedStores.RootStore {
                        readonly property string currentCurrency: "EUR"

                        function getFiatValue(cryptoValue, symbol) {
                            return cryptoValue * 0.1;
                        }

                        function formatCurrencyAmount(cryptoValue, symbol) {
                            return "%L1 %2".arg(cryptoValue).arg(symbol)
                        }
                    }
                    walletRootStore: WalletStores.RootStore
                    networksStore: SharedStores.NetworksStore {}

                    communitiesStore: CommunitiesStores.CommunitiesStore {
                        function getCommunityDetailsAsJson(communityId) {
                            if (communityId.indexOf("unknown") >= 0) {
                                return { name : "", image : "", color : "" }
                            }
                            return {
                                name : "Mock Community",
                                image : Assets.png("tokens/UNI"),
                                color : "orchid"
                            }                        
                        }
                    }
                }
                Component.onCompleted: viewLoader.active = true
            }
        }

        LogsAndControlsPanel {
            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 150

            SplitView.fillWidth: true
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        ColumnLayout {
            anchors.fill: parent
            Label {
                text: "Collectible:"
            }
            RowLayout {
                Layout.fillWidth: true
                ToolButton {
                    Layout.preferredWidth: 40
                    text: "←"
                    enabled: collectibleComboBox.currentIndex > 0
                    onClicked: collectibleComboBox.decrementCurrentIndex()
                }
                ComboBox {
                    id: collectibleComboBox
                    Layout.fillWidth: true
                    textRole: "name"
                    model: d.collectiblesModel
                    currentIndex: 0
                    onCurrentIndexChanged: d.refreshCurrentCollectible()
                }
                ToolButton {
                    Layout.preferredWidth: 40
                    text: "→"
                    enabled: collectibleComboBox.currentIndex < collectibleComboBox.count - 1
                    onClicked: collectibleComboBox.incrementCurrentIndex()
                }
            }
            CheckBox {
                id: isLoadingCheckbox
                text: "isLoading"
                checked: false
            }
            ColumnLayout {
                Layout.fillWidth: true
                Text {
                    text: "select account(s)"
                }
                Repeater {
                    id: accountsRepeater
                    model: WalletAccountsModel {}
                    delegate: CheckBox {
                        property string address: model.address
                        checked: true
                        visible: index<2
                        width: parent.width
                        text: name
                    }
                }
            }
            Item { Layout.fillHeight: true }
        }
    }
}

// category: Wallet
// status: good
