import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

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
                preSelectedAsset: {
                    let assetsList = buyStickersPackModal.store.currentAccount.assets
                    for(var i=0; i< assetsList.count;i++) {
                        let symbol = JSON.parse(stickerPackDetailsPopup.store.stickersStore.getStatusToken()).symbol
                        if(symbol === assetsList.rowData(i, "symbol"))
                            return {
                                name: assetsList.rowData(i, "name"),
                                symbol: assetsList.rowData(i, "symbol"),
                                totalBalance: assetsList.rowData(i, "totalBalance"),
                                totalCurrencyBalance: assetsList.rowData(i, "totalCurrencyBalance"),
                                balances: assetsList.rowData(i, "balances"),
                                decimals: assetsList.rowData(i, "decimals")
                            }
                    }
                    return {}
                }
                sendTransaction: function() {
                    if(bestRoutes.length === 1) {
                        let path = bestRoutes[0]
                        let eip1559Enabled = path.gasFees.eip1559Enabled
                        let maxFeePerGas = (selectedPriority === 0) ? path.gasFees.maxFeePerGasL:
                                                                      (selectedPriority === 1) ? path.gasFees.maxFeePerGasM:
                                                                                                 path.gasFees.maxFeePerGasH
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
                    onTransactionWasSent: {
                        try {
                            let response = JSON.parse(txResult)
                            if (!response.success) {
                                if (Utils.isInvalidPasswordMessage(response.result)) {
                                    buyStickersPackModal.setSendTxError()
                                    return
                                }
                                buyStickersPackModal.sendingError.text = response.result
                                return buyStickersPackModal.sendingError.open()
                            }
                            let url = `${buyStickersPackModal.store.getEtherscanLink()}/${response.result}`;
                            Global.displayToastMessage(qsTr("Transaction pending..."),
                                                       qsTr("View on etherscan"),
                                                       "",
                                                       true,
                                                       Constants.ephemeralNotificationType.normal,
                                                       url)
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
