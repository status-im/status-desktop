import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import StatusQ.Core 0.1

import utils 1.0
import shared 1.0
import shared.popups 1.0
import shared.status 1.0
import shared.stores 1.0 as SharedStores

//TODO remove this dependency!
import "../../../app/AppLayouts/Chat/stores"

// TODO: replace with StatusModal
ModalPopup {
    id: stickerPackDetailsPopup

    property int packId: -1

    property var store
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
            SendModal {
                id: buyStickersPackModal
                interactive: false
                sendType: Constants.SendType.StickersBuy
                preSelectedRecipient: stickerPackDetailsPopup.store.stickersStore.getStickersMarketAddress()
                preDefinedAmountToSend: LocaleUtils.numberToLocaleString(parseFloat(price))
                preSelectedAsset: store.getAsset(buyStickersPackModal.store.currentAccount.assets, JSON.parse(stickerPackDetailsPopup.store.stickersStore.getStatusToken()).symbol)
                sendTransaction: function() {
                    if(bestRoutes.length === 1) {
                        let path = bestRoutes[0]
                        let eip1559Enabled = path.gasFees.eip1559Enabled
                        let maxFeePerGas = path.gasFees.maxFeePerGasM
                        stickerPackDetailsPopup.store.stickersStore.authenticateAndBuy(packId,
                                                                                       selectedAccount.address,
                                                                                       path.gasAmount,
                                                                                       eip1559Enabled ? "" : path.gasFees.gasPrice,
                                                                                       eip1559Enabled ? path.gasFees.maxPriorityFeePerGas : "",
                                                                                       eip1559Enabled ? maxFeePerGas : path.gasFees.gasPrice,
                                                                                       eip1559Enabled)
                    }
                }
                Connections {
                    target: stickerPackDetailsPopup.store.stickersStore.stickersModule
                    function onTransactionWasSent(txResult: string) {
                        try {
                            let response = JSON.parse(txResult)
                            if (!response.success) {
                                if (response.result.includes(Constants.walletSection.cancelledMessage)) {
                                    return
                                }
                                buyStickersPackModal.sendingError.text = response.result
                                return buyStickersPackModal.sendingError.open()
                            }
                            for(var i=0; i<buyStickersPackModal.bestRoutes.length; i++) {
                                let txHash = response.result[buyStickersPackModal.bestRoutes[i].fromNetwork.chainId]
                                let url =  "%1/%2".arg(buyStickersPackModal.store.getEtherscanLink(buyStickersPackModal.bestRoutes[i].fromNetwork.chainId)).arg(response.result)
                                Global.displayToastMessage(qsTr("Transaction pending..."),
                                                           qsTr("View on etherscan"),
                                                           "",
                                                           true,
                                                           Constants.ephemeralNotificationType.normal,
                                                           url)
                            }
                            buyStickersPackModal.close()
                        } catch (e) {
                            console.error('Error parsing the response', e)
                        }
                    }
                }
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
        greyedOut: store.networkConnectionStore.stickersNetworkAvailable
        tooltip.text: root.store.networkConnectionStore.stickersNetworkUnavailableText
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
