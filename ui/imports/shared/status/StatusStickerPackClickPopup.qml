import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

import utils 1.0
import shared 1.0
import shared.popups 1.0
import shared.status 1.0
import shared.stores 1.0 as SharedStores
import shared.popups.send 1.0
import shared.stores.send 1.0

//TODO remove this dependency!
import AppLayouts.Chat.stores 1.0 as ChatStores
import AppLayouts.Wallet.stores 1.0

// TODO: replace with StatusModal
ModalPopup {
    id: stickerPackDetailsPopup

    property string packId

    property ChatStores.RootStore store
    required property WalletAssetsStore walletAssetsStore
    required property var sendModalPopup
    property string thumbnail: ""
    property string name: ""
    property string author: ""
    property string price
    property bool installed: false
    property bool bought: false
    property bool pending: false
    property var stickers
    signal buyClicked(string packId)

    onAboutToShow: {
        stickersModule.getInstalledStickerPacks()

        const idx = stickersModule.stickerPacks.findIndexById(packId, false)
        if(idx === -1) close()
        const item = SQUtils.ModelUtils.get(stickersModule.stickerPacks, idx)
        name = item.name
        author = item.author
        thumbnail = item.thumbnail
        price = item.price
        stickers = item.stickers
        installed = item.installed
        bought = item.bought
        pending = item.pending
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
    contentWrapper.anchors.rightMargin: 0
    StatusStickerList {
        id: stickerGridInPopup
        model: stickers
        anchors.fill: parent
        anchors.topMargin: Style.current.padding
        packId: stickerPackDetailsPopup.packId
    }

    footer: StatusStickerButton {
        anchors.right: parent.right
        style: StatusStickerButton.StyleType.LargeNoIcon
        packPrice: price
        isInstalled: installed
        isBought: bought
        isPending: pending
        greyedOut: !store.networkConnectionStore.stickersNetworkAvailable
        tooltip.text: store.networkConnectionStore.stickersNetworkUnavailableText
        onInstallClicked: {
            stickersModule.install(packId)
            stickerPackDetailsPopup.close()
        }
        onUninstallClicked: {
            stickersModule.uninstall(packId);
            stickerPackDetailsPopup.close();
        }
        onCancelClicked: function(){}
        onUpdateClicked: function(){}
        onBuyClicked: {
            const token = SQUtils.ModelUtils.getByKey(stickerPackDetailsPopup.walletAssetsStore.groupedAccountAssetsModel, "tokensKey", stickerPackDetailsPopup.store.stickersStore.getStatusTokenKey())

            stickerPackDetailsPopup.sendModalPopup.interactive = false
            stickerPackDetailsPopup.sendModalPopup.preSelectedRecipient = stickerPackDetailsPopup.store.stickersStore.getStickersMarketAddress()
            stickerPackDetailsPopup.sendModalPopup.preSelectedRecipientType = Helpers.RecipientAddressObjectType.Address
            stickerPackDetailsPopup.sendModalPopup.preSelectedHoldingID = !!token && !!token.symbol ? token.symbol : ""
            stickerPackDetailsPopup.sendModalPopup.preSelectedHoldingType = Constants.TokenType.ERC20
            stickerPackDetailsPopup.sendModalPopup.preSelectedSendType = Constants.SendType.StickersBuy
            stickerPackDetailsPopup.sendModalPopup.preDefinedAmountToSend = LocaleUtils.numberToLocaleString(parseFloat(stickerPackDetailsPopup.price))
            stickerPackDetailsPopup.sendModalPopup.preSelectedChainId = stickerPackDetailsPopup.store.appNetworkId
            stickerPackDetailsPopup.sendModalPopup.stickersPackId = stickerPackDetailsPopup.packId
            stickerPackDetailsPopup.sendModalPopup.open()

            stickerPackDetailsPopup.buyClicked(stickerPackDetailsPopup.packId)
        }
    }
}
