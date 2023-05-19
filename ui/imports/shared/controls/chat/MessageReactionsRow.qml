import QtQuick 2.15

import utils 1.0
import shared 1.0

Row {
    id: root

    property var reactionsModel
    property var messageReactionsModel: [] // TODO: https://github.com/status-im/status-desktop/issues/10703

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
