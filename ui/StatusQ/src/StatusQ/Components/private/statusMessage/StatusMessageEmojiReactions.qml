import QtQuick
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Core.Utils
import StatusQ.Controls
import StatusQ.Components

Item {
    id: root

    implicitHeight: 22
    implicitWidth: childrenRect.width

    property int imageMargin: 4
    signal addEmojiClicked(var sender, var mouse)
    signal hoverChanged(bool hovered)
    signal toggleReaction(string emoji)

    property bool isCurrentUser
    property var reactionsModel
    property bool limitReached: false

    QtObject {
        id: d

        function lastTwoItems(nodes) {
            return nodes.join(qsTr(" and "));
        }

        function showReactionAuthors(jsonArrayOfUsersReactedWithThisEmoji, emoji) {
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

    Row {
        spacing: root.imageMargin

        Repeater {
            id: reactionRepeater

            width: childrenRect.width
            model: root.reactionsModel

            Control {
                id: reactionDelegate

                topPadding: 2
                bottomPadding: 2
                leftPadding: 2
                rightPadding: 6

                background: Rectangle {
                    radius: 10
                    color: model.didIReactWithThisEmoji
                               ? (reactionDelegate.hovered ? Theme.palette.statusMessage.emojiReactionActiveBackgroundHovered
                                                         : Theme.palette.statusMessage.emojiReactionActiveBackground)
                               : (reactionDelegate.hovered ? Theme.palette.statusMessage.emojiReactionBackgroundHovered
                                                         : Theme.palette.statusMessage.emojiReactionBackground)

                    // Rounded corner to cover one corner
                    Rectangle {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        width: 10
                        height: 10
                        radius: 2
                        color: parent.color
                    }
                }

                contentItem: Row {
                    spacing: 4

                    StatusBaseText {
                        objectName: "emojiReaction"
                        anchors.verticalCenter: parent.verticalCenter
                        text: model.emoji
                    }

                    StatusBaseText {
                        anchors.verticalCenter: parent.verticalCenter
                        text: model.numberOfReactions
                        font.pixelSize: Theme.tertiaryTextFontSize
                        color: model.didIReactWithThisEmoji ? Theme.palette.white : Theme.palette.directColor1
                    }

                }

                StatusToolTip {
                    visible: reactionDelegate.hovered
                    maxWidth: 400
                    text: d.showReactionAuthors(model.jsonArrayOfUsersReactedWithThisEmoji, model.emoji)
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
            width: addEmojiButton.width + addEmojiButton.anchors.leftMargin // there is more margin between the button and the emojis than between each emoji
            height: addEmojiButton.height
            visible: root.enabled

            StatusIcon {
                id: addEmojiButton

                readonly property bool isHovered: addEmojiButtonMouseArea.containsMouse

                anchors.left: parent.left
                anchors.leftMargin: 2.5

                icon: "reaction-b"
                width: 16.5
                height: 16.5

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
}
