import QtQuick
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Controls

import utils
import shared.panels

StatusGridView {
    id: root

    property string packId
    signal stickerClicked(string hash, string packId, string url)

    ScrollBar.vertical: StatusScrollBar {}

    visible: count > 0
    cellWidth: 88
    cellHeight: 88
    focus: true

    delegate: Item {
        width: root.cellWidth
        height: root.cellHeight
        Column {
            anchors.fill: parent
            anchors.topMargin: 4
            anchors.leftMargin: 4
            ImageLoader {
                width: 80
                height: 80
                source: url
                onClicked: {
                    root.stickerClicked(hash, packId, url)
                }
            }
        }
    }
}
