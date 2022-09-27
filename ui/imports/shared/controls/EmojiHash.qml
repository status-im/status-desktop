import QtQuick 2.13

import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Components 0.1

import utils 1.0

Item {
    id: root

    property bool compact: false
    property bool oneRow
    property string publicKey

    readonly property real size: compact ? 10 : 15

    implicitHeight: positioner.implicitHeight
    implicitWidth: positioner.implicitWidth

    Grid {
        id: positioner

        rows: root.oneRow ? 1 : 2
        columnSpacing: root.oneRow ? 4 : 2
        rowSpacing: root.compact ? 4 : 6

        Repeater {
            model: Utils.getEmojiHashAsJson(root.publicKey)

            StatusEmoji {
                width: root.size
                height: root.size
                emojiId: StatusQUtils.Emoji.iconId(modelData)
            }
        }
    }
}
