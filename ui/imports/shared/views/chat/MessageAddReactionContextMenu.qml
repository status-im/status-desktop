import StatusQ.Popups

import shared.controls.chat

StatusMenu {
    id: root

    property alias reactionsModel: emojiRow.reactionsModel

    signal toggleReaction(int emojiId)

    width: emojiRow.width

    MessageReactionsRow {
        id: emojiRow
        onToggleReaction: function(emojiId) {
            root.toggleReaction(emojiId)
            root.close()
        }
    }
}
