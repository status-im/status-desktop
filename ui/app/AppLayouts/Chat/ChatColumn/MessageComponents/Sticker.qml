import QtQuick 2.3
import "../../../../../shared" as Shared
import "../../../../../imports"

Loader {
    property color color
    property var container
    property int contentType: -1

    id: root
    active: contentType === Constants.stickerType

    sourceComponent: Component {
        Shared.ImageLoader {
            color: root.color
            onLoaded: scrollToBottom(true, root.container)

            width: 140 * scaleAction.factor
            height: this.visible ? 140 * scaleAction.factor : 0
            source: this.visible ? ("https://ipfs.infura.io/ipfs/" + sticker) : ""
        }
    }
}
