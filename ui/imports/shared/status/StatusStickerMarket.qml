import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQml.Models 2.13

import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.status 1.0
import shared.stores 1.0 as SharedStores
import shared.popups.send 1.0

//TODO remove this dependency!
import AppLayouts.Chat.stores 1.0

Item {
    id: root

    property var store
    property var stickerPacks: StickerPackData {}
    property string packId
    property bool marketVisible

    signal backClicked
    signal uninstallClicked(string packId)
    signal installClicked(var stickers, string packId, int index)
    signal cancelClicked(string packId)
    signal updateClicked(string packId)
    signal buyClicked(string packId)

    StatusGridView {
        id: availableStickerPacks
        objectName: "stickerMarketStatusGridView"
        width: parent.width
        height: 380
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: Style.current.padding
        cellWidth: parent.width - (Style.current.padding * 2)
        cellHeight: height - 72
        visible: root.marketVisible

        ScrollBar.vertical: StatusScrollBar {}

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

            readonly property bool walletEnabled: SharedStores.RootStore.isWalletEnabled
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
                    contentWrapper.anchors.rightMargin: 0
                    StatusStickerList {
                        id: stickerGridInPopup
                        anchors.fill: parent
                        anchors.topMargin: Style.current.padding
                        model: stickers
                        packId: root.packId
                    }

                    footer: StatusStickerButton {
                        objectName: "statusStickerMarketInstallButton"
                        anchors.right: parent.right
                        style: StatusStickerButton.StyleType.LargeNoIcon
                        packPrice: price
                        isInstalled: installed
                        isBought: bought
                        isPending: pending
                        greyedOut: !root.store.networkConnectionStore.stickersNetworkAvailable
                        tooltip.text: root.store.networkConnectionStore.stickersNetworkUnavailableText
                        onInstallClicked: root.installClicked(stickers, packId, index)
                        onUninstallClicked: root.uninstallClicked(packId)
                        onCancelClicked: root.cancelClicked(packId)
                        onUpdateClicked: root.updateClicked(packId)
                        onBuyClicked: {
                            Global.openPopup(stickerPackPurchaseModal, {price, packId})
                            root.buyClicked(packId)
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
                        anchors.verticalCenter: parent.verticalCenter
                        packPrice: price
                        isInstalled: installed
                        isBought: bought
                        isPending: pending
                        greyedOut: !root.store.networkConnectionStore.stickersNetworkAvailable
                        tooltip.text: root.store.networkConnectionStore.stickersNetworkUnavailableText
                        onInstallClicked: root.installClicked(stickers, packId, index)
                        onUninstallClicked: root.uninstallClicked(packId)
                        onCancelClicked: root.cancelClicked(packId)
                        onUpdateClicked: root.updateClicked(packId)
                        onBuyClicked: {
                            Global.openPopup(stickerPackPurchaseModal, {price, packId})
                            root.buyClicked(packId)
                        }
                    }
                }
            }
        }
    }

    Component {
        id: stickerPackPurchaseModal
        SendModal {
            id: buyStickersModal

            required property int price
            required property string packId

            interactive: false
            preSelectedSendType: Constants.SendType.StickersBuy
            preSelectedRecipient: root.store.stickersStore.getStickersMarketAddress()
            preDefinedAmountToSend: LocaleUtils.numberToLocaleString(parseFloat(price))
            preSelectedHoldingID: JSON.parse(root.store.stickersStore.getStatusToken()).symbol
            preSelectedHoldingType: Constants.TokenType.ERC20
            sendTransaction: function() {
                if(bestRoutes.count === 1) {
                    let path = bestRoutes.firstItem()
                    let eip1559Enabled = path.gasFees.eip1559Enabled
                    let maxFeePerGas = path.gasFees.maxFeePerGasM
                    root.store.stickersStore.authenticateAndBuy(packId,
                                                 store.selectedSenderAccount.address,
                                                 path.gasAmount,
                                                 eip1559Enabled ? "" : path.gasFees.gasPrice,
                                                 eip1559Enabled ? path.gasFees.maxPriorityFeePerGas : "",
                                                 eip1559Enabled ? maxFeePerGas : path.gasFees.gasPrice,
                                                 eip1559Enabled)
                }
            }
            Connections {
                target: root.store.stickersStore.stickersModule
                function onTransactionWasSent(chainId: int, txHash: string, error: string) {
                    if (!!error) {
                        if (error.includes(Constants.walletSection.cancelledMessage)) {
                            return
                        }
                        buyStickersModal.sendingError.text = error
                        return buyStickersModal.sendingError.open()
                    }
                    let url =  "%1/%2".arg(buyStickersModal.store.getEtherscanLink(chainId)).arg(txHash)
                    Global.displayToastMessage(qsTr("Transaction pending..."),
                                               qsTr("View on etherscan"),
                                               "",
                                               true,
                                               Constants.ephemeralNotificationType.normal,
                                               url)
                    buyStickersModal.close()
                }
            }
        }
    }

    Item {
        id: footer
        height: 44
        anchors.top: availableStickerPacks.bottom

        StatusBackButton {
            id: btnBack
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding / 2
            width: 24
            height: 24
            type: StatusRoundButton.Type.Secondary
            onClicked: {
                root.backClicked()
            }
        }
    }
}
