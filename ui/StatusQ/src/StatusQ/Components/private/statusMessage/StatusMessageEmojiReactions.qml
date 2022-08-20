import QtQuick 2.3
import QtQuick.Controls 2.13
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

    property var store
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

            Rectangle {
                id: emojiContainer

                readonly property bool isHovered: mouseArea.containsMouse

                width: emojiImage.width + emojiCount.width + (root.imageMargin * 2) +  + 8
                height: 20
                radius: 10
                color: model.didIReactWithThisEmoji ?
                           (isHovered ? Theme.palette.statusMessage.emojiReactionActiveBackgroundHovered : Theme.palette.statusMessage.emojiReactionActiveBackground) :
                           (isHovered ? Theme.palette.statusMessage.emojiReactionBackgroundHovered : Theme.palette.statusMessage.emojiReactionBackground)

                StatusToolTip {
                    visible: mouseArea.containsMouse
                    maxWidth: 400
                    text: d.showReactionAuthors(model.jsonArrayOfUsersReactedWithThisEmoji, model.emojiId)
                }

                // Rounded corner to cover one corner
                Rectangle {
                    color: parent.color
                    width: 10
                    height: 10
                    anchors.top: parent.top
                    anchors.left: !root.isCurrentUser ? parent.left : undefined
                    anchors.leftMargin: 0
                    anchors.right: !root.isCurrentUser ? undefined : parent.right
                    anchors.rightMargin: 0
                    radius: 2
                    z: -1
                }

                // This is a workaround to get a "border" around the rectangle including the weird rectangle
                Loader {
                    active: model.didIReactWithThisEmoji
                    anchors.top: parent.top
                    anchors.topMargin: -1
                    anchors.left: parent.left
                    anchors.leftMargin: -1
                    z: -2

                    sourceComponent: Component {
                        Rectangle {
                            width: emojiContainer.width + 2
                            height: emojiContainer.height + 2
                            radius: emojiContainer.radius
                            color: Theme.palette.primaryColor1

                            Rectangle {
                                color: parent.color
                                width: 10
                                height: 10
                                anchors.top: parent.top
                                anchors.left: !root.isCurrentUser ? parent.left : undefined
                                anchors.leftMargin: 0
                                anchors.right: !root.isCurrentUser ? undefined : parent.right
                                anchors.rightMargin: 0
                                radius: 2
                                z: -1
                            }
                        }
                    }
                }

                // TODO: Use Row

                StatusEmoji {
                    id: emojiImage

                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: root.imageMargin

                    width: 15
                    height: 15

                    source: {
                        if (model.emojiId >= 1 && model.emojiId <= root.icons.length)
                            return root.icons[model.emojiId - 1];
                        return "";
                    }
                }

                StatusBaseText {
                    id: emojiCount
                    text: model.numberOfReactions
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: emojiImage.right
                    anchors.leftMargin: root.imageMargin
                    font.pixelSize: 12
                    color: model.didIReactWithThisEmoji ? Theme.palette.primaryColor1 : Theme.palette.directColor1
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

                property bool isHovered: false // TODO: Replace with mouseArea.containsMouse

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
                onEntered: addEmojiButton.isHovered = true
                onExited: addEmojiButton.isHovered = false
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
