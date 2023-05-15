import QtQuick 2.15

import utils 1.0
import shared 1.0

Row {
    id: root

    property var reactionsModel
    property var messageReactionsModel: [] // TODO: We never used this correctly. And this is not Discord-like behavior.

    signal toggleReaction(int emojiId)

    spacing: Style.current.halfPadding
    leftPadding: Style.current.halfPadding
    rightPadding: Style.current.halfPadding

    Repeater {
        model: root.reactionsModel
        delegate: EmojiReaction {
            source: Style.svg(filename)
            emojiId: model.emojiId
            // reactedByUser: !!root.messageReactionsModel[emojiId]
            onCloseModal: {
                root.toggleReaction(emojiId)
            }
        }
    }
}
