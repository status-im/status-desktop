import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQml.Models 2.3

import StatusQ.Popups 0.1
import StatusQ.Components 0.1

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.status 1.0
import shared.controls.chat 1.0
import shared.controls.chat.menuItems 1.0

StatusMenu {
    id: root

    property alias reactionsModel: emojiRow.reactionsModel
    property alias messageReactionsModel: emojiRow.messageReactionsModel

    signal toggleReaction(int emojiId)

    width: emojiRow.width

    MessageReactionsRow {
        id: emojiRow
        onToggleReaction: {
            root.toggleReaction(emojiId)
            root.close()
        }
    }
}
