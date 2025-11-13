import QtQuick

import StatusQ
import StatusQ.Core.Theme
import StatusQ.Controls

import shared.controls.chat

import SortFilterProxyModel

Row {
    id: root

    required property var emojiModel
    property int buttonSize

    signal toggleReaction(string emoji)
    signal openEmojiPopup(var parent, var mouse)

    height: buttonSize
    spacing: Theme.halfPadding
    leftPadding: Theme.halfPadding
    rightPadding: Theme.halfPadding

    Loader {
        active: root.visible

        sourceComponent: Row {
            spacing: Theme.halfPadding

            Repeater {
                id: recentEmojisRepeater
                model: 5 // Only show up to 5 recent emojis
                delegate: EmojiReaction {
                    id: emojiReaction

                    required property int index
                    property var emoji: root.emojiModel.get(index)

                    emojiId: emojiReaction.emoji.unicode
                    anchors.verticalCenter: parent.verticalCenter
                    // TODO not implemented yet. We'll need to pass this info
                    // reactedByUser: model.didIReactWithThisEmoji
                    onToggleReaction: {
                        root.toggleReaction(emojiReaction.emoji.emoji)
                    }
                }
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
