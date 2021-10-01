import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import utils 1.0
import "../../shared"
import "../../shared/status"
//TODO remove this!
import "../../app/AppLayouts/Chat/stores"

ModalPopup {
    id: stickerPackDetailsPopup

    property int packId: -1

    property string thumbnail: ""
    property string name: ""
    property string author: ""
    property string price: ""
    property bool installed: false;
    property bool bought: false;
    property bool pending: false;
    property var stickers;

    Component.onCompleted: {
        const idx = chatsModel.stickers.stickerPacks.findIndexById(packId, false);
        if(idx === -1) close();
        name = chatsModel.stickers.stickerPacks.rowData(idx, "name")
        author = chatsModel.stickers.stickerPacks.rowData(idx, "author")
        thumbnail = chatsModel.stickers.stickerPacks.rowData(idx, "thumbnail")
        price = chatsModel.stickers.stickerPacks.rowData(idx, "price")
        stickers = chatsModel.stickers.stickerPacks.getStickers()
        installed = chatsModel.stickers.stickerPacks.rowData(idx, "installed") === "true"
        bought = chatsModel.stickers.stickerPacks.rowData(idx, "bought") === "true"
        pending = chatsModel.stickers.stickerPacks.rowData(idx, "pending") === "true"
    }

    height: 472
    header: StatusStickerPackDetails {
        id: stickerGrid
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
        model: stickers
        anchors.fill: parent
        anchors.topMargin: Style.current.padding
        Component {
            id: stickerPackPurchaseModal
            StatusSNTTransactionModal {
                contractAddress: utilsModel.stickerMarketAddress
                assetPrice: price
                estimateGasFunction: function(selectedAccount, uuid) {
                    if (packId < 0  || !selectedAccount || !price) return 325000
                    return chatsModel.stickers.estimate(packId, selectedAccount.address, price, uuid)
                }
                onSendTransaction: function(selectedAddress, gasLimit, gasPrice, tipLimit, overallLimit, password) {
                    return chatsModel.stickers.buy(packId,
                                                   selectedAddress,
                                                   price,
                                                   gasLimit,
                                                   gasPrice,
                                                   tipLimit,
                                                   overallLimit,
                                                   password)
                }
                onClosed: {
                    destroy()
                }
                width: stickerPackDetailsPopup.width
                height: stickerPackDetailsPopup.height
            }
        }
    }

    footer: StatusStickerButton {
        height: 44
        anchors.right: parent.right
        style: StatusStickerButton.StyleType.LargeNoIcon
        packPrice: price
        isInstalled: installed
        isBought: bought
        isPending: pending
        onInstallClicked: {
            chatsModel.stickers.install(packId);
            stickerPackDetailsPopup.close();
        }
        onUninstallClicked: {
            chatsModel.stickers.uninstall(packId);
            stickerPackDetailsPopup.close();
        }
        onCancelClicked: function(){}
        onUpdateClicked: function(){}
        onBuyClicked: {
            openPopup(stickerPackPurchaseModal)
            root.buyClicked(packId)
        }
    }
}
