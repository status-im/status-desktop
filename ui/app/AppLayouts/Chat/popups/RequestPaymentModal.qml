import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15
import QtGraphicalEffects 1.15

import StatusQ 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Components.private 0.1 as SQP
import StatusQ.Components 0.1
import StatusQ.Popups.Dialog 0.1

import AppLayouts.Wallet.controls 1.0
import AppLayouts.Wallet.adaptors 1.0

import shared.popups.send.views 1.0
import shared.controls 1.0
import shared.stores 1.0 as SharedStores
import utils 1.0

StatusDialog {
    id: root

    required property SharedStores.RequestPaymentStore store

    property int selectedNetworkChainId: Constants.chains.mainnetChainId
    property string selectedAccountAddress
    property string selectedTokenKey: Constants.ethToken
    onSelectedTokenKeyChanged: Qt.callLater(d.reevaluateSelectedId)

    readonly property string amount: {
        if (!d.isSelectedHoldingValidAsset || !d.selectedHolding.marketDetails || !d.selectedHolding.marketDetails.currencyPrice) {
            return "0"
        }
        return amountToSendInput.text
    }

    objectName: "requestPaymentModal"

    implicitWidth: 480
    implicitHeight: 470

    modal: true
    padding: 0
    backgroundColor: Theme.palette.statusModal.backgroundColor

    title: qsTr("Payment request")

    QtObject {
        id: d

        // FIXME use ModelEntry
        property var selectedHolding: SQUtils.ModelUtils.getByKey(holdingSelector.model, "tokensKey", root.selectedTokenKey)
        readonly property bool isSelectedHoldingValidAsset: !!selectedHolding

        readonly property var adaptor: TokenSelectorViewAdaptor {
            assetsModel: root.store.processedAssetsModel
            flatNetworksModel: root.flatNetworksModel
            currentCurrency: root.store.currencyStore.currentCurrency
            showAllTokens: true
        }

        // FIXME drop after using ModelEntry, shouldn't be needed
        function reevaluateSelectedId() {
            const entry = SQUtils.ModelUtils.getByKey(holdingSelector.model, "tokensKey", root.selectedTokenKey)

            if (entry) {
                holdingSelector.setSelection(entry.symbol, entry.iconSource, entry.tokensKey)
            } else {
                root.selectedTokenKey = ""
                holdingSelector.reset()
            }

            d.selectedHolding = entry
        }
    }

    footer: StatusDialogFooter {
        StatusDialogDivider {
            anchors.top: parent.top
            width: parent.width
        }
        rightButtons: ObjectModel {
            StatusButton {
                objectName: "sendButton"
                text: qsTr("Add to message")
                disabledColor: Theme.palette.directColor8
                enabled: amountToSendInput.valid && !amountToSendInput.empty && amountToSendInput.asNumber > 0
                interactive: true
                onClicked: {
                    // TODO_ES handle
                    root.accept()
                }
            }
        }
    }

    ColumnLayout {
        anchors.top: parent.top
        anchors.topMargin: Theme.bigPadding
        anchors.left: parent.left
        anchors.leftMargin: Theme.padding
        anchors.right: parent.right
        anchors.rightMargin: Theme.padding

        spacing: Theme.padding

        AmountToSend {
            id: amountToSendInput
            Layout.fillWidth: true

            readonly property bool ready: valid && !empty

            readonly property string selectedSymbol: root.selectedTokenKey

            // For backward compatibility. To be removed when
            // dependent components (NetworkSelector, AmountToReceive)
            // are refactored.
            readonly property double asNumber: {
                if (!valid)
                    return 0

                return parseFloat(text.replace(LocaleUtils.userInputLocale.decimalPoint, "."))
            }
            readonly property int minSendCryptoDecimals:
                !fiatMode ? LocaleUtils.fractionalPartLength(asNumber) : 0
            readonly property int minReceiveCryptoDecimals:
                !fiatMode ? minSendCryptoDecimals + 1 : 0
            readonly property int minSendFiatDecimals:
                fiatMode ? LocaleUtils.fractionalPartLength(asNumber) : 0
            readonly property int minReceiveFiatDecimals:
                fiatMode ? minSendFiatDecimals + 1 : 0
            // End of to-be-removed part

            multiplierIndex: 9
                // !!holdingSelector.selectedItem
                // && !!holdingSelector.selectedItem.decimals
                // ? holdingSelector.selectedItem.decimals : 0

            // price: d.isSelectedHoldingValidAsset
                   // ? (d.selectedHolding ?
                          // d.selectedHolding.marketDetails.currencyPrice.amount : 1)
                   // : 1
            price: 1

            formatFiat: amount => root.store.currencyStore.formatCurrencyAmount(
                            amount, root.store.currencyStore.currentCurrency)
            formatBalance: amount => root.store.currencyStore.formatCurrencyAmount(
                               amount, selectedSymbol)

            showSeparator: true
            onValidChanged: {

            }
            onAmountChanged: {

            }

            AssetSelector {
                id: holdingSelector

                anchors.top: parent.top
                anchors.right: parent.right

                model: d.adaptor.outputAssetsModel
                onSelected: root.selectedTokenKey = key
            }
        }

        StatusBaseText {
            text: qsTr("Into")
            color: Theme.palette.directColor5
            font.weight: Font.Medium
        }

        AccountSelector {
            id: accountSelector
            model: root.store.accountsModel
            Layout.fillWidth: true
            Layout.preferredHeight: 64

            size: StatusComboBox.Size.Large

            control.background: SQP.StatusComboboxBackground {
                active: accountSelector.control.down || accountSelector.control.hovered
            }

            popup.verticalPadding: 0
            popup.width: accountSelector.width
            control.contentItem: WalletAccountListItem {
                readonly property var account: accountSelector.currentAccount
                width: accountSelector.width
                height: accountSelector.height
                name: !!account ? account.name : ""
                address: !!account ? account.address : ""
                emoji: !!account ? account.emoji : ""
                walletColor: !!account ? account.color : ""

                leftPadding: 0
                rightPadding: 0
                statusListItemTitle.customColor: Theme.palette.directColor1
                enabled: false
            }
        }

        StatusBaseText {
            text: qsTr("On")
            color: Theme.palette.directColor5
            font.weight: Font.Medium
        }

        StatusComboBox {
            id: networkSelector
            objectName: "networkSelector"
            Layout.fillWidth: true
            Layout.preferredHeight: 64

            readonly property ModelEntry singleSelectionItem: ModelEntry {
                sourceModel: root.store.flatNetworksModel
                key: "chainId"
                value: root.selectedNetworkChainId ?? -1
            }

            model: root.store.flatNetworksModel

            control.background: SQP.StatusComboboxBackground {
                active: networkSelector.control.down || networkSelector.control.hovered
            }

            component NetworkDelegate: StatusListItem {
                required property var network
                width: parent.width
                title: network.chainName
                asset.height: 36
                asset.width: 36
                asset.isImage: true
                asset.name: Theme.svg(network.iconUrl)
                subTitle: qsTr("Only")
            }

            control.contentItem: NetworkDelegate {
                required property var model
                network: networkSelector.singleSelectionItem.item
                leftPadding: 0
                rightPadding: 0
                statusListItemTitle.customColor: Theme.palette.directColor1
                bgColor: "transparent"
                enabled: false
            }

            popup.verticalPadding: 0
            delegate: NetworkDelegate {
                required property var model
                network: model
                onClicked: {
                    root.selectedNetworkChainId = model.chainId
                    networkSelector.popup.close()
                }
            }
        }
    }
}
