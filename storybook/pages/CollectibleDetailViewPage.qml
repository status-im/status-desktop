import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Storybook 1.0

import AppLayouts.Wallet 1.0
import AppLayouts.Wallet.stores 1.0 as WalletStores
import AppLayouts.Wallet.views.collectibles 1.0

import StatusQ.Core.Utils 0.1

import shared.controls 1.0
import shared.stores 1.0

import Models 1.0
import utils 1.0

SplitView {
    id: root

    QtObject {
        id: d

        readonly property QtObject collectiblesModel: WalletCollectiblesModel {
            Component.onCompleted: {
                d.refreshCurrentCollectible()
            }
        }
        property var currentCollectible

        function refreshCurrentCollectible() {
            currentCollectible = ModelUtils.get(collectiblesModel, collectibleComboBox.currentIndex)
        }

        readonly property QtObject transactionsModel: WalletTransactionsModel{}
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
                    rootStore: QtObject {
                        readonly property string currentCurrency: "EUR"

                        function getFiatValue(cryptoValue, symbol) {
                            return cryptoValue * 0.1;
                        }

                        function formatCurrencyAmount(cryptoValue, symbol) {
                            return "%L1 %2".arg(cryptoValue).arg(symbol)
                        }
                    }
                    walletRootStore: QtObject {
                        function getNameForAddress(address) {
                            return "NAMEFOR: %1".arg(address)
                        }

                        function getExplorerNameForNetwork(networkName) {
                            return qsTr("%1 Explorer").arg(networkName)
                        }

                        readonly property bool showAllAccounts: true
                    }
                    communitiesStore: QtObject {
                        function getCommunityDetailsAsJson(communityId) {
                            return {
                                name : "Mock Community",
                                image : Style.png("tokens/UNI"),
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
            Label {
                text: "Collectible:"
            }
            ComboBox {
                id: collectibleComboBox
                Layout.fillWidth: true
                textRole: "name"
                model: d.collectiblesModel
                currentIndex: 0
                onCurrentIndexChanged: d.refreshCurrentCollectible()
            }
            CheckBox {
                id: isLoadingCheckbox
                text: "isLoading"
                checked: false
            }
        }
    }
}

// category: Wallet
