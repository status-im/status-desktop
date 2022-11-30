import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQml.Models 2.13

import StatusQ.Core 0.1

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.status 1.0
import shared.stores 1.0 as SharedStores

//TODO remove this dependency!
import AppLayouts.Chat.stores 1.0

Item {
    id: root

    property var store
    property var stickerPacks: StickerPackData {}
    property int packId: -1

    signal backClicked
    signal uninstallClicked(int packId)
    signal installClicked(var stickers, int packId, int index)
    signal cancelClicked(int packId)
    signal updateClicked(int packId)
    signal buyClicked(int packId)

    StatusGridView {
        id: availableStickerPacks
        objectName: "stickerMarketStatusGridView"
        width: parent.width
        height: 380
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        anchors.top: parent.top
        anchors.topMargin: Style.current.padding
        cellWidth: parent.width - (Style.current.padding * 2)
        cellHeight: height - 72

        focus: true
        model: DelegateModel {
            id: delegateModel

            function update() {
                if (items.count > 0) {
                    items.setGroups(0, items.count, "items");
                }

                var visible = [];
                for (var i = 0; i < items.count; ++i) {
                    var item = items.get(i);
                    if (delegateModel.walletEnabled ||
                        !delegateModel.walletEnabled && item.model.price == 0) {
                        visible.push(item);
                    }
                }

                for (i = 0; i < visible.length; ++i) {
                    item = visible[i];
                    item.inVisible = true;
                    if (item.visibleIndex !== i) {
                        visibleItems.move(item.visibleIndex, i, 1);
                    }
                }
            }

            readonly property bool walletEnabled: localAccountSensitiveSettings.isWalletEnabled
            onWalletEnabledChanged: {
                update()
            }

            model: stickerPacks
            items.onChanged: update()
            filterOnGroup: "visible"
            groups: DelegateModelGroup {
                id: visibleItems

                name: "visible"
                includeByDefault: false
            }

            delegate: Item {
                objectName: "stickerMarketDelegateItem" + index
                readonly property string packId: model.packId // This property is necessary for the tests
                readonly property bool installed: model.installed // This property is necessary for the tests
                width: availableStickerPacks.cellWidth
                height: availableStickerPacks.cellHeight
                RoundedImage {
                    id: imgPreview
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 220
                    width: parent.width
                    radius: 12
                    source: model.preview
                    onClicked: {
                        stickerPackDetailsPopup.open()
                    }
                }

                // TODO: replace with StatusModal
                ModalPopup {
                    id: stickerPackDetailsPopup
                    height: 540
                    header: StatusStickerPackDetails {
                        packThumb: thumbnail
                        packName: name
                        packAuthor: author
                        packNameFontSize: 17
                        spacing: Style.current.padding / 2
                    }

                    contentWrapper.anchors.topMargin: 0
                    contentWrapper.anchors.bottomMargin: 0
                    StatusStickerList {
                        id: stickerGridInPopup
                        anchors.fill: parent
                        anchors.topMargin: Style.current.padding
                        model: stickers
                        packId: root.packId
                    }

                    footer: StatusStickerButton {
                        objectName: "statusStickerMarketInstallButton"
                        height: 44
                        anchors.right: parent.right
                        style: StatusStickerButton.StyleType.LargeNoIcon
                        packPrice: price
                        isInstalled: installed
                        isBought: bought
                        isPending: pending
                        onInstallClicked: root.installClicked(stickers, packId, index)
                        onUninstallClicked: root.uninstallClicked(packId)
                        onCancelClicked: root.cancelClicked(packId)
                        onUpdateClicked: root.updateClicked(packId)
                        onBuyClicked: {
                            Global.openPopup(stickerPackPurchaseModal)
                            root.buyClicked(packId)
                        }
                    }
                }
                Component {
                    id: stickerPackPurchaseModal
                    SendModal {
                        id: buyStickersModal
                        interactive: false
                        sendType: Constants.SendType.StickersBuy
                        preSelectedRecipient: root.store.stickersStore.getStickersMarketAddress()
                        preDefinedAmountToSend: LocaleUtils.numberToLocaleString(parseFloat(price))
                        preSelectedAsset: {
                            let assetsList = buyStickersModal.store.currentAccount.assets
                            for(var i=0; i< assetsList.count;i++) {
                                let symbol = JSON.parse(root.store.stickersStore.getStatusToken()).symbol
                                if(symbol === assetsList.rowData(i, "symbol"))
                                    return {
                                        name: assetsList.rowData(i, "name"),
                                        symbol: assetsList.rowData(i, "symbol"),
                                        totalBalance: assetsList.rowData(i, "totalBalance"),
                                        totalCurrencyBalance: assetsList.rowData(i, "totalCurrencyBalance"),
                                        balances: assetsList.rowData(i, "balances"),
                                        decimals: assetsList.rowData(i, "decimals")
                                    }
                            }
                            return {}
                        }
                        sendTransaction: function() {
                            if(bestRoutes.length === 1) {
                                let path = bestRoutes[0]
                                let eip1559Enabled = path.gasFees.eip1559Enabled
                                let maxFeePerGas = (selectedPriority === 0) ? path.gasFees.maxFeePerGasL:
                                                                              (selectedPriority === 1) ? path.gasFees.maxFeePerGasM:
                                                                                                         path.gasFees.maxFeePerGasH
                                root.store.stickersStore.authenticateAndBuy(packId,
                                                             selectedAccount.address,
                                                             path.gasAmount,
                                                             eip1559Enabled ? "" : path.gasFees.gasPrice,
                                                             eip1559Enabled ? path.gasFees.maxPriorityFeePerGas : "",
                                                             eip1559Enabled ? maxFeePerGas : path.gasFees.gasPrice,
                                                             eip1559Enabled)
                            }
                        }
                        Connections {
                            target: root.store.stickersStore.stickersModule
                            onTransactionWasSent: {
                                try {
                                    let response = JSON.parse(txResult)
                                    if (!response.success) {
                                        if (response.result.includes(Constants.walletSection.cancelledMessage)) {
                                            return
                                        }
                                        buyStickersModal.sendingError.text = response.result
                                        return buyStickersModal.sendingError.open()
                                    }
                                    let url = `${buyStickersModal.store.getEtherscanLink()}/${response.result}`;
                                    Global.displayToastMessage(qsTr("Transaction pending..."),
                                                               qsTr("View on etherscan"),
                                                               "",
                                                               true,
                                                               Constants.ephemeralNotificationType.normal,
                                                               url)
                                    buyStickersModal.close()
                                } catch (e) {
                                    console.error('Error parsing the response', e)
                                }
                            }
                        }
                    }
                }

                StatusStickerPackDetails {
                    id: stickerPackDetails
                    height: 64 - (Style.current.smallPadding * 2)
                    width: parent.width - (Style.current.padding * 2)
                    anchors.top: imgPreview.bottom
                    anchors.topMargin: Style.current.smallPadding
                    anchors.bottomMargin: Style.current.smallPadding
                    anchors.left: parent.left
                    anchors.right: parent.right
                    packThumb: thumbnail
                    packName: name
                    packAuthor: author

                    StatusStickerButton {
                        anchors.right: parent.right
                        packPrice: price
                        width: 75 // only needed for Qt Creator
                        isInstalled: installed
                        isBought: bought
                        isPending: pending
                        onInstallClicked: root.installClicked(stickers, packId, index)
                        onUninstallClicked: root.uninstallClicked(packId)
                        onCancelClicked: root.cancelClicked(packId)
                        onUpdateClicked: root.updateClicked(packId)
                        onBuyClicked: {
                            if (!SharedStores.RootStore.isWalletEnabled) {
                                confirmationPopup.open()
                                return
                            }
                            Global.openPopup(stickerPackPurchaseModal)
                            root.buyClicked(packId)
                        }
                    }
                }

                ConfirmationDialog {
                    id: confirmationPopup
                    showCancelButton: true
                    confirmationText: qsTr("This feature is experimental and is meant for testing purposes by core contributors and the community. It's not meant for real use and makes no claims of security or integrity of funds or data. Use at your own risk.")
                    confirmButtonLabel: qsTr("I understand")
                    onConfirmButtonClicked: {
                        SharedStores.RootStore.enableWallet();
                        close()
                        Global.openPopup(stickerPackPurchaseModal)
                        root.buyClicked(packId)
                    }

                    onCancelButtonClicked: {
                        close()
                    }
                }
            }
        }
    }

    Item {
        id: footer
        height: 44 - Style.current.padding
        anchors.top: availableStickerPacks.bottom

        RoundedIcon {
            id: btnBack
            anchors.top: parent.top
            anchors.topMargin: Style.current.padding / 2
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding / 2
            width: 28
            height: 28
            iconWidth: 17.5
            iconHeight: 13.5
            iconColor: Style.current.roundedButtonSecondaryForegroundColor
            source: Style.svg("arrowUp")
            rotation: 270
            onClicked: {
                root.backClicked()
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;height:440;width:360}
}
##^##*/
