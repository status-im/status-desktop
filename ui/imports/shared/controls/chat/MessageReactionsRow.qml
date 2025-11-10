import QtQuick

import StatusQ
import StatusQ.Core.Theme
import StatusQ.Controls

import shared.controls.chat

import SortFilterProxyModel

Row {
    id: root

    required property SortFilterProxyModel emojiModel
    property int buttonSize

    signal toggleReaction(string emoji)
    signal openEmojiPopup(var parent, var mouse)

    height: buttonSize
    spacing: Theme.halfPadding
    leftPadding: Theme.halfPadding
    rightPadding: Theme.halfPadding

    Connections {
        target: root.emojiModel
        onRecentEmojisUpdated: {
            // Force re-evaluation of recentEmojisRepeater
            recentEmojisRepeater.model = 0
            recentEmojisRepeater.model = 5

        }
    }

    QtObject {
        id: d

        readonly property var recentEmojisModel: SortFilterProxyModel {
            sourceModel: root.emojiModel

            filters: [
                IndexFilter {
                    // Only show the first 5 emojis
                    maximumIndex: 4
                }
            ]
        }
    }

    Repeater {
        id: recentEmojisRepeater
        model: 5 // Only show up to 5 recent emojis
        delegate: EmojiReaction {
            id: emojiReaction

            required property int index
            property var emoji: d.recentEmojisModel.get(index)

            emojiId: emojiReaction.emoji.unicode
            anchors.verticalCenter: parent.verticalCenter
            // TODO not implemented yet. We'll need to pass this info
            // reactedByUser: model.didIReactWithThisEmoji
            onToggleReaction: {
                root.toggleReaction(emojiReaction.emoji.emoji)
            }
        }
    }

    StatusFlatRoundButton {
        height: root.buttonSize ? buttonSize : parent.height
        width: height
        icon.name: "reaction-b"
        type: StatusFlatRoundButton.Type.Tertiary
        onClicked: mouse => root.openEmojiPopup(this, mouse)
    }
}
