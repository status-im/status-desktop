import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import utils 1.0
import shared 1.0
import shared.popups 1.0
import shared.status 1.0
//TODO remove this dependency!
import "../../../app/AppLayouts/Chat/stores"

// TODO: replace with StatusModal
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
    signal buyClicked(int packId)

    Component.onCompleted: {
        const idx = stickersModule.stickerPacks.findIndexById(packId, false);
        if(idx === -1) close();
        name = stickersModule.stickerPacks.rowData(idx, "name")
        author = stickersModule.stickerPacks.rowData(idx, "author")
        thumbnail = stickersModule.stickerPacks.rowData(idx, "thumbnail")
        price = stickersModule.stickerPacks.rowData(idx, "price")
        stickers = stickersModule.stickerPacks.getStickers()
        installed = stickersModule.stickerPacks.rowData(idx, "installed") === "true"
        bought = stickersModule.stickerPacks.rowData(idx, "bought") === "true"
        pending = stickersModule.stickerPacks.rowData(idx, "pending") === "true"
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
        packId: stickerPackDetailsPopup.packId
        Component {
            id: stickerPackPurchaseModal
            StatusSNTTransactionModal {
                // Not Refactored Yet
//                contractAddress: utilsModel.stickerMarketAddress
                assetPrice: price
                estimateGasFunction: function(selectedAccount, uuid) {
                    if (packId < 0  || !selectedAccount || !price) return 325000
                    return stickersModule.estimate(packId, selectedAccount.address, price, uuid)
                }
                onSendTransaction: function(selectedAddress, gasLimit, gasPrice, tipLimit, overallLimit, password) {
                    return stickersModule.buy(packId,
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
            stickersModule.install(packId);
            stickerPackDetailsPopup.close();
        }
        onUninstallClicked: {
            stickersModule.uninstall(packId);
            stickerPackDetailsPopup.close();
        }
        onCancelClicked: function(){}
        onUpdateClicked: function(){}
        onBuyClicked: {
            Global.openPopup(stickerPackPurchaseModal);
            stickerPackDetailsPopup.buyClicked(packId);
        }
    }
}
