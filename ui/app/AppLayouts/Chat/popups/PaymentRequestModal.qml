import QtQml.Models
import QtQuick
import QtQuick.Layouts

import StatusQ
import StatusQ.Components
import StatusQ.Components.private as SQP
import StatusQ.Controls
import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Core.Utils as SQUtils
import StatusQ.Popups.Dialog

import AppLayouts.Wallet.controls

import shared.controls
import shared.popups.send.views
import utils

import QtModelsToolkit

StatusDialog {
    id: root

    /**
     Expected model structure:
        chainId    [int]    - networks's unique chain identifier
        chainName  [string] - networks's chain name
        iconUrl    [string] - networks's icon url
    **/
    required property var flatNetworksModel
    /**
     Expected model structure:
        address  [string] - account's unique address
        name     [string] - account's name
        emoji    [string] - account's emoji
        color    [string] - account's wallet color
    **/
    required property var accountsModel
    /** Expected model structure: see SearchableAssetsPanel::model **/
    required property var assetsModel
    required property string currentCurrency
    property var formatCurrencyAmount: function() {}

    // input / output
    property int selectedNetworkChainId: Constants.chains.mainnetChainId
    property string selectedAccountAddress
    property string selectedTokenGroupKey: defaultTokenGroupKey
    // selected token key is automatically evaluated based on the selected group key and selected chain
    readonly property string selectedTokenKey: SQUtils.ModelUtils.getByKey(d.selectedHolding.item.tokens, "chainId", root.selectedNetworkChainId, "key")
    readonly property string symbol: d.selectedHolding.item.symbol


    readonly property string defaultTokenGroupKey: Utils.getNativeTokenGroupKey(selectedNetworkChainId)
    // output
    readonly property string amount: {
        if (!d.isSelectedHoldingValidAsset || !d.selectedHolding.item.marketDetails || !d.selectedHolding.item.marketDetails.currencyPrice) {
            return "0"
        }
        return amountToSendInput.amount
    }

    objectName: "paymentRequestModal"

    width: 480
    topPadding: Theme.bigPadding
    modal: true
    backgroundColor: Theme.palette.statusModal.backgroundColor

    title: qsTr("Payment request")

    onAboutToShow: {
        if (!!root.selectedTokenGroupKey && d.selectedHolding.available) {
            holdingSelector.setSelection(d.selectedHolding.item.symbol, d.selectedHolding.item.iconSource, d.selectedHolding.item.key)
        }
        if (!SQUtils.Utils.isMobile)
            amountToSendInput.forceActiveFocus()
    }

    QtObject {
        id: d

        function resetSelectedToken() {
            root.selectedTokenGroupKey = root.defaultTokenGroupKey
        }

        readonly property ModelEntry selectedHolding: ModelEntry {
            sourceModel: holdingSelector.model
            key: "key"
            value: root.selectedTokenGroupKey
            onValueChanged: {
                if (value !== undefined && !available) {
                    Qt.callLater(d.resetSelectedToken)
                } else {
                    holdingSelector.setSelection(d.selectedHolding.item.symbol, d.selectedHolding.item.iconSource, d.selectedHolding.item.key)
                }
            }
            onAvailableChanged: {
                if (value !== undefined && !available) {
                    Qt.callLater(d.resetSelectedToken)
                }
            }
        }

        readonly property bool isSelectedHoldingValidAsset: selectedHolding.available
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
                         && root.selectedTokenGroupKey !== ""
                interactive: true
                onClicked: root.accept()
            }
        }
    }

    contentItem: ColumnLayout {
        spacing: Theme.padding

        AmountToSend {
            id: amountToSendInput
            objectName: "amountInput"
            Layout.fillWidth: true

            readonly property bool ready: valid && !empty

            multiplierIndex: d.isSelectedHoldingValidAsset && !!d.selectedHolding.item.decimals ? d.selectedHolding.item.decimals : 0
            cryptoPrice: d.isSelectedHoldingValidAsset && !!d.selectedHolding.item.marketDetails ? d.selectedHolding.item.marketDetails.currencyPrice.amount : 0

            formatFiat: amount => root.formatCurrencyAmount(
                            amount, root.currentCurrency)
            formatBalance: amount => root.formatCurrencyAmount(
                               amount, root.selectedTokenGroupKey)

            dividerVisible: true
            selectedSymbol: amountToSendInput.fiatMode ?
                             root.currentCurrency:
                             d.isSelectedHoldingValidAsset ?
                                 d.selectedHolding.item.symbol : ""
            amountInputRightPadding: holdingSelector.width + Theme.padding

            AssetSelector {
                id: holdingSelector

                objectName: "assetSelector"

                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: (Theme.halfPadding / 2)

                model: root.assetsModel
                onSelected: {
                    root.selectedTokenGroupKey = groupKey
                }
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

            control.contentItem: StatusListItem {
                readonly property var network: networkSelector.singleSelectionItem.item
                width: parent.width
                title: network.chainName
                asset.height: 36
                asset.width: 36
                asset.isImage: true
                asset.name: Assets.svg(network.iconUrl)
                subTitle: qsTr("Only")
                leftPadding: 0
                rightPadding: 0
                statusListItemTitle.customColor: Theme.palette.directColor1
                bgColor: "transparent"
                enabled: false
            }

            popup.verticalPadding: 0
            delegate: StatusListItem {
                required property var model
                width: parent.width
                title: model.chainName
                asset.height: 36
                asset.width: 36
                asset.isImage: true
                asset.name: Assets.svg(model.iconUrl)
                subTitle: qsTr("Only")

                onClicked: {
                    root.selectedNetworkChainId = model.chainId
                    networkSelector.popup.close()
                }
            }
        }
    }
}
