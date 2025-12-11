import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme

import utils
import shared.controls
import shared.stores as SharedStores

import AppLayouts.Wallet.stores as WalletStores

import Models
import Storybook

SplitView {
    id: root

    // mirrors ActivityEntry defined in src/app/modules/main/wallet_section/activity/entry.nim
    readonly property QtObject mockupModelData: QtObject {
        readonly property string id: "0xdeadbeef"
        readonly property int timestamp: Date.now() / 1000
        readonly property int status: ctrlStatus.currentValue
        readonly property double amount: 123.45
        readonly property double inAmount: amount
        readonly property double outAmount: amount
        readonly property string symbol: "SNT"
        readonly property string inSymbol: symbol
        readonly property string outSymbol: symbol
        readonly property bool isMultiTransaction: ctrlMultiTrans.checked

        readonly property int txType: ctrlType.currentValue
        readonly property string sender: "0xfB8131c260749c7835a08ccBdb64728De432858E"
        readonly property string recipient: "0x3fb81384583b3910BB14Cc72582E8e8a56E83ae9"
        readonly property bool isNFT: ctrlIsNft.checked
        readonly property bool isCommunityAssetViaAirdrop: isCommunityAssetViaAirdrop.checked
        readonly property string communityName: "Doodles"
        readonly property string communityImageUrl: Assets.png("collectibles/HappyMeow")
        readonly property string tokenID: "4981676894159712808201908443964193325271219637660871887967796332739046670337"
        readonly property string tokenAddress: "0xdeadbeef"
        readonly property string tokenInAddress: "0xdeadbeef-in"
        readonly property string tokenOutAddress: "0xdeadbeef-out"
        readonly property string nftName: "Happy Meow NFT"
        readonly property string nftImageUrl: Assets.png("collectibles/HappyMeow")
        readonly property int chainId: 1
        readonly property int chainIdIn: 1
        readonly property int chainIdOut: 2

        readonly property string interactedContractAddress: "0x6a000f20005980200259b80c5102003040001068"
        readonly property string approvalSpender: "0xDEF171Fe48CF0115B1d80b88dc8eAB59176FEe57"

        readonly property bool highlight: _highlight
        function doneHighlighting() {
            _highlight = false
        }
        property bool _highlight: false
    }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true
        Item {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            Rectangle {
                anchors.fill: column
                anchors.margins: -1
                border.color: "lightgray"
            }

            ColumnLayout {
                id: column

                anchors.centerIn: parent

                width: 600

                TransactionDelegate {
                    id: delegate
                    Layout.fillWidth: true
                    modelData: root.mockupModelData
                    showAllAccounts: ctrlAllAccounts.checked
                    currenciesStore: SharedStores.CurrenciesStore {
                        readonly property string currentCurrency: "EUR"

                        function getFiatValue(cryptoValue, symbol) {
                            return cryptoValue * 0.1;
                        }

                        function formatCurrencyAmount(cryptoValue, symbol) {
                            return "%L1 %2".arg(cryptoValue).arg(symbol)
                        }
                    }
                    flatNetworks: NetworksModel.flatNetworks
                    activityStore: WalletStores.RootStore
                }
            }
        }

        LogsAndControlsPanel {
            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 200

            SplitView.fillWidth: true
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        ColumnLayout {
            CheckBox {
                text: "Is loading"
                checked: delegate.loading
                onToggled: delegate.loading = checked
            }
            CheckBox {
                text: "Is activity details header"
                readonly property string headerState: "header"
                checked: delegate.state === headerState
                onToggled: delegate.state = checked ? headerState : ""
            }

            CheckBox {
                id: ctrlIsNft
                text: "Is NFT"
            }

            CheckBox {
                id: isCommunityAssetViaAirdrop
                checked: true
                text: "Is Community Asset Via Airdrop"
            }

            Label {
                Layout.topMargin: 10
                Layout.fillWidth: true
                text: "Transaction type:"
            }

            ComboBox {
                id: ctrlType
                Layout.fillWidth: true
                textRole: "name"
                valueRole: "type"
                model: ListModel {
                    ListElement { name: "Send"; type: Constants.TransactionType.Send }
                    ListElement { name: "Receive"; type: Constants.TransactionType.Receive }
                    ListElement { name: "Buy"; type: Constants.TransactionType.Buy }
                    ListElement { name: "Swap"; type: Constants.TransactionType.Swap }
                    ListElement { name: "Bridge"; type: Constants.TransactionType.Bridge }
                    ListElement { name: "ContractDeployment"; type: Constants.TransactionType.ContractDeployment }
                    ListElement { name: "Mint"; type: Constants.TransactionType.Mint }
                    ListElement { name: "Approve"; type: Constants.TransactionType.Approve }
                    ListElement { name: "Sell"; type: Constants.TransactionType.Sell }
                    ListElement { name: "Destroy"; type: Constants.TransactionType.Destroy }
                }
            }

            Label {
                Layout.topMargin: 10
                Layout.fillWidth: true
                text: "Transaction status:"
            }

            ComboBox {
                id: ctrlStatus
                Layout.fillWidth: true
                textRole: "name"
                valueRole: "status"
                model: ListModel {
                    ListElement { name: "Failed"; status: Constants.TransactionStatus.Failed }
                    ListElement { name: "Pending"; status: Constants.TransactionStatus.Pending }
                    ListElement { name: "Complete"; status: Constants.TransactionStatus.Complete }
                    ListElement { name: "Finalised"; status: Constants.TransactionStatus.Finalised }
                }
            }

            Switch {
                id: ctrlMultiTrans
                text: "Multi transaction"
            }

            Switch {
                id: ctrlAllAccounts
                text: "All Accounts"
            }

            Button {
                text: "New transaction"
                onClicked: {
                    mockupModelData._highlight = true
                }
            }
        }
    }
}

// category: Wallet
