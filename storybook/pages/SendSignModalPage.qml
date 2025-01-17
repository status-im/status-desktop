import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Core.Theme 0.1

import Storybook 1.0
import Models 1.0

import AppLayouts.Wallet.popups.simpleSend 1.0

import utils 1.0

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

                    recipientAddress: ctrlRecipient.text

                    networkShortName: priv.selectedNetwork.shortName
                    networkName: priv.selectedNetwork.chainName
                    networkIconPath: Theme.svg(priv.selectedNetwork.iconUrl)
                    networkBlockExplorerUrl: priv.selectedNetwork.blockExplorerURL

                    fiatFees: formatBigNumber(42.542567, "EUR")
                    cryptoFees: formatBigNumber(0.06, "ETH")
                    estimatedTime: qsTr("> 5 minutes")

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

            TextField {
                Layout.fillWidth: true
                id: ctrlRecipient
                text: "0xA858DDc0445d8131daC4d1DE01f834ffcbA52Ef1"
                placeholderText: "Selected recipient"
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
