import QtQuick 2.3
import "../../../../../shared" as Shared
import "../../../../../imports"

Loader {
    property color color

    id: root
    active: contentType === Constants.stickerType

    sourceComponent: Component {
        Shared.ImageLoader {
            color: root.color
            onLoaded: {
                scrollToBottom(true, messageItem)
            }

            width: 140
            height: this.visible ? 140 : 0
            source: this.visible ? ("https://ipfs.infura.io/ipfs/" + sticker) : ""
        }
    }
}
