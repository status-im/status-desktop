import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core.Utils
import StatusQ.Core.Theme

import Storybook
import Models

import AppLayouts.Wallet.popups.simpleSend

import utils

import QtModelsToolkit

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Horizontal

    property var dialog

    function createAndOpenDialog() {
        dialog = dlgComponent.createObject(popupBg)
        dialog.open()
    }

    Component.onCompleted: createAndOpenDialog()

    QtObject {
        id: priv

        readonly property var accountsModel: WalletAccountsModel {}
        readonly property var selectedAccount: selectedAccountEntry.item

        readonly property var recipientModel: ListModel {
            readonly property var data: [
                {
                    modelName: "Wallet A",
                    name: "Hot wallet",
                    emoji: "🚗",
                    colorId: Constants.walletAccountColors.army,
                    color: "#216266",
                    ens: "",
                    address: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881",
                },
                {
                    modelName: "Wallet B",
                    name: "helloworld",
                    emoji: "😋",
                    colorId: Constants.walletAccountColors.primary,
                    color: "#2A4AF5",
                    ens: "",
                    address: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240",
                },
                {
                    modelName: "ENS",
                    name: "Family (ens)",
                    emoji: "🎨",
                    colorId: Constants.walletAccountColors.magenta,
                    color: "#EC266C",
                    ens: "bation.eth",
                    address: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8882",
                },
                {
                    modelName: "Address",
                    name: "",
                    emoji: "",
                    colorId: "",
                    color: "",
                    ens: "",
                    address: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8883",
                },
            ]
            Component.onCompleted: append(data)
        }
        readonly property var selectedRecipient: selectedRecipientEntry.item

        readonly property var networksModel: NetworksModel.flatNetworks
        readonly property var selectedNetwork: selectedNetworkEntry.item
    }

    ModelEntry {
        id: selectedAccountEntry
        sourceModel: priv.accountsModel
        key: "address"
        value: ctrlAccount.currentValue
    }

    ModelEntry {
        id: selectedRecipientEntry
        sourceModel: priv.recipientModel
        key: "address"
        value: ctrlRecipient.currentValue
    }

    ModelEntry {
        id: selectedNetworkEntry
        sourceModel: priv.networksModel
        key: "chainId"
        value: ctrlNetwork.currentValue
    }

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        PopupBackground {
            id: popupBg
            anchors.fill: parent

            Button {
                anchors.centerIn: parent
                text: "Reopen"

                onClicked: createAndOpenDialog()
            }

            Component {
                id: dlgComponent
                SendSignModal {
                    anchors.centerIn: parent
                    destroyOnClose: true
                    modal: false

                    formatBigNumber: (number, symbol, noSymbolOption) => parseFloat(number).toLocaleString(Qt.locale(), 'f', 2)
                                     + (noSymbolOption ? "" : " " + (symbol || Qt.locale().currencySymbol(Locale.CurrencyIsoCode)))

                    tokenSymbol: ctrlFromSymbol.text
                    tokenAmount: ctrlFromAmount.text
                    tokenContractAddress: "0x6B175474E89094C44Da98b954EedeAC495271d0F"

                    accountName: priv.selectedAccount.name
                    accountAddress: priv.selectedAccount.address
                    accountEmoji: priv.selectedAccount.emoji
                    accountColor: Utils.getColorForId(priv.selectedAccount.colorId)

                    recipientAddress: priv.selectedRecipient.address
                    recipientName: priv.selectedRecipient.name
                    recipientEns: priv.selectedRecipient.ens
                    recipientEmoji: priv.selectedRecipient.emoji
                    recipientWalletColor: Utils.getColorForId(priv.selectedRecipient.colorId)

                    networkShortName: priv.selectedNetwork.shortName
                    networkName: priv.selectedNetwork.chainName
                    networkIconPath: Theme.svg(priv.selectedNetwork.iconUrl)
                    networkBlockExplorerUrl: priv.selectedNetwork.blockExplorerURL
                    networkChainId: priv.selectedNetwork.chainId

                    fromChainEIP1559Compliant: true
                    fromChainNoBaseFee: false
                    fromChainNoPriorityFee: false

                    currentGasPrice: "0"
                    currentBaseFee: "8.2"
                    currentSuggestedMinPriorityFee: "0.06"
                    currentSuggestedMaxPriorityFee: "5.1"
                    currentGasAmount: "31500"
                    currentNonce: 21

                    normalPrice: "1.45 EUR"
                    normalGasPrice: "0"
                    normalBaseFee: "10000"
                    normalPriorityFee: "1000"
                    normalTime: 60
                    fastPrice: "1.65 EUR"
                    fastBaseFee: "100000"
                    fastPriorityFee: "10000"
                    fastTime: 40
                    urgentPrice: "1.85 EUR"
                    urgentBaseFee: "1000000"
                    urgentPriorityFee: "100000"
                    urgentTime: 15

                    customGasPrice: "0"
                    customBaseFee: "10000"
                    customPriorityFee: "1000"
                    customGasAmount: "35000"
                    customNonce: 22

                    selectedFeeMode: Constants.FeePriorityModeType.Normal

                    fnGetPriceInCurrencyForFee: function(feeInWei) {
                        return "0.25 USD"
                    }

                    fnGetPriceInNativeTokenForFee: function(feeInWei) {
                        return "0.000123 ETH"
                    }

                    fnGetEstimatedTime: function(gasPrice, baseFeeInWei, priorityFeeInWei) {
                        return 0
                    }

                    fiatFees: formatBigNumber(42.542567, "EUR")
                    cryptoFees: formatBigNumber(0.06, "ETH")
                    estimatedTime: qsTr("~60s")

                    isCollectibleLoading: isCollectibleLoadingCheckbox.checked
                    isCollectible: isCollectibleCheckbox.checked
                    collectibleContractAddress: !!collectibleComboBox.currentCollectible ?
                                                    collectibleComboBox.currentCollectible.contractAddress: ""
                    collectibleTokenId: !!collectibleComboBox.currentCollectible ?
                                        collectibleComboBox.currentCollectible.tokenId: ""
                    collectibleName: !!collectibleComboBox.currentCollectible ?
                                         collectibleComboBox.currentCollectible.name: ""
                    collectibleBackgroundColor: !!collectibleComboBox.currentCollectible ?
                                                    collectibleComboBox.currentCollectible.backgroundColor: ""
                    collectibleIsMetadataValid: !!collectibleComboBox.currentCollectible ?
                                                    collectibleComboBox.currentCollectible.isMetadataValid : false
                    collectibleMediaUrl: !!collectibleComboBox.currentCollectible ?
                                             collectibleComboBox.currentCollectible.mediaUrl ?? "" : ""
                    collectibleMediaType: ""
                    collectibleFallbackImageUrl:!!collectibleComboBox.currentCollectible ?
                                                    collectibleComboBox.currentCollectible.imageUrl : ""

                    loginType: ctrlLoginType.currentIndex

                    feesLoading: ctrlLoading.checked

                    expirationSeconds: !!ctrlExpiration.text && parseInt(ctrlExpiration.text) ? parseInt(ctrlExpiration.text) : 0
                    onExpirationSecondsChanged: requestTimestamp = new Date()

                    fnGetOpenSeaExplorerUrl: function(networkShortName) {
                        return "%1/assets/%2".arg(Constants.openseaExplorerLinks.mainnetLink).arg(Constants.openseaExplorerLinks.ethereum)
                    }

                    onAccepted: logs.logEvent("accepted")
                    onRejected: logs.logEvent("rejected")
                    onClosed: logs.logEvent("closed")
                }
            }
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumWidth: 250
        SplitView.preferredWidth: 250

        logsView.logText: logs.logText

        ColumnLayout {
            Layout.fillWidth: true
            TextField {
                Layout.fillWidth: true
                id: ctrlFromSymbol
                text: "DAI"
                placeholderText: "From symbol"
            }
            CheckBox {
                id: isCollectibleCheckbox
                text:"is collectible"
            }
            CheckBox {
                id: isCollectibleLoadingCheckbox
                text:"is collectible loading"
            }
            ComboBox {
                id: collectibleComboBox
                property var currentCollectible
                Layout.fillWidth: true
                textRole: "name"
                model: ManageCollectiblesModel {}
                currentIndex: 0
                onCurrentIndexChanged: {
                    currentCollectible = ModelUtils.get(model, collectibleComboBox.currentIndex)
                }
                enabled: isCollectibleCheckbox.checked
            }
            Text {
                text: "Selected Send Amount"
            }
            TextField {
                Layout.fillWidth: true
                id: ctrlFromAmount
                text: "100"
                placeholderText: "From amount"
            }
            Text {
                text: "Selected From Account"
            }
            ComboBox {
                id: ctrlAccount
                textRole: "name"
                valueRole: "address"
                model: priv.accountsModel
                currentIndex: 0
            }

            Text {
                text: "Selected Recipient"
            }
            ComboBox {
                id: ctrlRecipient
                textRole: "modelName"
                valueRole: "address"
                model: priv.recipientModel
                currentIndex: 0
            }

            Text {
                text: "Selected Network"
            }
            ComboBox {
                id: ctrlNetwork
                textRole: "chainName"
                valueRole: "chainId"
                model: priv.networksModel
                currentIndex: 0
            }

            Switch {
                id: ctrlLoading
                text: "Fees loading"
            }

            Text {
                text: "Login Type"
            }
            ComboBox {
                id: ctrlLoginType
                model: Constants.authenticationIconByType
            }

            TextField {
                id: ctrlExpiration
                placeholderText: "Expiration in seconds"
            }
        }
    }
}

// category: Popups

// https://www.figma.com/design/FkFClTCYKf83RJWoifWgoX/Wallet-v2?node-id=25214-40565&m=dev
