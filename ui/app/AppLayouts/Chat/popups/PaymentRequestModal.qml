import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import StatusQ 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components.private 0.1 as SQP
import StatusQ.Components 0.1
import StatusQ.Popups.Dialog 0.1

import AppLayouts.Wallet.controls 1.0
import AppLayouts.Wallet.adaptors 1.0

import shared.popups.send.views 1.0
import shared.controls 1.0
import StatusQ.Core.Utils 0.1 as SQUtils
import utils 1.0

StatusDialog {
    id: root

    // models
    required property string currentCurrency
    required property var flatNetworksModel
    required property var accountsModel
    required property var assetsModel
    property var formatCurrencyAmount: function() {}

    // input / output
    property int selectedNetworkChainId: Constants.chains.mainnetChainId
    property string selectedAccountAddress
    property string selectedTokenKey: Constants.ethToken

    readonly property string amount: {
        if (!d.isSelectedHoldingValidAsset || !d.selectedHolding.item.marketDetails || !d.selectedHolding.item.marketDetails.currencyPrice) {
            return "0"
        }
        return amountToSendInput.amount
    }

    objectName: "paymentRequestModal"

    implicitWidth: 480
    implicitHeight: 470

    modal: true
    padding: 0
    backgroundColor: Theme.palette.statusModal.backgroundColor

    title: qsTr("Payment request")

    onOpened: {
        // Setting value here because to prevent not updating when selected token key is filled
        d.selectedHolding.value = Qt.binding(function() { return root.selectedTokenKey })

        if (!!root.selectedTokenKey) {
            holdingSelector.setSelection(d.selectedHolding.item.symbol, d.selectedHolding.item.iconSource, d.selectedHolding.item.tokensKey)
        }
        amountToSendInput.forceActiveFocus()
    }

    QtObject {
        id: d

        readonly property ModelEntry selectedHolding: ModelEntry {
            sourceModel: holdingSelector.model
            key: "tokensKey"
        }

        readonly property bool isSelectedHoldingValidAsset: !!selectedHolding.item
    }

    footer: StatusDialogFooter {
        StatusDialogDivider {
            anchors.top: parent.top
            width: parent.width
        }
        rightButtons: ObjectModel {
            StatusButton {
                objectName: "addButton"
                text: qsTr("Add to message")
                disabledColor: Theme.palette.directColor8
                enabled: amountToSendInput.valid
                         && !amountToSendInput.empty
                         && amountToSendInput.amount > 0
                         && root.selectedAccountAddress !== ""
                         && root.selectedNetworkChainId > 0
                         && root.selectedTokenKey !== ""
                interactive: true
                onClicked: root.accept()
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
            objectName: "amountInput"
            Layout.fillWidth: true

            readonly property bool ready: valid && !empty

            multiplierIndex: d.isSelectedHoldingValidAsset && !!d.selectedHolding.item.decimals ? d.selectedHolding.item.decimals : 0
            price: d.isSelectedHoldingValidAsset && !!d.selectedHolding.item.marketDetails ? d.selectedHolding.item.marketDetails.currencyPrice.amount : 1

            formatFiat: amount => root.formatCurrencyAmount(
                            amount, root.currentCurrency)
            formatBalance: amount => root.formatCurrencyAmount(
                               amount, root.selectedTokenKey)

            showSeparator: true

            AssetSelector {
                id: holdingSelector
                objectName: "assetSelector"

                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: -(Theme.halfPadding / 2)

                model: root.assetsModel
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
            model: root.accountsModel
            Layout.fillWidth: true
            Layout.preferredHeight: 64

            size: StatusComboBox.Size.Large
            selectedAddress: root.selectedAccountAddress

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
            onCurrentAccountAddressChanged: {
                if (root.selectedAccountAddress === "")
                    selectedAddress = "" // Remove binding to prevent internal binding loop

                root.selectedAccountAddress = currentAccountAddress
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
                sourceModel: root.flatNetworksModel
                key: "chainId"
                value: root.selectedNetworkChainId ?? -1
            }

            model: root.flatNetworksModel

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
