import QtQuick

import StatusQ.Core.Theme

import shared.controls.chat

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
