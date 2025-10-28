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
    property int buttonSize

    signal toggleReaction(string emoji)
    signal openEmojiPopup(var parent, var mouse)

    height: buttonSize
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
