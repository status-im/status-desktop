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
import "../../../app/AppLayouts/Chat/stores"
import AppLayouts.Wallet.stores 1.0

// TODO: replace with StatusModal
ModalPopup {
    id: stickerPackDetailsPopup

    property string packId

    property var store
    required property TransactionStore transactionStore
    required property WalletAssetsStore walletAssetsStore
    property string thumbnail: ""
    property string name: ""
    property string author: ""
    property string price
    property bool installed: false;
    property bool bought: false;
    property bool pending: false;
    property var stickers;
    signal buyClicked(string packId)

    Component.onCompleted: {
        const idx = stickersModule.stickerPacks.findIndexById(packId, false);
        if(idx === -1) close();
        const item = SQUtils.ModelUtils.get(stickersModule.stickerPacks, idx)
        name = item.name
        author = item.author
        thumbnail = item.thumbnail
        price = item.price
        stickers = stickersModule.stickerPacks.getStickers()
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
        Component {
            id: stickerPackPurchaseModal
            SendModal {
                id: buyStickersPackModal
                interactive: false
                store: stickerPackDetailsPopup.transactionStore
                preSelectedSendType: Constants.SendType.StickersBuy
                preSelectedRecipient: stickerPackDetailsPopup.store.stickersStore.getStickersMarketAddress()
                preDefinedAmountToSend: LocaleUtils.numberToLocaleString(parseFloat(price))
                preSelectedHoldingID: {
                    let token = ModelUtils.getByKey(root.walletAssetsStore.groupedAccountAssetsModel, "tokensKey", stickerPackDetailsPopup.store.stickersStore.getStatusTokenKey())
                    return !!token && !!token.symbol ? token.symbol : ""
                }
                preSelectedHoldingType: Constants.TokenType.ERC20
                sendTransaction: function() {
                    if(bestRoutes.count === 1) {
                        let path = bestRoutes.firstItem()
                        let eip1559Enabled = path.gasFees.eip1559Enabled
                        let maxFeePerGas = path.gasFees.maxFeePerGasM
                        stickerPackDetailsPopup.store.stickersStore.authenticateAndBuy(packId,
                                                                                       store.selectedSenderAccount.address,
                                                                                       path.gasAmount,
                                                                                       eip1559Enabled ? "" : path.gasFees.gasPrice,
                                                                                       eip1559Enabled ? path.gasFees.maxPriorityFeePerGas : "",
                                                                                       eip1559Enabled ? maxFeePerGas : path.gasFees.gasPrice,
                                                                                       eip1559Enabled)
                    }
                }
                Connections {
                    target: stickerPackDetailsPopup.store.stickersStore.stickersModule
                    function onTransactionWasSent(chainId: int, txHash: string, error: string) {
                        if (!!error) {
                            if (error.includes(Constants.walletSection.cancelledMessage)) {
                                return
                            }
                            buyStickersPackModal.sendingError.text = error
                            return buyStickersPackModal.sendingError.open()
                        }
                        let url =  "%1/%2".arg(buyStickersPackModal.store.getEtherscanLink(chainId)).arg(txHash)
                        Global.displayToastMessage(qsTr("Transaction pending..."),
                                                   qsTr("View on etherscan"),
                                                   "",
                                                   true,
                                                   Constants.ephemeralNotificationType.normal,
                                                   url)
                        buyStickersPackModal.close()
                    }
                }
            }
        }
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
