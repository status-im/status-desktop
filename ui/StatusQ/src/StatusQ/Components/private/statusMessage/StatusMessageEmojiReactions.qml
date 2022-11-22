import QtQuick 2.3
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.14
import QtGraphicalEffects 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

Item {
    id: root

    implicitHeight: 22
    implicitWidth: childrenRect.width

    property int imageMargin: 4
    signal addEmojiClicked(var sender, var mouse)
    signal hoverChanged(bool hovered)
    signal toggleReaction(int emojiID)

    property bool isCurrentUser
    property var emojiReactionsModel

    property var icons: []

    QtObject {
        id: d

        function lastTwoItems(nodes) {
            return nodes.join(qsTr(" and "));
        }

        function showReactionAuthors(jsonArrayOfUsersReactedWithThisEmoji, emojiId) {
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
                        .arg(Emoji.getEmojiFromId(emojiId));
        }
    }

    Row {
        spacing: root.imageMargin

        Repeater {
            id: reactionRepeater

            width: childrenRect.width
            model: root.emojiReactionsModel

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

                    StatusEmoji {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 15
                        height: 15

                        source: {
                            if (model.emojiId >= 1 && model.emojiId <= root.icons.length)
                                return root.icons[model.emojiId - 1];
                            return "";
                        }
                    }

                    StatusBaseText {
                        anchors.verticalCenter: parent.verticalCenter
                        text: model.numberOfReactions
                        font.pixelSize: 12
                        color: model.didIReactWithThisEmoji ? Theme.palette.indirectColor1 : Theme.palette.directColor1
                    }

                }

                StatusToolTip {
                    visible: reactionDelegate.hovered
                    maxWidth: 400
                    text: d.showReactionAuthors(model.jsonArrayOfUsersReactedWithThisEmoji, model.emojiId)
                }

                MouseArea {
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
                        root.toggleReaction(model.emojiId)
                    }
                }
            }
        }

        Item {
            width: addEmojiButton.width + addEmojiButton.anchors.leftMargin // there is more margin between the button and the emojis than between each emoji
            height: addEmojiButton.height

            StatusIcon {
                id: addEmojiButton

                readonly property bool isHovered: addEmojiButtonMouseArea.containsMouse

                anchors.left: parent.left
                anchors.leftMargin: 2.5

                icon: "reaction-b"
                width: 16.5
                height: 16.5

                color: addEmojiButton.isHovered ? Theme.palette.primaryColor1 : Theme.palette.baseColor1
            }

            MouseArea {
                id: addEmojiButtonMouseArea
                anchors.fill: addEmojiButton
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: {
                    root.addEmojiClicked(this, mouse);
                }
            }

            StatusToolTip {
                visible: addEmojiButton.isHovered
                text: qsTr("Add reaction")
            }
        }
    }
}
