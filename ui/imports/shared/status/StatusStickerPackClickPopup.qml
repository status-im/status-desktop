import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Core.Theme 0.1

import utils 1.0
import shared 1.0
import shared.popups 1.0
import shared.status 1.0
import shared.stores 1.0 as SharedStores
import shared.popups.send 1.0
import shared.stores.send 1.0

//TODO remove this dependency!
import AppLayouts.Chat.stores 1.0 as ChatStores

// TODO: replace with StatusModal
ModalPopup {
    id: root

    property string packId

    property ChatStores.RootStore store
    property string thumbnail: ""
    property string name: ""
    property string author: ""
    property string price
    property bool installed: false
    property bool bought: false
    property bool pending: false
    property var stickers
    signal buyClicked()

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
        packNameFontSize: Theme.secondaryAdditionalTextSize
        spacing: Theme.padding / 2
    }

    contentWrapper.anchors.topMargin: 0
    contentWrapper.anchors.bottomMargin: 0
    contentWrapper.anchors.rightMargin: 0
    StatusStickerList {
        id: stickerGridInPopup
        model: stickers
        anchors.fill: parent
        anchors.topMargin: Theme.padding
        packId: root.packId
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
            root.close()
        }
        onUninstallClicked: {
            stickersModule.uninstall(packId);
            root.close();
        }
        onCancelClicked: function(){}
        onUpdateClicked: function(){}
        onBuyClicked: root.buyClicked()
    }
}
