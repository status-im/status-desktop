import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import "../../imports"
import "../../shared"
import "../../shared/status"
import "../../app/AppLayouts/Chat/ChatColumn/samples"

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
        height: 76
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: Style.current.padding
        width: parent.width - (Style.current.padding * 2)
        packThumb: thumbnail
        packName: name
        packAuthor: author
        packNameFontSize: 17
        spacing: Style.current.padding / 2
    }
    footer: StatusStickerButton {
        height: 76
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
    contentWrapper.anchors.topMargin: 0
    contentWrapper.anchors.bottomMargin: 0
    StatusStickerList {
        id: stickerGridInPopup
        model: stickers
        height: 350
        Component {
        id: stickerPackPurchaseModal
        StatusStickerPackPurchaseModal {
            onClosed: {
                destroy()
            }
            stickerPackId: packId
            packPrice: price
            width: stickerPackDetailsPopup.width
            height: stickerPackDetailsPopup.height
            showBackBtn: stickerPackDetailsPopup.opened
        }
    }
    }
}
