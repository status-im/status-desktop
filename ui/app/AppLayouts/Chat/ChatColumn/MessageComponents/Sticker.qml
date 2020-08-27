import QtQuick 2.3
import "../../../../../imports"

Image {
    id: stickerId
    visible: contentType === Constants.stickerType
    width: 140
    height: this.visible ? 140 : 0
    sourceSize.width: width
    sourceSize.height: height
    source: this.visible ? ("https://ipfs.infura.io/ipfs/" + sticker) : ""
}
