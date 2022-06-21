import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQml.Models 2.13

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

    GridView {
        id: availableStickerPacks
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
        clip: true
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
                    StatusSNTTransactionModal {
                        store: root.store
                        stickersStore: root.store.stickersStore
                        contractAddress: root.store.stickersStore.getStickersMarketAddress()
                        contactsStore: root.store.contactsStore
                        assetPrice: price
                        chainId: root.store.stickersStore.getChainIdForStickers()
                        estimateGasFunction: function(selectedAccount, uuid) {
                            if (packId < 0  || !selectedAccount || !price) return 325000
                            return root.store.stickersStore.estimate(packId, selectedAccount.address, price, uuid)
                        }
                        onSendTransaction: function(selectedAddress, gasLimit, gasPrice, tipLimit, overallLimit, password, eip1559Enabled) {
                            return root.store.stickersStore.buy(packId,
                                                                selectedAddress,
                                                                gasLimit,
                                                                gasPrice,
                                                                tipLimit,
                                                                overallLimit,
                                                                password,
                                                                eip1559Enabled)
                        }
                        onClosed: {
                            destroy()
                        }
                        asyncGasEstimateTarget: root.store.stickersStore.stickersModule
                        width: stickerPackDetailsPopup.width
                        height: stickerPackDetailsPopup.height
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
