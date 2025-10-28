import QtQuick
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Core.Utils
import StatusQ.Controls
import StatusQ.Components

Flow {
    id: root

    spacing: 4

    property int imageMargin: 4
    signal addEmojiClicked(var sender, var mouse)
    signal hoverChanged(bool hovered)
    signal toggleReaction(string emoji)

    property bool isCurrentUser
    property var reactionsModel
    property bool limitReached: false

    QtObject {
        id: d

        readonly property string addReactionButtonName: "addReactionButton"

        function lastTwoItems(nodes) {
            return nodes.join(qsTr(" and "));
        }

        function showReactionAuthors(jsonArrayOfUsersReactedWithThisEmoji, emoji) {
            if (!jsonArrayOfUsersReactedWithThisEmoji) {
                return
            }
            const listOfUsers = JSON.parse(jsonArrayOfUsersReactedWithThisEmoji)
            if (listOfUsers.error) {
                console.error("error parsing users who reacted to a message, error: ", obj.error)
                return
            }

            let author;
            if (listOfUsers.length === 1) {
                author = listOfUsers[0]
            } else if (listOfUsers.length === 2) {
                author = lastTwoItems(listOfUsers);
            } else {
                var leftNode = [];
                var rightNode = [];
                const maxReactions = 12
                let maximum = Math.min(maxReactions, listOfUsers.length)

                if (listOfUsers.length > maxReactions) {
                    leftNode = listOfUsers.slice(0, maxReactions);
                    rightNode = listOfUsers.slice(maxReactions, listOfUsers.length);
                    return (rightNode.length === 1) ?
                                lastTwoItems([leftNode.join(", "), rightNode[0]]) :
                                lastTwoItems([leftNode.join(", "), qsTr("%1 more").arg(rightNode.length)]);
                }

                leftNode = listOfUsers.slice(0, maximum - 1);
                rightNode = listOfUsers.slice(maximum - 1, listOfUsers.length);
                author = lastTwoItems([leftNode.join(", "), rightNode[0]])
            }
            return qsTr("%1 reacted with %2")
                        .arg(author)
                        .arg(emoji);
        }
    }

    Repeater {
        model: root.reactionsModel

        Control {
            id: reactionDelegate

            topPadding: 3
            bottomPadding: 3
            leftPadding: 4
            rightPadding: 5

            background: Rectangle {
                radius: 8
                color: {
                    if (reactionDelegate.hovered) {
                        return Theme.palette.statusMessage.emojiReactionBackgroundHovered
                    }
                    return model.didIReactWithThisEmoji ? Theme.palette.primaryColor2 : Theme.palette.statusMessage.emojiReactionBackground
                }
                border.width: model.didIReactWithThisEmoji || reactionDelegate.hovered ? 1 : 0
                border.color: reactionDelegate.hovered ? Theme.palette.statusMessage.emojiReactionBorderHovered : Theme.palette.primaryColor1
            }

            contentItem: Row {
                spacing: 4

                StatusBaseText {
                    objectName: "emojiReaction"
                    font.pixelSize: Theme.fontSize17
                    anchors.verticalCenter: parent.verticalCenter
                    text: model.emoji
                }

                StatusBaseText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: model.numberOfReactions
                    font.pixelSize: Theme.fontSize14
                }
            }

            StatusToolTip {
                visible: reactionDelegate.hovered
                maxWidth: 400
                text: d.showReactionAuthors(model.jsonArrayOfUsersReactedWithThisEmoji, model.emoji) || ""
            }

            StatusMouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: {
                    root.hoverChanged(true)
                }
                onExited: {
                    root.hoverChanged(false)
                }
                onClicked: {
                    root.toggleReaction(model.emoji)
                }
            }
        }
    }

    Item {
        width: addEmojiButton.width
        height: addEmojiButton.height
        visible: root.enabled

        StatusIcon {
            id: addEmojiButton

            readonly property bool isHovered: addEmojiButtonMouseArea.containsMouse

            icon: "reaction-b"
            width: 22
            height: 22

            color: addEmojiButton.isHovered && !root.limitReached ? Theme.palette.primaryColor1 : Theme.palette.baseColor1
        }

        StatusMouseArea {
            id: addEmojiButtonMouseArea
            anchors.fill: addEmojiButton
            cursorShape: !root.limitReached ? Qt.PointingHandCursor : Qt.ArrowCursor
            hoverEnabled: true
            onClicked: (mouse) => {
                if (root.limitReached)
                    return
                root.addEmojiClicked(this, mouse);
            }
        }

        StatusToolTip {
            visible: addEmojiButton.isHovered
            text: root.limitReached ? qsTr("Maximum number of different reactions reached") : qsTr("Add reaction")
        }
    }
}
