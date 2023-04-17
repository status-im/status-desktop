import QtQuick 2.13
import QtQuick.Controls 2.13

import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared.panels 1.0

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
