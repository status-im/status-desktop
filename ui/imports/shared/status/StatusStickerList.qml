import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import utils 1.0
import shared 1.0
import shared.panels 1.0

GridView {
    id: root
    property int packId: -1
    property var stickerGrid
    visible: count > 0
    anchors.fill: parent
    cellWidth: Style.dp(88)
    cellHeight: Style.dp(88)
    model: stickerList
    focus: true
    clip: true
    signal stickerClicked(string hash, int packId)
    delegate: Item {
        width: root.cellWidth
        height: root.cellHeight
        Column {
            anchors.fill: parent
            anchors.topMargin: Style.current.halfPadding/2
            anchors.leftMargin: Style.current.halfPadding/2
            ImageLoader {
                width: Style.dp(80)
                height: Style.dp(80)
                source: url
                onClicked: {
                    root.stickerClicked(hash, packId)
                }
            }
        }
    }
}
