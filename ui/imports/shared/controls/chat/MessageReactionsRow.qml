import QtQuick

import StatusQ.Core.Theme

import shared.controls.chat

Row {
    id: root

    property var defaultEmojiReactionsModel

    signal toggleReaction(string emoji)

    spacing: Theme.halfPadding
    leftPadding: Theme.halfPadding
    rightPadding: Theme.halfPadding

    Repeater {
        model: root.defaultEmojiReactionsModel
        delegate: EmojiReaction {
            source: Theme.svg(model.filename)
            emoji: model.emoji
            reactedByUser: model.didIReactWithThisEmoji
            onCloseModal: {
                if (reactedByUser) {
                    return
                }
                root.toggleReaction(emoji)
            }
        }
    }
}
