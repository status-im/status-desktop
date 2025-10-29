import QtQuick

import StatusQ
import StatusQ.Core.Theme
import StatusQ.Controls

import shared.controls.chat

import SortFilterProxyModel

Row {
    id: root

    required property StatusEmojiModel emojiModel
    required property var recentEmojis
    required property string skinColor

    signal toggleReaction(string emoji)
    signal openEmojiPopup(var parent, var mouse)

    spacing: Theme.halfPadding
    leftPadding: Theme.halfPadding
    rightPadding: Theme.halfPadding

    Component.onCompleted: {
        if (!root.recentEmojis) {
            return
        }
        root.emojiModel.recentEmojis = root.recentEmojis
    }

    QtObject {
        id: d

        readonly property var recentEmojisModel: SortFilterProxyModel {
            sourceModel: root.emojiModel

            filters: [
                IndexFilter {
                    // Only show the first 5 emojis
                    maximumIndex: 4
                },
                AnyOf {
                    ValueFilter {
                        roleName: "skinColor"
                        value: ""
                    }
                    ValueFilter {
                        roleName: "skinColor"
                        value: root.emojiModel.baseSkinColorName
                    }
                    enabled: root.skinColor === ""
                },
                AnyOf {
                    ValueFilter {
                        roleName: "skinColor"
                        value: ""
                    }
                    ValueFilter {
                        roleName: "skinColor"
                        value: root.skinColor
                    }
                    enabled: root.skinColor !== ""
                }
            ]

            sorters: RoleSorter {
                roleName: "emoji_order"
            }
        }
    }

    Repeater {
        model: 5 // Only show up to 5 recent emojis
        delegate: EmojiReaction {
            id: emojiReaction

            required property int index
            property var emoji: visible ? d.recentEmojisModel.get(index) : null

            visible: index < d.recentEmojisModel.count
            emojiId: visible ? emojiReaction.emoji.unicode : ""
            // TODO not implemented yet. We'll need to pass this info
            // reactedByUser: model.didIReactWithThisEmoji
            onToggleReaction: {
                root.toggleReaction(emojiReaction.emoji.emoji)
            }
        }
    }

    StatusFlatRoundButton {
        height: parent.height
        width: height
        icon.name: "reaction-b"
        type: StatusFlatRoundButton.Type.Tertiary
        onClicked: mouse => root.openEmojiPopup(this, mouse)
    }
}
