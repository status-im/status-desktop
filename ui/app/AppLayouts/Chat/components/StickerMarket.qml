import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import "../../../../imports"
import "../../../../shared"
import "../ChatColumn/samples"

Item {
    id: root
    property var stickerPacks: StickerPackData {}
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
                height: 472
                header: StickerPackDetails {
                    height: 46
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
                footer: StickerButton {
                    height: 76
                    anchors.right: parent.right
                    style: StickerButton.StyleType.LargeNoIcon
                    packPrice: price
                    isInstalled: installed
                    onInstallClicked: root.installClicked(stickers, packId, index)
                    onUninstallClicked: root.uninstallClicked(packId)
                    onCancelClicked: root.cancelClicked(packId)
                    onUpdateClicked: root.updateClicked(packId)
                    onBuyClicked: root.buyClicked(packId)
                }
                contentWrapper.anchors.topMargin: 0
                contentWrapper.anchors.bottomMargin: 0
                StickerList {
                    id: stickerGridInPopup
                    model: stickers
                    height: 350
                }
            }
            StickerPackDetails {
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

                StickerButton {
                    anchors.right: parent.right
                    packPrice: price
                    width: 75 // only needed for Qt Creator
                    isInstalled: installed
                    onInstallClicked: root.installClicked(stickers, packId, index)
                    onUninstallClicked: root.uninstallClicked(packId)
                    onCancelClicked: root.cancelClicked(packId)
                    onUpdateClicked: root.updateClicked(packId)
                    onBuyClicked: root.buyClicked(packId)
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
            source: "../../../img/arrowUp.svg"
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
