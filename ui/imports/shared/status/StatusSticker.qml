import QtQuick 2.3
import shared.panels 1.0

import utils 1.0

Loader {
    property color color
    property int contentType: -1
    property string stickerData: ""
    property int imageHeight: 140
    property int imageWidth: 140
    signal loaded()

    id: root
    active: contentType === Constants.messageContentType.stickerType

    sourceComponent: Component {
        ImageLoader {
            color: root.color
            onLoaded: root.loaded()

            width: imageWidth
            height: this.visible ? imageHeight : 0
            source: this.visible ? ("https://ipfs.infura.io/ipfs/" + stickerData) : ""
        }
    }
}
