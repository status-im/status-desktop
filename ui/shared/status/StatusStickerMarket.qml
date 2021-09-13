import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import "../../imports"
import "../../shared"
import "../../shared/status"
import "../../app/AppLayouts/Chat/ChatColumn/samples"

Item {
    id: root
    property var stickerPacks: StickerPackData {}
    property var stickerPurchasePopup

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
        model: stickerPacks
        focus: true
        clip: true
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
                source: "https://ipfs.infura.io/ipfs/" + preview
                onClicked: {
                    stickerPackDetailsPopup.open()
                }
            }

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
                        root.stickerPurchasePopup = openPopup(stickerPackPurchaseModal)
                        root.buyClicked(packId)
                    }
                }
            }
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

            Connections {
                target: chatsModel.stickers
                function onGasEstimateReturned(estimate, uuid) {
                    stickerPurchasePopup.setAsyncGasLimitResult(uuid, estimate)
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
                        if (!appSettings.isWalletEnabled) {
                            confirmationPopup.open()
                            return
                        }
                        root.stickerPurchasePopup = openPopup(stickerPackPurchaseModal)
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
                    appSettings.isWalletEnabled = true
                    close()
                    root.stickerPurchasePopup = openPopup(stickerPackPurchaseModal)
                    root.buyClicked(packId)
                }

                onCancelButtonClicked: {
                    close()
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
            source: "../../app/img/arrowUp.svg"
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
