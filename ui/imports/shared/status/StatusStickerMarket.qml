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

//TODO remove this dependency!
import AppLayouts.Chat.stores 1.0

Item {
    id: root

    property var store
    property var stickerPacks: StickerPackData {}
    property string packId

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
                        height: 44
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
                            Global.openPopup(stickerPackPurchaseModal)
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
                        packPrice: price
                        width: 75 // only needed for Qt Creator
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
                            Global.openPopup(stickerPackPurchaseModal)
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
            interactive: false
            sendType: Constants.SendType.StickersBuy
            preSelectedRecipient: root.store.stickersStore.getStickersMarketAddress()
            preDefinedAmountToSend: LocaleUtils.numberToLocaleString(parseFloat(price))
            preSelectedAsset: store.getAsset(buyStickersModal.store.currentAccount.assets, JSON.parse(root.store.stickersStore.getStatusToken()).symbol)
            sendTransaction: function() {
                if(bestRoutes.length === 1) {
                    let path = bestRoutes[0]
                    let eip1559Enabled = path.gasFees.eip1559Enabled
                    let maxFeePerGas = path.gasFees.maxFeePerGasM
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
                function onTransactionWasSent(txResult: string) {
                    try {
                        let response = JSON.parse(txResult)
                        if (!response.success) {
                            if (response.result.includes(Constants.walletSection.cancelledMessage)) {
                                return
                            }
                            buyStickersModal.sendingError.text = response.result
                            return buyStickersModal.sendingError.open()
                        }
                        for(var i=0; i<buyStickersModal.bestRoutes.length; i++) {
                            let url =  "%1/%2".arg(buyStickersModal.store.getEtherscanLink(buyStickersModal.bestRoutes[i].fromNetwork.chainId)).arg(response.result)
                            Global.displayToastMessage(qsTr("Transaction pending..."),
                                                       qsTr("View on etherscan"),
                                                       "",
                                                       true,
                                                       Constants.ephemeralNotificationType.normal,
                                                       url)
                        }
                        buyStickersModal.close()
                    } catch (e) {
                        console.error('Error parsing the response', e)
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
