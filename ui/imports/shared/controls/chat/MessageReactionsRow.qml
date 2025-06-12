import QtQuick 2.15

import StatusQ.Core.Theme 0.1

import shared.controls.chat 1.0

Row {
    id: root

    property var reactionsModel

    signal toggleReaction(int emojiId)

    spacing: Theme.halfPadding
    leftPadding: Theme.halfPadding
    rightPadding: Theme.halfPadding

    Repeater {
        model: root.reactionsModel
        delegate: EmojiReaction {
            source: Theme.svg(model.filename)
            emojiId: model.emojiId
            reactedByUser: model.didIReactWithThisEmoji
            onCloseModal: {
                if (reactedByUser) {
                    return
                }
                root.toggleReaction(emojiId)
            }
        }
    }
}
