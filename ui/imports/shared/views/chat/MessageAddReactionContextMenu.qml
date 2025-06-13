import StatusQ.Popups 0.1

import shared.controls.chat 1.0

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
