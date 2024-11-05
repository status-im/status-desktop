import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import QtQml.Models 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.status 1.0
import shared.popups.send 1.0
import shared.stores.send 1.0

//TODO remove this dependency!
import AppLayouts.Chat.stores 1.0 as ChatStores
import AppLayouts.Wallet.stores 1.0

Item {
    id: root

    property ChatStores.RootStore store
    property var stickerPacks: ChatStores.StickerPackData {}
    property string packId
    property bool marketVisible
    property bool isWalletEnabled

    signal backClicked
    signal uninstallClicked(string packId)
    signal installClicked(var stickers, string packId, int index)
    signal cancelClicked(string packId)
    signal updateClicked(string packId)
    signal buyClicked(string packId, int price)

    StatusGridView {
        id: availableStickerPacks
        objectName: "stickerMarketStatusGridView"
        width: parent.width
        height: 380
        anchors.left: parent.left
        anchors.leftMargin: Theme.padding
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: Theme.padding
        cellWidth: parent.width - (Theme.padding * 2)
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

            readonly property bool walletEnabled: root.isWalletEnabled
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
                        spacing: Theme.padding / 2
                    }

                    contentWrapper.anchors.topMargin: 0
                    contentWrapper.anchors.bottomMargin: 0
                    contentWrapper.anchors.rightMargin: 0
                    StatusStickerList {
                        id: stickerGridInPopup
                        anchors.fill: parent
                        anchors.topMargin: Theme.padding
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
                        onBuyClicked: root.buyClicked(packId, price)
                    }
                }

                StatusStickerPackDetails {
                    id: stickerPackDetails
                    height: 64 - (Theme.smallPadding * 2)
                    width: parent.width - (Theme.padding * 2)
                    anchors.top: imgPreview.bottom
                    anchors.topMargin: Theme.smallPadding
                    anchors.bottomMargin: Theme.smallPadding
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
                        onBuyClicked: root.buyClicked(packId, price)
                    }
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
            anchors.leftMargin: Theme.padding / 2
            width: 24
            height: 24
            icon.width: 16
            icon.height: 16
            horizontalPadding: 0
            verticalPadding: 0
            onClicked: {
                root.backClicked()
            }
        }
    }
}
